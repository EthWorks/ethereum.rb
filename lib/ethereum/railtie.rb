module Ethereum

  class Railtie < Rails::Railtie
    rake_tasks do
      load('tasks/ethereum_test.rake')
      load('tasks/ethereum_node.rake')
    end
  end

end