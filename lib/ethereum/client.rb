module Ethereum
  class Client

    RPC_COMMANDS = %w(personal_newAccount personal_unlockAccount eth_accounts eth_blockNumber eth_getBalance eth_protocolVersion eth_coinbase eth_mining eth_gasPrice eth_getStorage eth_storageAt eth_getStorageAt eth_getTransactionCount eth_getBlockTransactionCountByHash eth_getBlockTransactionCountByNumber eth_getUncleCountByBlockHash eth_getUncleCountByBlockNumber eth_getData eth_getCode eth_sign eth_sendRawTransaction eth_sendTransaction eth_transact eth_estimateGas eth_call eth_flush eth_getBlockByHash eth_getBlockByNumber eth_getTransactionByHash eth_getTransactionByBlockNumberAndIndex eth_getTransactionByBlockHashAndIndex eth_getUncleByBlockHashAndIndex eth_getUncleByBlockNumberAndIndex eth_getCompilers eth_compileSolidity eth_newFilter eth_newBlockFilter eth_newPendingTransactionFilter eth_uninstallFilter eth_getFilterChanges eth_getFilterLogs eth_getLogs eth_hashrate eth_getWork eth_submitWork eth_resend eth_pendingTransactions eth_getTransactionReceipt)

    def get_id
      @id = @id + 1
      return @id
    end

    def clear_batch
      @batch = []
    end

  end

end

