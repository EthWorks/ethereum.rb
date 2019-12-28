require 'open3'

namespace :ethereum do
  namespace :node do

    desc "Run testnet (goerli) node"
    task :test do
      args = "--chain testnet"
      out, _, _ = Open3.capture3("parity #{args} account list")
      account = out.split(/[\[\n\]]/)[0]
      cmd = "parity #{args} --password ~/Library/Application\\ Support/io.parity.ethereum/pass --unlock #{account} --author #{account}"
      puts cmd
      system cmd
    end

    desc "Run production node"
    task :run do
      _, out, _ = Open3.capture3("parity account list")
      account = out.split(/[\[,\]]/)[1]
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
        loop do
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
