module Ethereum

  class ProjectInitializer

    attr_accessor :contract_names, :combined_output, :contracts

    def initialize(location)
      ENV['ETHEREUM_SOLIDITY_BINARY'] ||= "/usr/local/bin/solc"
      solidity = ENV['ETHEREUM_SOLIDITY_BINARY']
      contract_dir = location
      compile_command = "#{solidity} --combined-json abi,bin #{contract_dir}"
      raw_data = `#{compile_command}`
      data = JSON.parse(raw_data)
      @contract_names = data["contracts"].keys
      @contracts = @contract_names.collect do |contract_name|
        ContractInitializer.new(contract_name, data["contracts"][contract_name])
      end
    end

  end

end
