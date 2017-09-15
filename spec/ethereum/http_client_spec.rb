require 'spec_helper'

describe Ethereum::HttpClient do

  subject { Ethereum::HttpClient.new('http://localhost:8545') }
  let (:version) { subject.eth_protocol_version["result"] }

  it 'is able to connect' do
    expect(version).to be_instance_of String
  end

  it 'should support batching' do
    response = subject.batch do
      subject.net_listening
      subject.eth_block_number
    end

    expect(response).to be_a Array
    expect(response.length).to eq 2
    expect(response.first['result']).to be_in [true, false]
    expect(response.last['result']).to match /(0x)?[0-9a-f]+/i
  end

end
