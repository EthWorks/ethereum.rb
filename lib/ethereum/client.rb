module Ethereum
  class Client
    # https://github.com/ethereum/wiki/wiki/JSON-RPC
    RPC_COMMANDS = %w(web3_clientVersion web3_sha3 net_version net_peerCount net_listening eth_protocolVersion eth_syncing eth_coinbase eth_mining eth_hashrate eth_gasPrice eth_accounts eth_blockNumber eth_getBalance eth_getStorageAt eth_getTransactionCount eth_getBlockTransactionCountByHash eth_getBlockTransactionCountByNumber eth_getUncleCountByBlockHash eth_getUncleCountByBlockNumber eth_getCode eth_sign eth_sendTransaction eth_sendRawTransaction eth_call eth_estimateGas eth_getBlockByHash eth_getBlockByNumber eth_getTransactionByHash eth_getTransactionByBlockHashAndIndex eth_getTransactionByBlockNumberAndIndex eth_getTransactionReceipt eth_getUncleByBlockHashAndIndex eth_getUncleByBlockNumberAndIndex eth_getCompilers eth_compileLLL eth_compileSolidity eth_compileSerpent eth_newFilter eth_newBlockFilter eth_newPendingTransactionFilter eth_uninstallFilter eth_getFilterChanges eth_getFilterLogs eth_getLogs eth_getWork eth_submitWork eth_submitHashrate db_putString db_getString db_putHex db_getHex shh_post shh_version shh_newIdentity shh_hasIdentity shh_newGroup shh_addToGroup shh_newFilter shh_uninstallFilter shh_getFilterChanges shh_getMessages)
    # https://github.com/ethereum/go-ethereum/wiki/Management-APIs
    RPC_MANAGEMENT_COMMANDS = %w(admin_addPeer admin_datadir admin_nodeInfo admin_peers admin_setSolc admin_startRPC admin_startWS admin_stopRPC admin_stopWS debug_backtraceAt debug_blockProfile debug_cpuProfile debug_dumpBlock debug_gcStats debug_getBlockRlp debug_goTrace debug_memStats debug_seedHash debug_setHead debug_setBlockProfileRate debug_stacks debug_startCPUProfile debug_startGoTrace debug_stopCPUProfile debug_stopGoTrace debug_traceBlock debug_traceBlockByNumber debug_traceBlockByHash debug_traceBlockFromFile debug_traceTransaction debug_verbosity debug_vmodule debug_writeBlockProfile debug_writeMemProfile miner_hashrate miner_makeDAG miner_setExtra miner_setGasPrice miner_start miner_startAutoDAG miner_stop miner_stopAutoDAG personal_importRawKey personal_listAccounts personal_lockAccount personal_newAccount personal_unlockAccount personal_sendTransaction txpool_content txpool_inspect txpool_status)

    attr_accessor :command, :id, :log, :logger

    def initialize(log = false)
      @id = 0
      @log = log
      @batch = nil

      if @log == true
        @logger = Logger.new("/tmp/ethereum_ruby_http.log")
      end
    end

    def batch
      @batch = []

      yield
      result = send_batch(@batch)

      @batch = nil
      reset_id

      return result
    end

    def get_id
      @id += 1
      return @id
    end

    def reset_id
      @id = 0
    end

    (RPC_COMMANDS + RPC_MANAGEMENT_COMMANDS).each do |rpc_command|
      method_name = "#{rpc_command.underscore}"
      define_method method_name do |*args|
        command = rpc_command
        if command == "eth_call"
          args << "latest"
        end
        payload = {jsonrpc: "2.0", method: command, params: args, id: get_id}
        if @log == true
          @logger.info("Sending #{payload.to_json}")
        end

        if @batch
          @batch << payload
          return true
        else
          read = send_single(payload.to_json)
          output = JSON.parse(read)
          reset_id
          return output
        end
      end
    end

  end

end

