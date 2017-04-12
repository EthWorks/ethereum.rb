require 'spec_helper'

describe Ethereum::Solidity do

  include Ethereum::ExplorerUrlHelper
  
  def link_to(label, url, options)
    "<a href=\"#{url}\">#{label}</a>"
  end
  
  it "link_to_tx" do
    html = link_to_tx("See the transaction", "0x3a4e53b01274b0ca9087750d96d8ba7f5b6b27bf93ac65f3174f48174469846d")
    expect(html).to start_with '<a href="https://'
    expect(html).to end_with '.etherscan.io/tx/0x3a4e53b01274b0ca9087750d96d8ba7f5b6b27bf93ac65f3174f48174469846d">See the transaction</a>'
  end

  it "link_to_address" do
    html = link_to_address("See the wallet", "0xE08cdFD4a1b2Ef5c0FC193877EC6A2Bb8f8Eb373")
    expect(html).to start_with '<a href="https://'
    expect(html).to end_with '.etherscan.io/address/0xE08cdFD4a1b2Ef5c0FC193877EC6A2Bb8f8Eb373">See the wallet</a>'
  end

end
