module Ethereum

  class ProjectInitializer

    attr_accessor :contract_names, :combined_output, :contracts, :libraries

    def initialize(location, optimize = false)
      ENV['ETHEREUM_SOLIDITY_BINARY'] ||= "/usr/local/bin/solc"
      solidity = ENV['ETHEREUM_SOLIDITY_BINARY']
      contract_dir = location
      if optimize 
        opt_flag = "--optimize"
      else
        opt_flag = ""
      end
      compile_command = "#{solidity} #{opt_flag} --combined-json abi,bin #{contract_dir}"
      raw_data = `#{compile_command}`
      data = JSON.parse(raw_data)
      @contract_names = data["contracts"].keys
      @libraries = {} 
      @contracts = @contract_names.collect do |contract_name|
        ContractInitializer.new(contract_name, data["contracts"][contract_name], self)
      end
    end

  end

end
