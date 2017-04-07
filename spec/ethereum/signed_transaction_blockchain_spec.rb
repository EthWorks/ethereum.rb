require 'eth'
require 'spec_helper'

describe Ethereum do

  let(:client) { Ethereum::Singleton.instance }
  let(:path) { "#{Dir.pwd}/spec/fixtures/TestContract.sol" }
  let(:private_hex) { "3a9f0de356f75c0af771119c6ada8c6f911d61a07bd3efcf91eedb28bd42e83f" }

  it "deploys with key set value and checks value", blockchain: true do
    contract = Ethereum::Contract.create(file: path)
    contract.key = Eth::Key.new priv: private_hex
    contract.deploy_and_wait("Aloha!")  
    contract.transact_and_wait.set("greeting", "Aloha!")
    expect(contract.call.get("greeting")).to eq ["Aloha!", "żółć"]
  end
end
