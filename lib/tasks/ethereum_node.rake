require 'open3'

namespace :ethereum do
  namespace :node do

    desc "Run testnet node "
    task :test do
      stdout, stdeerr, status = Open3.capture3("parity --chain testnet account list")
      account = stdeerr.split(/[\[,\]]/)[1]
      system "parity --chain testnet --password ~/.parity/pass --unlock #{account}"
    end

    desc "Run morden (production) node"
    task :test do
      stdout, stdeerr, status = Open3.capture3("parity account list")
      account = stdeerr.split(/[\[,\]]/)[1]
      system "parity --password ~/.parity/pass --unlock #{account}"
    end

  end
end