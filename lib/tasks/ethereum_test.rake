namespace :ethereum do

  namespace :node do
    desc "Setup testing environment for ethereum node"
    task :run do
      `parity --chain testnet`
    end
  end

end