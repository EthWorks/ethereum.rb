require 'spec_helper'

describe Ethereum::HttpClient do

  subject { Ethereum::HttpClient.new('http://localhost:8545') }
  let (:version) { subject.eth_protocol_version["result"] }

  it 'is able to connect' do
    expect(version).to be_instance_of String
  end

end
