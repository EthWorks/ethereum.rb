namespace :ethereum do
  namespace :contract do

    desc "Compile"
    task :compile, [:path] do |t, args|
      contract = Ethereum::Solidity.new.compile(args[:path])
      puts "Contract abi:"
      puts contract["Works"]["abi"]
      puts
      puts "Contract binary code:"
      puts contract["Works"]["bin"]
      puts
    end

  end
end