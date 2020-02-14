# Prerequisites

## Compatibility and requirements

* Tested with parity 2.5, might work with geth and older parity, but was not tested.
* Tested with solc 0.5.16
* Ruby 2.x
* UNIX/Linux or OS X environment

## Installing prerequisites

### Ethereum node

Currently the only node supported by ethereum.rb is [parity](https://ethcore.io/parity.html). To install parity on mac simply:

    $ brew tap ethcore/ethcore
    $ brew install parity

To install parity on linux download latest package from [parity github](https://github.com/paritytech/parity/releases) and install on your computer.

It might work with [geth](https://github.com/ethereum/go-ethereum/wiki/geth) as well, but this configuration is not tested. 

To work correctly ethereum.rb needs parity to have at least one wallet configured. Parity should automatically create one for you during installation. 
You can see the list of wallets by calling:

    $ parity account list

And create one with following command:

    $ parity account new

### Solidity complier

To be able to compile [solidity](https://github.com/ethereum/solidity) contracts you need to install solc compiler. Installation instructions are available [here](http://solidity.readthedocs.io/en/latest/installing-solidity.html).
To install on mac type:

    $ brew install solidity --beta

In general get used to working on beta versions as ethereum ecosystem evolves quite fast.

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

It will run parity node, unlock the first account on the account list, but you need to supply it with password.
To do that adding create file containing password accessable from your parity folder, which should be one of the following:
 * `/Users/You/AppData/Roaming/Parity/Ethereum` on Windows
 * `/Users/you/Library/Application Support/io.parity.ethereum` on MacOS
 * `/home/you/.local/share/parity` on Linux/Unix
 * `/home/you/.parity` on Linux and MacOS for Parity versions older then 1.5.0

Warnning: Running a parity node with unlock wallet is a considerable security risk and should be avoided on production servers. Especially avoid running node with unlocked wallet and enabled json rpc server in http mode.

To send transaction on a testnet blockchain you will need test ether, you can get it at the following site.

* [Goerli Testnet Faucet](https://goerli-faucet.slock.it/)
* [Goerli: Authenticated Faucet](https://faucet.goerli.mudit.blog/)
