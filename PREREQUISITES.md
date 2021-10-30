# Prerequisites

## Compatibility and requirements

* Tested with OpenEthereum 3.3, might work with Geth and older Parity versions, but was not tested.
* Tested with `solc` 0.5.17
* Ruby 2.7 or 3.0
* UNIX/Linux or OS X environment

## Installing prerequisites

### Ethereum node

Currently the only node supported by ethereum.rb is [OpenEthereum](https://github.com/openethereum/openethereum).

To install OpenEthereum download latest package from [Github](https://github.com/openethereum/openethereum/releases) and install on your computer.

To work correctly ethereum.rb needs OpenEthereum to have at least one wallet configured. OpenEthereum should automatically create one for you during installation.
You can see the list of wallets by calling:

    $ openethereum account list

And create one with following command:

    $ openethereum account new

### Solidity complier

To be able to compile [solidity](https://github.com/ethereum/solidity) contracts you need to install solc compiler. Installation instructions are available [here](http://solidity.readthedocs.io/en/latest/installing-solidity.html).
To install on mac type:

    $ brew install solidity

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ethereum.rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ethereum.rb

### Running a node

There is a rake task to run node on testnet network, that you can run from your application directory:

    $ rake ethereum:node:test

It will run OpenEthereum node, unlock the first account on the account list, but you need to supply it with password.
To do that adding create file containing password accessable from your OpenEthereum folder, which should be one of the following:
 * `/Users/You/AppData/Roaming/Parity/Ethereum` on Windows
 * `/Users/you/Library/Application Support/io.parity.ethereum` on MacOS
 * `/home/you/.local/share/io.parity.ethereum` on Linux/Unix

Warnning: Running a OpenEthereum node with unlock wallet is a considerable security risk and should be avoided on production servers. Especially avoid running node with unlocked wallet and enabled json rpc server in http mode.

To send transaction on a testnet blockchain you will need test ether, you can get it at the following site.

* [Goerli Testnet Faucet](https://goerli-faucet.slock.it/)
* [Goerli: Authenticated Faucet](https://faucet.goerli.mudit.blog/)
