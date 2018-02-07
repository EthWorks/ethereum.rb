require 'spec_helper'

describe Ethereum::Contract do

  let(:client) { Ethereum::IpcClient.new }
  let(:path) { "#{Dir.pwd}/spec/fixtures/TestContract.sol" }

  it "namespaces the generated contract class" do
    @works = Ethereum::Contract.create(file: path, client: client)
    expect(@works.parent.class_object.to_s).to eq("Ethereum::Contract::TestContract")
  end

end
