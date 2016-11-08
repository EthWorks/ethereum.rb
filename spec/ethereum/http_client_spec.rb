require 'spec_helper'

describe Ethereum do

  describe 'HttpClient' do
    it 'should be able to connect' do
      client = Ethereum::HttpClient.new('http://localhost:8545')
      expect(client.eth_protocol_version).to be_instance_of Hash
    end
  end

end
