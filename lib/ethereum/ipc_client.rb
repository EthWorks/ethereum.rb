require 'socket'
require 'active_support'
require 'active_support/core_ext'
module Ethereum
  class IpcClient
    attr_accessor :command, :id, :ipcpath, :batch, :converted_transactions

    def initialize
      @ipcpath = "/Users/aeufemio/.ethereum_testnet/geth.ipc"
      @id = 1
      @batch = []
    end

    def get_id
      @id = @id + 1
      return @id
    end

    RPC_COMMANDS = %w(eth_accounts eth_blockNumber eth_getBalance eth_protocolVersion eth_coinbase eth_mining eth_gasPrice eth_getStorage eth_storageAt eth_getStorageAt eth_getTransactionCount eth_getBlockTransactionCountByHash eth_getBlockTransactionCountByNumber eth_getUncleCountByBlockHash eth_getUncleCountByBlockNumber eth_getData eth_getCode eth_sign eth_sendRawTransaction eth_sendTransaction eth_transact eth_estimateGas eth_call eth_flush eth_getBlockByHash eth_getBlockByNumber eth_getTransactionByHash eth_getTransactionByBlockNumberAndIndex eth_getTransactionByBlockHashAndIndex eth_getUncleByBlockHashAndIndex eth_getUncleByBlockNumberAndIndex eth_getCompilers eth_compileSolidity eth_newFilter eth_newBlockFilter eth_newPendingTransactionFilter eth_uninstallFilter eth_getFilterChanges eth_getFilterLogs eth_getLogs eth_hashrate eth_getWork eth_submitWork eth_resend eth_pendingTransactions eth_getTransactionReceipt)

    RPC_COMMANDS.each do |rpc_command|
      method_name = "#{rpc_command.split("_")[1].underscore}"
      define_method method_name do |*args|
        command = rpc_command
        payload = {jsonrpc: "2.0", method: command, params: args, id: get_id}
        socket = UNIXSocket.new(@ipcpath)
        socket.write(payload.to_json)
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

    def clear_batch
      @batch = []
    end

  end
end

