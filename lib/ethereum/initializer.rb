module Ethereum

  class Initializer
    attr_accessor :contracts, :file

    def initialize(file)
      @file = File.read(file)
      client = IpcClient.new
      sol_output = client.compile_solidity(@file)
      contracts = sol_output["result"].keys
      @contracts = []
      contracts.each do |contract|
        abi = sol_output["result"][contract]["info"]["abiDefinition"] 
        name = contract
        code = sol_output["result"][contract]["code"]
        @contracts << Ethereum::Contract.new(name, code, abi)
      end
    end

  end
end
