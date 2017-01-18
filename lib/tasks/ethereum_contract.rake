require File.expand_path("../../ethereum.rb", __FILE__)

namespace :ethereum do
  namespace :contract do

    desc "Compile a contract"
    task :compile, [:path] do |_, args|
      contract = Ethereum::Solidity.new.compile(args[:path])
      puts "Contract abi:"
      puts contract["Works"]["abi"]
      puts
      puts "Contract binary code:"
      puts contract["Works"]["bin"]
      puts
    end

    desc "Compile and deploy contract"
    task :deploy, [:path] do |_, args|
      puts "Deploing contract #{args[:path]}"
      @works = Ethereum::Contract.from_file(args[:path])
      @works.deploy_and_wait { puts "." }
      address = @works.deployment.contract_address
      puts "Contract deployed under address: #{address}"
    end

  end
end
