module Ethereum

  class Deployment

    DEFAULT_TIMEOUT = 300.seconds
    DEFAULT_STEP = 5.seconds

    attr_accessor :id, :contract_address, :connection, :deployed, :mined
    attr_reader :valid_deployment

    def initialize(txid, connection)
      @id = txid
      @connection = connection
      @deployed = false
      @contract_address = nil
      @valid_deployment = false
    end

    def mined?
      return true if @mined
      @mined = @connection.eth_get_transaction_by_hash(@id)["result"]["blockNumber"].present?
      @mined ||= false
    end

    def check_deployed
      return false unless @id
      contract_receipt = @connection.eth_get_transaction_receipt(@id)
      result = contract_receipt["result"]
      has_contract_address = result && result["contractAddress"]
      @contract_address ||= result["contractAddress"] if has_contract_address
      has_contract_address && result["blockNumber"]
    end

    def deployed?
      @valid_deployment ||= check_deployed
    end

    def wait_for_deployment(timeout: DEFAULT_TIMEOUT, step: DEFAULT_STEP)
      start_time = Time.now
      loop do
        raise "Transaction #{@id} timed out." if ((Time.now - start_time) > timeout) 
        yield if block_given?
        return true if deployed?
        sleep step
      end
    end

  end
end
