module Ethereum

  class Initializer
    attr_accessor :contracts, :file, :client

    def initialize(file, client = Ethereum::Singleton.instance)
      @client = client
      sol_output = Solidity.new.compile(file)
      contracts = sol_output.keys

      @contracts = []
      contracts.each do |contract|
        abi = JSON.parse(sol_output[contract]["abi"] )
        name = contract
        code = sol_output[contract]["bin"]
        @contracts << Contract.new(name, code, abi)
      end
    end

    def build_all
      @contracts.each do |contract|
        contract.build(@client)
      end
    end

  end
end
