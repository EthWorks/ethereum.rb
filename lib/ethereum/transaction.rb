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

    def mined?
      return true if @mined
      @mined = @connection.get_transaction_by_hash(@id)["result"]["blockNumber"].present?
    end

    def wait_for_miner(timeout = 1500.seconds)
      start_time = Time.now
      while self.mined? == false
        raise Timeout::Error if ((Time.now - start_time) > timeout)
        sleep 5
        return true if self.mined?
      end
    end

  end

end
