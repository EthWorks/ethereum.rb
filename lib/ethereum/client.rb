module Ethereum
  class Client

    RPC_COMMANDS = %w(personal_newAccount personal_unlockAccount eth_accounts eth_blockNumber eth_getBalance eth_protocolVersion eth_coinbase eth_mining eth_gasPrice eth_getStorage eth_storageAt eth_getStorageAt eth_getTransactionCount eth_getBlockTransactionCountByHash eth_getBlockTransactionCountByNumber eth_getUncleCountByBlockHash eth_getUncleCountByBlockNumber eth_getData eth_getCode eth_sign eth_sendRawTransaction eth_sendTransaction eth_transact eth_estimateGas eth_call eth_flush eth_getBlockByHash eth_getBlockByNumber eth_getTransactionByHash eth_getTransactionByBlockNumberAndIndex eth_getTransactionByBlockHashAndIndex eth_getUncleByBlockHashAndIndex eth_getUncleByBlockNumberAndIndex eth_getCompilers eth_compileSolidity eth_newFilter eth_newBlockFilter eth_newPendingTransactionFilter eth_uninstallFilter eth_getFilterChanges eth_getFilterLogs eth_getLogs eth_hashrate eth_getWork eth_submitWork eth_resend eth_pendingTransactions eth_getTransactionReceipt)

    attr_accessor :command, :id, :batch, :log, :logger

    def initialize(log = false)
      @id = 0
      @batch = []
      @log = log

      if @log == true
        @logger = Logger.new("/tmp/ethereum_ruby_http.log")
      end
    end

    def get_id
      @id = @id + 1
      return @id
    end

    def clear_batch
      @batch = []
    end

    RPC_COMMANDS.each do |rpc_command|
      method_name = "#{rpc_command.split("_")[1].underscore}"
      define_method method_name do |*args|
        command = rpc_command
        if command == "eth_call"
          args << "latest"
        end
        payload = {jsonrpc: "2.0", method: command, params: args, id: get_id}.to_json
        if @log == true
          @logger.info("Sending #{payload}")
        end
        read = send_single(payload)
        output = JSON.parse(read)
        return output
      end

      define_method "#{method_name}_batch" do |*args|
        command = rpc_command
        payload = {jsonrpc: "2.0", method: command, params: args, id: get_id}
        @batch << payload.to_json
      end
    end

  end

end

