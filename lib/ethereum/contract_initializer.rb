module Ethereum

  class ContractInitializer

    attr_accessor :abi, :binary, :name, :libraries, :needs_linking

    def initialize(contract_name, contract)
      @abi = JSON.parse(contract["abi"]) unless contract.nil?
      @binary = contract["bin"] unless contract.nil?
      @name = contract_name
      matchdata = /_+[a-zA-Z]+_+/.match(@binary)
      @needs_linking = matchdata.present?
      if @needs_linking
        @libraries = matchdata.to_a.collect do |libname|
          {name: libname.gsub(/_+/,''), sigil: libname}
        end
      end
    end

    def link_libraries
      if @needs_linking
        @libraries.each do |library|
          ENV['ETHEREUM_DEPLOYER_WAIT_TIME'] ||= "120"
          wait_time = ENV['ETHEREUM_DEPLOYER_WAIT_TIME'].to_i
          library_instance = library[:name].constantize.new
          library_instance.deploy_and_wait(wait_time)
          @binary.gsub!(library[:sigil], library_instance.address.gsub(/^0x/,''))
        end
      end
    end

    def build(connection)
      contract = Ethereum::Contract.new(@name, @binary, @abi) 
      contract.build(connection)
    end

  end

end
