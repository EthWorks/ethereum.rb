require 'spec_helper'

describe Ethereum do
  describe 'HttpClient' do
    it 'should work' do
      client = Ethereum::HttpClient.new('localhost', '8545')
      expect(client.eth_accounts['error']).to eq(nil)
    end
  end

  describe 'IpcClient' do
    it 'should work' do
      client = Ethereum::IpcClient.new("#{ENV['HOME']}/EtherDev/data/geth.ipc")
      expect(client.eth_accounts['error']).to eq(nil)
    end
  end
end
