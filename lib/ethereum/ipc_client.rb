require 'socket'
module Ethereum
  class IpcClient < Client
    attr_accessor :command, :id, :ipcpath, :batch, :converted_transactions, :log, :logger

    def initialize(ipcpath = "#{ENV['HOME']}/.ethereum/geth.ipc", log = true)
      @ipcpath = ipcpath
      @id = 1
      @batch = []
      @log = log
      if @log == true
        @logger = Logger.new("/tmp/ethereum_ruby_ipc.log")
      end
    end

    RPC_COMMANDS.each do |rpc_command|
      method_name = "#{rpc_command.split("_")[1].underscore}"
      define_method method_name do |*args|
        command = rpc_command
        if command == "eth_call"
          args << "latest"
        end
        payload = {jsonrpc: "2.0", method: command, params: args, id: get_id}
        socket = UNIXSocket.new(@ipcpath)
        socket.write(payload.to_json)
        if @log == true
          @logger.info("Sending #{payload.to_json}")
        end
        socket.close_write
        read = socket.read
        socket.close_read
        output = JSON.parse(read)
        return output
      end

      define_method "#{method_name}_batch" do |*args|
        command = rpc_command
        payload = {jsonrpc: "2.0", method: command, params: args, id: get_id}
        @batch << payload.to_json
      end
    end

    def send_batch
      socket = UNIXSocket.new(@ipcpath)
      socket.write(@batch.join(" "))
      socket.close_write
      read = socket.read
      collection = read.chop.split("}{").collect do |output|
        if output[0] == "{"
          JSON.parse("#{output}}")["result"]
        else
          JSON.parse("{#{output}}")["result"]
        end
      end
      return collection
    end

  end
end

