require 'pp'
require File.expand_path("../../ethereum.rb", __FILE__)

namespace :ethereum do
  namespace :transaction do

    desc "Get info about transaction"
    task :byhash, [:id] do |_, args|
      @client = Ethereum::Singleton.instance
      pp @client.eth_get_transaction_by_hash(args[:id])
    end

    desc "Send"
    task :send, [:address, :amount] do |_, args|
      @client = Ethereum::Singleton.instance
      @formatter = Ethereum::Formatter.new
      address = @formatter.to_address(args[:address])
      value = @client.int_to_hex(@formatter.to_wei(args[:amount].to_f))
      puts "Transfer from: #{@client.default_account} to: #{address}, amount: #{value}wei"
      pp @client.eth_send_transaction({from: @client.default_account, to: address, value: value})
    end

  end
end
