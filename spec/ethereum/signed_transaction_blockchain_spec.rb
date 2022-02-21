require 'spec_helper'

describe Ethereum do

  let(:client) { Ethereum::Singleton.instance }
  let(:path) { "#{Dir.pwd}/spec/fixtures/TestContract.sol" }
  let(:private_hex) { "3a9f0de356f75c0af771119c6ada8c6f911d61a07bd3efcf91eedb28bd42e83f" }
  let(:key) { Eth::Key.new priv: private_hex }
  let(:amount) { 1000_000_000_000_000 }

  it "deploys with key set value and checks value", blockchain: true do
    client.transfer_to_and_wait(key.address, 1000_000_000_000_000_000)
    contract = Ethereum::Contract.create(file: path)
    contract.key = key
    contract.deploy_and_wait("Aloha!")
    contract.transact_and_wait.set("greeting", "Aloha!")
    expect(contract.call.get("greeting")).to eq ["Aloha!", "żółć"]
  end

  it "transfers ether", blockchain: true do
    client.transfer_to_and_wait(key.address, 1000_000_000_000_000_000)
    balance_before = client.get_balance(key.address)
    client.transfer_and_wait(key, "0x27DCB234FAb8190e53E2d949d7b2C37411eFB72e", amount)
    balance_after = client.get_balance(key.address)
    expect(balance_after).to be < (balance_before - amount)
  end

end
