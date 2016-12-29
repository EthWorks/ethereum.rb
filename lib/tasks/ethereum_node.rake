require 'open3'

namespace :ethereum do
  namespace :node do

    desc "Run testnet node "
    task :test do
      stdout, stdeerr, status = Open3.capture3("parity --chain ~/.parity/ropsten.json account list")
      account = stdeerr.split(/[\[,\]]/)[1]
      cmd = "parity --chain ~/.parity/ropsten.json --password ~/.parity/pass --unlock #{account} --author #{account} daemon ~/.parity.pid"
      puts cmd
      system cmd
    end

    desc "Run morden (production) node"
    task :run do
      stdout, stdeerr, status = Open3.capture3("parity account list")
      account = stdeerr.split(/[\[,\]]/)[1]
      system "parity --password ~/.parity/pass --unlock #{account}  --author #{account} --no-jsonrpc"
    end

    desc "Mine ethereum testing environment for ethereum node"
    task :mine do
        cmd = "ethminer"
        puts cmd
        system cmd
    end

    desc "Check if node is syncing"
    task :waitforsync do
      formatter = Ethereum::Formatter.new
      begin
        while (1) do
           result = Ethereum::Singleton.instance.eth_syncing["result"]
           unless result
             puts "Synced"
             break
           else
             current = formatter.to_int(result["currentBlock"])
             highest = formatter.to_int(result["highestBlock"])
             puts "Syncing block: #{current}/#{highest}"
           end
           sleep 5
        end
      rescue
        puts "Ethereum node not running?"
      end
    end

  end
end