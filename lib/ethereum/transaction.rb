module Ethereum

  class Transaction
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
      @mined = @connection.eth_get_transaction_by_hash(@id)["result"]["blockNumber"].present?
    end

    def wait_for_miner(timeout = 1500.seconds)
      start_time = Time.now
      loop do
        raise Timeout::Error if ((Time.now - start_time) > timeout)
        return true if self.mined?
        sleep 5
      end
    end

    def self.from_blockchain(address, connection = IpcClient.new)
      Transaction.new(address, connection, nil, nil)
    end
  end
end 
