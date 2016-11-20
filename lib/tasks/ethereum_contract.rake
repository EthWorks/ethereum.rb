namespace :ethereum do
  namespace :contract do

    desc "Compile a contract"
    task :compile, [:path] do |t, args|
      contract = Ethereum::Solidity.new.compile(args[:path])
      puts "Contract abi:"
      puts contract["Works"]["abi"]
      puts
      puts "Contract binary code:"
      puts contract["Works"]["bin"]
      puts
    end

    desc "Compile and deploy contract"
    task :compile, [:path] do |t, args|
      puts "Deploing contract"
      @works = Ethereum::Contract.from_file(args[:path], @client)
      @works.deploy_and_wait(&block) { puts "." }
      address = @works.deployment.contract_address
      puts "Contract deployed under address: #{address}"
    end

  end
end
