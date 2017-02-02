# Prerequisites

## Compatibility and requirements

* Tested with parity 1.5.0, might work with geth (but was not tested)
* Tested with solc 0.4.9
* Ruby 2.x
* UNIX/Linux or OS X environment

## Prerequisites

Ethereum.rb requires installation of ethereum node and solidity compiler.

### Ethereum node

Currently the lib supports only [parity](https://ethcore.io/parity.html). To install parity on mac simply:

    $ brew install parity --beta

To install parity on linux download latest package from [parity github](https://github.com/ethcore/parity/releases) and install on your computer.

It might work with [geth](https://github.com/ethereum/go-ethereum/wiki/geth) as well, but this configuration is not tested. Library assumes that you have at least one wallet configured.

### Solidity complier

To be able to compile [solidity](https://github.com/ethereum/solidity) contracts you need to install solc compiler. Installation instructions are available [here](http://solidity.readthedocs.io/en/latest/installing-solidity.html).
To install on mac simply:

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

    $ gem install ethereum.eb
