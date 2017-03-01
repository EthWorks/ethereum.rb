module Ethereum

  class Railtie < Rails::Railtie
    rake_tasks do
      load('tasks/ethereum_test.rake')
      load('tasks/ethereum_node.rake')
      load('tasks/ethereum_contract.rake')
      load('tasks/ethereum_transaction.rake')
    end
  end

end