require 'open3'

namespace :ethereum do
  namespace :node do

    desc "Run testnet node "
    task :test do
      stdout, stdeerr, status = Open3.capture3("parity --chain testnet account list")
      account = stdeerr.split(/[\[,\]]/)[1]
      cmd = "parity --chain ~/.parity/ropsten.json --password ~/.parity/pass --unlock #{account} --author #{account}"
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

  end
end