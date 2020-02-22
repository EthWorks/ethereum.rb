module Ethereum

  class Transaction

    DEFAULT_TIMEOUT = 300.seconds
    DEFAULT_STEP = 5.seconds

    attr_accessor :id, :mined, :connection, :input, :input_parameters

    def initialize(id, connection, data, input_parameters = [])
      @mined = false
      @connection = connection
      @id = id
      @input = data
      @input_parameters = input_parameters
    end

    def address
      @id
    end

    def mined?
      return true if @mined
      tx = @connection.eth_get_transaction_by_hash(@id)
      @mined = !tx.nil? && !tx["result"].nil? && tx["result"]["blockNumber"].present?
    end

    def wait_for_miner(timeout: DEFAULT_TIMEOUT, step: DEFAULT_STEP)
      start_time = Time.now
      loop do
        raise Timeout::Error if ((Time.now - start_time) > timeout)
        return true if self.mined?
        sleep step
      end
    end

    def self.from_blockchain(address, connection = IpcClient.new)
      Transaction.new(address, connection, nil, nil)
    end
  end
end
