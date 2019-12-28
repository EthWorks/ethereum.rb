module Ethereum
  module ExplorerUrlHelper

    CHAIN_PREFIX = {
      17 => "no-explorer-for-devmode.",
      42 => "kovan.",
      3 => "ropsten.",
      4 => "rinkeby.",
      5 => "goerli."
    }

    def link_to_tx(label, txid, **opts)
      link_to label, explorer_path("tx/#{txid}"), {target: "_blank"}.merge(opts)
    end

    def link_to_address(label, address, **opts)
      link_to label, explorer_path("address/#{address}"), {target: "_blank"}.merge(opts)
    end

    def explorer_path(suffix, version = Ethereum::Singleton.instance.get_chain)
      prefix = CHAIN_PREFIX.fetch(version, "")
      "https://#{prefix}etherscan.io/#{suffix}"
    end
  end
end
