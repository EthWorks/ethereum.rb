module Ethereum

  class ContractInitializer

    attr_accessor :abi, :binary, :name, :libraries, :needs_linking, :project_initializer

    def initialize(contract_name, contract, project_initializer)
      @abi = JSON.parse(contract["abi"]) unless contract.nil?
      @binary = contract["bin"] unless contract.nil?
      @name = contract_name
      @project_initializer = project_initializer
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
          name = library[:name]
          if @project_initializer.libraries[name].nil?
            ENV['ETHEREUM_DEPLOYER_WAIT_TIME'] ||= "120"
            wait_time = ENV['ETHEREUM_DEPLOYER_WAIT_TIME'].to_i
            library_instance = library[:name].constantize.new
            puts "Deploying library #{name}"
            library_instance.deploy_and_wait(wait_time)
            puts "Library deployed at #{library_instance.address}"
            @project_initializer.libraries[name] = library_instance.address
            @binary.gsub!(library[:sigil], library_instance.address.gsub(/^0x/,''))
          else
            address = @project_initializer.libraries[name]
            @binary.gsub!(library[:sigil], address.gsub(/^0x/,''))
          end
        end
      end
    end

    def build(connection)
      contract = Ethereum::Contract.new(@name, @binary, @abi) 
      contract.build(connection)
    end

  end

end
