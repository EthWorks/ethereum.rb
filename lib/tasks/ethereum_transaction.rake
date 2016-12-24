require 'pp'
require File.expand_path("../../ethereum.rb", __FILE__)

namespace :ethereum do
  namespace :transaction do

    desc "Get info about transaction"
    task :byhash, [:id] do |t, args|
      @client = Ethereum::Singleton.instance
      pp @client.eth_get_transaction_by_hash((args[:id]))
    end

  end
end
