module Ethereum
  module ExplorerUrlHelper
    def link_to_tx(label, txid, **opts)
      link_to label, explorer_path("tx/#{txid}"), {target: "_blank"}.merge(opts)
    end

    def link_to_address(label, address, **opts)
      link_to label, explorer_path("address/#{address}"), {target: "_blank"}.merge(opts)
    end

    def explorer_path(suffix)
      version = Ethereum::Singleton.instance.net_version["result"]
      prefix = ""
      prefix = "no-explorer-for-devmode." if version.to_i == 17
      prefix = "kovan." if version.to_i == 42
      prefix = "ropsten." if version.to_i == 3
      "https://#{prefix}etherscan.io/#{suffix}"
    end
  end
end