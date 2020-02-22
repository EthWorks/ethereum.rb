require 'forwardable'

module Ethereum
  class Contract

    attr_reader :address
    attr_accessor :key
    attr_accessor :gas_limit, :gas_price, :nonce
    attr_accessor :code, :name, :abi, :class_object, :sender, :deployment, :client
    attr_accessor :events, :functions, :constructor_inputs
    attr_accessor :call_raw_proxy, :call_proxy, :transact_proxy, :transact_and_wait_proxy
    attr_accessor :new_filter_proxy, :get_filter_logs_proxy, :get_filter_change_proxy

    def initialize(name, code, abi, client = Ethereum::Singleton.instance)
      @name = name
      @code = code
      @abi = abi
      @constructor_inputs, @functions, @events = Ethereum::Abi.parse_abi(abi)
      @formatter = Ethereum::Formatter.new
      @client = client
      @sender = client.default_account
      @encoder = Encoder.new
      @decoder = Decoder.new
      @gas_limit = @client.gas_limit
      @gas_price = @client.gas_price
    end

    # Creates a contract wrapper.
    # This method attempts to instantiate a contract object from a Solidity source file, from a Truffle
    # artifacts file, or from explicit API and bytecode.
    # - If *:file* is present, the method compiles it and looks up the contract factory at *:contract_index*
    #   (0 if not provided). *:abi* and *:code* are ignored.
    # - If *:truffle* is present, the method looks up the Truffle artifacts data for *:name* and uses
    #   those data to build a contract instance.
    # - Otherwise, the method uses *:name*, *:code*, and *:abi* to build the contract instance.
    #
    # @param opts [Hash] Options to the method.
    # @option opts [String] :file Path to the Solidity source that contains the contract code.
    # @option opts [Ethereum::Singleton] :client The client to use.
    # @option opts [String] :code The hex representation of the contract's bytecode.
    # @option opts [Array,String] :abi The contract's ABI; a string is assumed to contain a JSON representation
    #  of the ABI.
    # @option opts [String] :address The contract's address; if not present and +:truffle+ is present,
    #  the method attempts to determine the address from the artifacts' +networks+ key and the client's
    #  network id.
    # @option opts [String] :name The contract name.
    # @option opts [Integer] :contract_index The index of the contract data in the compiled file.
    # @option opts [Hash] :truffle If this parameter is present, the method uses Truffle information to
    #  generate the contract wrapper.
    #  - *:paths* An array of strings containing the list of paths where to look up Truffle artifacts files.
    #    See also {#find_truffle_artifacts}.
    #
    # @return [Ethereum::Contract] Returns a contract wrapper.

    def self.create(file: nil, client: Ethereum::Singleton.instance, code: nil, abi: nil, address: nil, name: nil, contract_index: nil, truffle: nil)
      contract = nil
      if file.present?
        contracts = Ethereum::Initializer.new(file, client).build_all
        raise "No contracts compiled" if contracts.empty?
        if contract_index
          contract = contracts[contract_index].class_object.new
        else
          contract = contracts.first.class_object.new
        end
      else
        if truffle.present? && truffle.is_a?(Hash)
          artifacts = find_truffle_artifacts(name, (truffle[:paths].is_a?(Array)) ? truffle[:paths] : [])
          if artifacts
            abi = artifacts['abi']
            # The truffle artifacts store bytecodes with a 0x tag, which we need to remove
            # this may need to be 'deployedBytecode'
            code_key = artifacts['bytecode'].present? ? 'bytecode' : 'unlinked_binary'
            code = (artifacts[code_key].start_with?('0x')) ? artifacts[code_key][2, artifacts[code_key].length] : artifacts[code_key]
            unless address
              address = if client
                          network_id = client.net_version['result']
                          (artifacts['networks'][network_id]) ? artifacts['networks'][network_id]['address'] : nil
                        else
                          nil
                        end
            end
          else
            abi = nil
            code = nil
          end
        else
          abi = abi.is_a?(String) ? JSON.parse(abi) : abi.map(&:deep_stringify_keys)
        end
        contract = Ethereum::Contract.new(name, code, abi, client)
        contract.build
        contract = contract.class_object.new
      end
      contract.address = address
      contract
    end

    def address=(addr)
      @address = addr
      @events.each do |event|
        event.set_address(addr)
        event.set_client(@client)
      end
    end

    def deploy_payload(params)
      if @constructor_inputs.present?
        raise ArgumentError, "Wrong number of arguments in a constructor" and return if params.length != @constructor_inputs.length
      end
      deploy_arguments = @encoder.encode_arguments(@constructor_inputs, params)
      "0x" + @code + deploy_arguments
    end

    def deploy_args(params)
      add_gas_options_args({from: sender, data: deploy_payload(params)})
    end

    def send_transaction(tx_args)
        @client.eth_send_transaction(tx_args)["result"]
    end

    def send_raw_transaction(payload, to = nil)
      Eth.configure { |c| c.chain_id = @client.net_version["result"].to_i }
      @nonce = @client.get_nonce(key.address)
      args = {
        from: key.address,
        value: 0,
        data: payload,
        nonce: @nonce,
        gas_limit: gas_limit,
        gas_price: gas_price
      }
      args[:to] = to if to
      tx = Eth::Tx.new(args)
      tx.sign key
      @client.eth_send_raw_transaction(tx.hex)["result"]
    end

    def deploy(*params)
      if key
        tx = send_raw_transaction(deploy_payload(params))
      else
        tx = send_transaction(deploy_args(params))
      end
      tx_failed = tx.nil? || tx == "0x0000000000000000000000000000000000000000000000000000000000000000"
      raise IOError, "Failed to deploy, did you unlock #{sender} account? Transaction hash: #{tx}" if tx_failed
      @deployment = Ethereum::Deployment.new(tx, @client)
    end

    def deploy_and_wait(*params, **args, &block)
      deploy(*params)
      @deployment.wait_for_deployment(**args, &block)
      self.events.each do |event|
        event.set_address(@address)
        event.set_client(@client)
      end
      @address = @deployment.contract_address
    end

    def estimate(*params)
      result = @client.eth_estimate_gas(deploy_args(params))
      @decoder.decode_int(result["result"])
    end

    def call_payload(fun, args)
      "0x" + fun.signature + (@encoder.encode_arguments(fun.inputs, args).presence || "0"*64)
    end

    def call_args(fun, args)
      add_gas_options_args({to: @address, from: @sender, data: call_payload(fun, args)})
    end

    def call_raw(fun, *args)
      raw_result = @client.eth_call(call_args(fun, args))["result"]
      output = @decoder.decode_arguments(fun.outputs, raw_result)
      return {data: call_payload(fun, args), raw: raw_result, formatted: output}
    end

    def call(fun, *args)
      output = call_raw(fun, *args)[:formatted]
      if output.length == 1
        return output[0]
      else
        return output
      end
    end

    def transact(fun, *args)
      if key
        tx = send_raw_transaction(call_payload(fun, args), address)
      else
        tx = send_transaction(call_args(fun, args))
      end
      return Ethereum::Transaction.new(tx, @client, call_payload(fun, args), args)
    end

    def transact_and_wait(fun, *args)
      tx = transact(fun, *args)
      tx.wait_for_miner
      return tx
    end

    def create_filter(evt, **params)
      params[:to_block] ||= "latest"
      params[:from_block] ||= "0x0"
      params[:address] ||= @address
      params[:topics] = @encoder.ensure_prefix(evt.signature)
      payload = {topics: [params[:topics]], fromBlock: params[:from_block], toBlock: params[:to_block], address: @encoder.ensure_prefix(params[:address])}
      filter_id = @client.eth_new_filter(payload)
      return @decoder.decode_int(filter_id["result"])
    end

    def parse_filter_data(evt, logs)
      formatter = Ethereum::Formatter.new
      collection = []
      logs["result"].each do |result|
        inputs = evt.input_types
        outputs = inputs.zip(result["topics"][1..-1])
        data = {blockNumber: result["blockNumber"].hex, transactionHash: result["transactionHash"], blockHash: result["blockHash"], transactionIndex: result["transactionIndex"].hex, topics: []}
        outputs.each do |output|
          data[:topics] << formatter.from_payload(output)
        end
        collection << data
      end
      return collection
    end

    def get_filter_logs(evt, filter_id)
      parse_filter_data evt, @client.eth_get_filter_logs(filter_id)
    end

    def get_filter_changes(evt, filter_id)
      parse_filter_data evt, @client.eth_get_filter_changes(filter_id)
    end

    def function_name(fun)
      count = functions.select {|x| x.name == fun.name }.count
      name = (count == 1) ? "#{fun.name.underscore}" : "#{fun.name.underscore}__#{fun.inputs.collect {|x| x.type}.join("__")}"
      name.to_sym
    end

    def build
      class_name = @name.camelize
      parent = self
      create_function_proxies
      create_event_proxies
      class_methods = Class.new do
        extend Forwardable
        def_delegators :parent, :deploy_payload, :deploy_args, :call_payload, :call_args
        def_delegators :parent, :signed_deploy, :key, :key=
        def_delegators :parent, :gas_limit, :gas_price, :gas_limit=, :gas_price=, :nonce, :nonce=
        def_delegators :parent, :abi, :deployment, :events
        def_delegators :parent, :estimate, :deploy, :deploy_and_wait
        def_delegators :parent, :address, :address=, :sender, :sender=
        def_delegator :parent, :call_raw_proxy, :call_raw
        def_delegator :parent, :call_proxy, :call
        def_delegator :parent, :transact_proxy, :transact
        def_delegator :parent, :transact_and_wait_proxy, :transact_and_wait
        def_delegator :parent, :new_filter_proxy, :new_filter
        def_delegator :parent, :get_filter_logs_proxy, :get_filter_logs
        def_delegator :parent, :get_filter_change_proxy, :get_filter_changes
        define_method :parent do
          parent
        end
      end
      Ethereum::Contract.send(:remove_const, class_name) if Ethereum::Contract.const_defined?(class_name, false)
      Ethereum::Contract.const_set(class_name, class_methods)
      @class_object = class_methods
    end

    # Get the list of paths where to look up Truffle artifacts files.
    #
    # @return [Array<String>] Returns the array containing the list of lookup paths.

    def self.truffle_paths()
      @truffle_paths = [] unless @truffle_paths
      @truffle_paths
    end

    # Set the list of paths where to look up Truffle artifacts files.
    #
    # @param paths [Array<String>, nil] The array containing the list of lookup paths; a `nil` value is
    #  converted to the empty array.

    def self.truffle_paths=(paths)
      @truffle_paths = (paths.is_a?(Array)) ? paths : []
    end

    # Looks up and loads a Truffle artifacts file.
    # This method iterates over the `truffle_path` elements, looking for an artifact file in the
    # `build/contracts` subdirectory.
    #
    # @param name [String] The name of the contract whose artifacts to look up.
    # @param paths [Array<String>] An additional list of paths to look up; this list, if present, is
    #  prepended to the `truffle_path`.
    #
    # @return [Hash,nil] Returns a hash containing the parsed JSON from the artifacts file; if no file
    #  was found, returns `nil`.

    def self.find_truffle_artifacts(name, paths = [])
      subpath = File.join('build', 'contracts', "#{name}.json")

      found = paths.concat(truffle_paths).find { |p| File.file?(File.join(p, subpath)) }
      if (found)
        JSON.parse(IO.read(File.join(found, subpath)))
      else
        nil
      end
    end

    private
      def add_gas_options_args(args)
        args[:gas] = @client.int_to_hex(gas_limit) if gas_limit.present?
        args[:gasPrice] = @client.int_to_hex(gas_price) if gas_price.present?
        args
      end

      def create_function_proxies
        parent = self
        call_raw_proxy, call_proxy, transact_proxy, transact_and_wait_proxy = Class.new, Class.new, Class.new, Class.new
        @functions.each do |fun|
          call_raw_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.call_raw(fun, *args) }
          call_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.call(fun, *args) }
          transact_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.transact(fun, *args) }
          transact_and_wait_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.transact_and_wait(fun, *args) }
        end
        @call_raw_proxy, @call_proxy, @transact_proxy, @transact_and_wait_proxy =  call_raw_proxy.new, call_proxy.new, transact_proxy.new, transact_and_wait_proxy.new
      end

      def create_event_proxies
        parent = self
        new_filter_proxy, get_filter_logs_proxy, get_filter_change_proxy = Class.new, Class.new, Class.new
        events.each do |evt|
          new_filter_proxy.send(:define_method, evt.name.underscore) { |*args| parent.create_filter(evt, *args) }
          get_filter_logs_proxy.send(:define_method, evt.name.underscore) { |*args| parent.get_filter_logs(evt, *args) }
          get_filter_change_proxy.send(:define_method, evt.name.underscore) { |*args| parent.get_filter_changes(evt, *args) }
        end
        @new_filter_proxy, @get_filter_logs_proxy, @get_filter_change_proxy = new_filter_proxy.new, get_filter_logs_proxy.new, get_filter_change_proxy.new
      end
  end
end
