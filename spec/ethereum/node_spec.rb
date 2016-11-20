require 'spec_helper'

describe "Ethereum Node" do

  before(:all) do
    @client = Ethereum::IpcClient.new
    @formatter = Ethereum::Formatter.new
  end

  it 'has supported JSON RPC version' do
    expect(@client.eth_protocol_version["jsonrpc"]).to eq "2.0"
  end

  it 'has suported Ethereum version' do
    expect(@client.eth_protocol_version["result"]).to eq "63"
  end

  it 'has at least one account' do
    expect(@client.eth_accounts.size).to be > 0
  end

  it 'has coinbase' do
    expect(@client.eth_coinbase).to be_truthy
  end

end