module Ethereum
  class Contract

    attr_accessor :code, :name, :functions, :abi, :constructor_inputs, :events

    def initialize(name, code, abi)
      @name = name
      @code = code
      @abi = abi
      @functions = []
      @events = []
      @constructor_inputs = @abi.detect {|x| x["type"] == "constructor"}["inputs"] rescue nil
      @abi.select {|x| x["type"] == "function" }.each do |abifun|
        @functions << Ethereum::Function.new(abifun) 
      end
      @abi.select {|x| x["type"] == "event" }.each do |abievt|
        @events << Ethereum::ContractEvent.new(abievt)
      end
    end

    def build(connection)
      class_name = @name
      functions = @functions
      constructor_inputs = @constructor_inputs
      binary = @code
      events = @events

      class_methods = Class.new do

        define_method "connection".to_sym do
          connection
        end

        define_method :deploy do |*params|
          formatter = Ethereum::Formatter.new
          deploy_code = binary
          deploy_arguments = ""
          if constructor_inputs.present?
            raise "Missing constructor parameter" and return if params.length != constructor_inputs.length
            constructor_inputs.each_index do |i|
              args = [constructor_inputs[i]["type"], params[i]]
              deploy_arguments << formatter.to_payload(args)
            end
          end
          deploy_payload = deploy_code + deploy_arguments
          deploytx = connection.send_transaction({from: self.sender, gas: self.gas, gasPrice: self.gas_price, data: "0x" + deploy_payload})["result"]
          instance_variable_set("@deployment", Ethereum::Deployment.new(deploytx, connection))
        end

        define_method :events do
          return events
        end

        define_method :deployment do
          instance_variable_get("@deployment")
        end

        define_method :deploy_and_wait do |time = 60.seconds, *params|
          self.deploy(*params)
          self.deployment.wait_for_deployment(time)
          instance_variable_set("@address", self.deployment.contract_address)
          self.events.each do |event|
            event.set_address(self.deployment.contract_address)
            event.set_client(connection)
          end
        end

        define_method :at do |addr|
          instance_variable_set("@address", addr) 
          self.events.each do |event|
            event.set_address(addr)
            event.set_client(connection)
          end
        end

        define_method :address do
          instance_variable_get("@address")
        end

        define_method :as do |addr|
          instance_variable_set("@sender", addr)
        end

        define_method :sender do
          instance_variable_get("@sender") || connection.coinbase["result"]
        end

        define_method :set_gas_price do |gp|
          instance_variable_set("@gas_price", gp)
        end

        define_method :gas_price do
          instance_variable_get("@gas_price") || 60000000000
        end

        define_method :set_gas do |gas|
          instance_variable_set("@gas", gas)
        end

        define_method :gas do 
          instance_variable_get("@gas") || 3000000
        end

        events.each do |evt|
          define_method "nf_#{evt.name.underscore}".to_sym do |params = {}|
            params[:to_block] ||= "latest"
            params[:from_block] ||= "0x0"
            params[:address] ||=  instance_variable_get("@address")
            params[:topics] = evt.signature
            payload = {topics: [params[:topics]], fromBlock: params[:from_block], toBlock: params[:to_block], address: params[:address]}
            filter_id = connection.new_filter(payload)
            return filter_id["result"]
          end

          define_method "gfl_#{evt.name.underscore}".to_sym do |filter_id|
            formatter = Ethereum::Formatter.new
            logs = connection.get_filter_logs(filter_id)
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

          define_method "gfc_#{evt.name.underscore}".to_sym do |filter_id|
            formatter = Ethereum::Formatter.new
            logs = connection.get_filter_changes(filter_id)
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

        end

        functions.each do |fun|

          fun_count = functions.select {|x| x.name == fun.name }.count
          derived_function_name = (fun_count == 1) ? "#{fun.name.underscore}" : "#{fun.name.underscore}__#{fun.inputs.collect {|x| x.type}.join("__")}"
          call_function_name = "call_#{derived_function_name}".to_sym
          call_function_name_alias = "c_#{derived_function_name}".to_sym
          call_raw_function_name = "call_raw_#{derived_function_name}".to_sym
          call_raw_function_name_alias = "cr_#{derived_function_name}".to_sym
          transact_function_name = "transact_#{derived_function_name}".to_sym
          transact_function_name_alias = "t_#{derived_function_name}".to_sym
          transact_and_wait_function_name = "transact_and_wait_#{derived_function_name}".to_sym
          transact_and_wait_function_name_alias = "tw_#{derived_function_name}".to_sym

          define_method call_raw_function_name do |*args|
            formatter = Ethereum::Formatter.new
            arg_types = fun.inputs.collect(&:type)
            connection = self.connection
            return {result: :error, message: "missing parameters for #{fun.function_string}" } if arg_types.length != args.length
            payload = []
            payload << fun.signature
            arg_types.zip(args).each do |arg|
              payload << formatter.to_payload(arg)
            end
            raw_result = connection.call({to: self.address, from: self.sender, data: payload.join()})["result"]
            formatted_result = fun.outputs.collect {|x| x.type }.zip(raw_result.gsub(/^0x/,'').scan(/.{64}/))
            output = formatted_result.collect {|x| formatter.from_payload(x) }
            return {data: "0x" + payload.join(), raw: raw_result, formatted: output}
          end

          define_method call_function_name do |*args|
            data = self.send(call_raw_function_name, *args)
            output = data[:formatted]
            if output.length == 1 
              return output[0]
            else 
              return output
            end
          end

          define_method transact_function_name do |*args|
            formatter = Ethereum::Formatter.new
            arg_types = fun.inputs.collect(&:type)
            connection = self.connection
            return {result: :error, message: "missing parameters for #{fun.function_string}" } if arg_types.length != args.length
            payload = []
            payload << fun.signature
            arg_types.zip(args).each do |arg|
              payload << formatter.to_payload(arg)
            end
            txid = connection.send_transaction({to: self.address, from: self.sender, data: "0x" + payload.join(), gas: self.gas, gasPrice: self.gas_price})["result"]
            return Ethereum::Transaction.new(txid, self.connection, payload.join(), args)
          end

          define_method transact_and_wait_function_name do |*args|
            function_name = "transact_#{derived_function_name}".to_sym
            tx = self.send(function_name, *args)
            tx.wait_for_miner
            return tx
          end

          alias_method call_function_name_alias, call_function_name
          alias_method call_raw_function_name_alias, call_raw_function_name
          alias_method transact_function_name_alias, transact_function_name
          alias_method transact_and_wait_function_name_alias, transact_and_wait_function_name

        end
      end
      if Object.const_defined?(class_name)
        Object.send(:remove_const, class_name)
      end
      Object.const_set(class_name, class_methods)
    end

  end
end
