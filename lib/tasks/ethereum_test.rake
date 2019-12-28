namespace :ethereum do
  namespace :test do

    desc "Setup testing environment for ethereum node"
    task :setup do
      @client = Ethereum::Singleton.instance

      network_id = @client.net_version["result"].to_i
      raise "Error: Run your tests on goerli testnet. Use rake ethereum:node:test to run node. Net id: #{network_id}" if network_id != 5

      accounts = @client.eth_accounts["result"]
      if accounts.size > 0
        puts "Account already exist, skipping this step"
      else
        puts "Creating account..."
        `parity --chain testnet account new`
      end

      balance = @client.eth_get_balance(@client.default_account)["result"]
      formatter = Ethereum::Formatter.new
      balance = formatter.to_int(balance)
      balance = formatter.from_wei(balance).to_f

      if balance.to_f > 0.02
        puts "Done. You're ready to run tests.\nTests will use ether from account: #{@client.default_account} with #{balance} ether"
      else
        puts "Not enough ether to run tests. \nYou have: #{balance} ether. \nYou need at least 0.02 ether to run tests.\nTransfer ether to account: #{@client.default_account}.\nThe easiest way to get ether is to use Ethereum Testnet Faucet."
      end
    end

  end
end
