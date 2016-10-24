module Ethereum

  class Deployment

    attr_accessor :id, :contract_address, :connection, :deployed, :mined, :valid_deployment

    def initialize(txid, connection)
      @id = txid
      @connection = connection
      @deployed = false
      @contract_address = nil
      @valid_deployment = false
    end

    def mined?
      return true if @mined
      @mined = @connection.get_transaction_by_hash(@id)["result"]["blockNumber"].present? rescue nil
      @mined ||= false
    end

    def has_address?
      return true if @contract_address.present?
      return false unless self.mined? 
      @contract_address ||= @connection.get_transaction_receipt(@id)["result"]["contractAddress"] 
      return @contract_address.present?
    end

    def deployed?
      return true if @valid_deployment
      return false unless self.has_address?
      @valid_deployment = @connection.get_code(@contract_address)["result"] != "0x"
    end

    def wait_for_deployment2(timeout = 1500.seconds)
      start_time = Time.now
      while self.deployed? == false
        raise "Transaction #{@id} timed out." if ((Time.now - start_time) > timeout) 
        sleep 5 
        return true if self.deployed? 
      end
    end

    def wait_for_deployment(timeout = 1500.seconds)
      start_time = Time.now
      while true
        raise "Transaction #{@id} timed out." if ((Time.now - start_time) > timeout) 
        sleep 5 
        puts "id: #{@id}"
        contract_receipt = @connection.eth_get_transaction_receipt(@id)
        puts "contract_receipt: #{contract_receipt}"
        return true if contract_receipt["result"] && contract_receipt["result"]["contractAddress"] 
      end
    end


  end

end
