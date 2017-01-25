module Ethereum
  class Contract

    attr_accessor :code, :name, :functions, :abi, :constructor_inputs, :events, :class_object, :sender, :address, :deployment, :client

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
    end

    def self.from_file(path, client = Ethereum::Singleton.instance)
      @init = Ethereum::Initializer.new(path, client)
      contracts = @init.build_all
      raise "No contracts complied" if contracts.empty?
      contracts.first.class_object.new
    end

    def self.from_code(name, code, abi_string, client = Ethereum::Singleton.instance)
      contract = Ethereum::Contract.new(name, code, JSON.parse(abi_string), client)
      contract.build(client)
      contract_instance = contract.class_object.new
      contract_instance
    end

    def self.from_blockchain(name, address, abi, client = Ethereum::Singleton.instance)
      contract = Ethereum::Contract.new(name, nil, abi)
      contract.build(client)
      contract_instance = contract.class_object.new
      contract_instance.at address
      contract_instance
    end

    def deploy(*params)
      if @constructor_inputs.present?
        raise "Missing constructor parameter" and return if params.length != @constructor_inputs.length
      end
      deploy_arguments = @formatter.construtor_params_to_payload(@constructor_inputs, params)
      payload = "0x" + @code + deploy_arguments
      tx = @client.eth_send_transaction({from: sender, data: payload})["result"]
      raise "Failed to deploy, did you unlock #{sender} account? Transaction hash: #{deploytx}" if tx.nil? || tx == "0x0000000000000000000000000000000000000000000000000000000000000000"
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

    def call_raw(fun, *args)
      arg_types = fun.inputs.collect(&:type)
      return {result: :error, message: "missing parameters for #{fun.function_string}" } if arg_types.length != args.length
      payload = [fun.signature]
      arg_types.zip(args).each do |arg|
        payload << @formatter.to_payload(arg)
      end
      raw_result = @client.eth_call({to: @address, from: @sender, data: "0x" + payload.join()})
      raw_result = raw_result["result"]
      output = @decoder.decode_arguments(fun.outputs, raw_result)
      return {data: "0x" + payload.join(), raw: raw_result, formatted: output}
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
      arg_types = fun.inputs.collect(&:type)
      return {result: :error, message: "missing parameters for #{fun.function_string}" } if arg_types.length != args.length
      payload = []
      payload << fun.signature
      arg_types.zip(args).each do |arg|
        payload << @formatter.to_payload(arg)
      end
      txid = @client.eth_send_transaction({to: @address, from: @sender, data: "0x" + payload.join()})["result"]
      return Ethereum::Transaction.new(txid, @client, payload.join(), args)
    end

    def transact_and_wait(fun, *args)
      tx = transact(fun, *args)
      tx.wait_for_miner
      return tx
    end

    def estimate(*params)
      deploy_arguments = ""
      if @constructor_inputs.present?
        raise "Wrong number of arguments in a constructor" and return if params.length != @constructor_inputs.length
        @constructor_inputs.each_index do |i|
          args = [@constructor_inputs[i]["type"], params[i]]
          deploy_arguments << @formatter.to_payload(args)
        end
      end
      deploy_payload = @code + deploy_arguments
      result = @client.eth_estimate_gas({from: @sender, data: "0x" + deploy_payload})
      @decoder.decode_int(result["result"])
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

    def create_function_proxies
      functions = @functions
      parent = self
      call_raw_proxy = Class.new
      call_proxy = Class.new
      transact_proxy = Class.new
      transact_and_wait_proxy = Class.new
      functions.each do |fun|
        call_raw_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.call_raw(fun, *args) }
        call_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.call(fun, *args) }
        transact_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.transact(fun, *args) }
        transact_and_wait_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.transact_and_wait(fun, *args) }
      end
      [call_raw_proxy.new, call_proxy.new, transact_proxy.new, transact_and_wait_proxy.new]
    end

    def build(connection)
      class_name = @name.camelize
      functions = @functions
      events = @events
      parent = self
      call_raw_proxy, call_proxy, transact_proxy, transact_and_wait_proxy = create_function_proxies

      class_methods = Class.new do

        extend Forwardable

        def_delegators :parent, :abi, :deployment
        def_delegators :parent, :estimate, :deploy, :deploy_and_wait
        def_delegators :parent, :address, :address=, :sender, :sender=

        define_method :call_raw do
          call_raw_proxy
        end

        define_method :call do
          call_proxy
        end

        define_method :transact do
          transact_proxy
        end

        define_method :transact_and_wait do
          transact_and_wait_proxy
        end

        define_method :parent do
          parent
        end

        define_method "connection".to_sym do
          connection
        end

        define_method :events do
          return events
        end

        define_method :at do |addr|
          parent.address = addr
          self.events.each do |event|
            event.set_address(addr)
            event.set_client(connection)
          end
        end

        events.each do |evt|
          define_method "nf_#{evt.name.underscore}".to_sym do |params = {}|
            parent.create_filter(evt, **params)
          end

          define_method "gfl_#{evt.name.underscore}".to_sym do |filter_id|
            parent.get_filter_logs(evt, filter_id)
          end

          define_method "gfc_#{evt.name.underscore}".to_sym do |filter_id|
            parent.get_filter_changes(evt, filter_id)
          end

        end
      end
      if Object.const_defined?(class_name)
        Object.send(:remove_const, class_name)
      end
      Object.const_set(class_name, class_methods)
      @class_object = class_methods
    end

  end
end
