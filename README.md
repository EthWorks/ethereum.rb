# Ruby library for  connecting with Ethereum node

A simple library for Ethereum.

## Highlights

* Pure Ruby implementation
* IPC & HTTP Client with batch calls support
* Compile Solidity contracts with solc compiler
* Deploy and call contracts methods
* Contract events

## Compatibility and requirements

* Tested on parity, might work with geth
* Ruby 2.x
* UNIX/Linux or OS X environment


## Prerequisites

Ethereum.rb requires installation of ethereum node and solidity compiler.

### Ethereum node

Currently the lib supports only [parity](https://ethcore.io/parity.html). It might work with [geth](https://github.com/ethereum/go-ethereum/wiki/geth) as well, but this configuration is not tested. Library assumes that you have at least one wallet configured.

### Solidity complier

To be able to compile [solidity](https://github.com/ethereum/solidity) contracts you need to install solc compiler. Installation instructions are available [here](http://solidity.readthedocs.io/en/latest/installing-solidity.html).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ethereum'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ethereum

## Basic Usage

### IPC Client Connection

To create client instance simply create Ethereum::IpcClient:

```ruby
client = Ethereum::IpcClient.new
```

You can also customize it with path to ipc file path and logging flag:

```ruby
client = Ethereum::IpcClient.new("~/.parity/mycustom.ipc", false)
```

If no ipc file path given, IpcClient looks for ipc file in default locations for parity and geth.
By default logging is on and logs are saved in "/tmp/ethereum_ruby_http.log".


### Solidity contract compilation and deployment

You can create contract from solidity source and deploy it to the blockchain.

```ruby
contract = Ethereum::Contract.from_file("mycontract.sol", client)
contract_instance = contract.deploy_and_wait
```

Deployment may take up to couple minutes.
Or with more complex syntax (might be useful if you want to complie multiple contracts at once):

```ruby
init = Ethereum::Initializer.new("mycontract.sol", client)
init.build_all
contract = MyContract.new
contract_instance = contract.deploy_and_wait(60)
```

Note that contract variable holds the reference to contract code, while contract_instance holds refernce to contract deployed to the blockchain. You can call contract functions on contract_instance as described in sections "Transacting and Calling Solidity Functions".

All names used to name contract in solidity source will transalte to name of classes in ruby (camelized).
If class of given name exist it will be undefined first to avoid name collision. 

### Get contract from blockchain

The other way to obtain contract instance is get one form the blockchain. To do so you need a contract name, contract address and ABI definition.

```ruby
contract_instance = Ethereum::Contract.from_blockchain("MyContract", "0x01a4d1A62F01ED966646acBfA8BB0b59960D06dd ", abi, client)

```

Note that you need to specify contract name, that will be used to define new class in ruby, as it is not a part of ABI definition.

### Transacting and Calling Solidity Functions

Solidity functions are exposed using the following conventions: 

```
transact_[function_name](params) 
transact_and_wait_[function_name](params)  
call_[function_name](params)
```

**Example Contract in Solidity**
```
contract SimpleNameRegistry {

  mapping (address => bool) public myMapping;

  function register(address _a, bytes32 _b) {
  }

  function getSomeValue(address _x) public constant returns(bool b, address b) {
  }

}
```

```ruby
simple_name_registry_instance.transact_and_wait_register("0x5b6cb65d40b0e27fab87a2180abcab22174a2d45", "minter.contract.dgx")
simple_name_registry_instance.transact_register("0x385acafdb80b71ae001f1dbd0d65e62ec2fff055", "anthony@eufemio.dgx")
simple_name_registry_instance.call_get_some_value("0x385acafdb80b71ae001f1dbd0d65e62ec2fff055")
simple_name_registry_instance.call_my_mapping("0x385acafdb80b71ae001f1dbd0d65e62ec2fff055")
```

### Run contracts using a different address

```ruby
simple_name_registry_instance.as("0x0c0d99d3608a2d1d38bb1b28025e970d3910b1e1")
```

### Point contract instance to a previously deployed contract

```ruby
simple_name_registry_instance.at("0x734533083b5fc0cd14b7cb8c8eb6ed0c9bd184d3")
```

## Utils rake tasks

```ruby
rake ethereum:contract:compile[path]            # Compile a contract / Compile and deploy contract
rake ethereum:node:mine                         # Mine ethereum testing environment for ethereum node
rake ethereum:node:run                          # Run morden (production) node
rake ethereum:node:test                         # Run testnet node
rake ethereum:test:setup                        # Setup testing environment for ethereum node
rake ethereum:transaction:byhash[id]            # Get info about transaction
rake ethereum:transaction:send[address,amount]  # Send [amount of] ether to an account

```

## Debbuging
Logs from communication with node are available under following path:
```
/tmp/ethereum_ruby_http.log
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. 
Make sure `rake ethereum:test:setup` passes before running tests.
Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Status 

[![Build Status](https://travis-ci.org/marekkirejczyk/ethereum.rb.svg?branch=master)](https://travis-ci.org/marekkirejczyk/ethereum.rb)

## Ethereum ruby

This library has been forked from [ethereum-ruby](https://github.com/DigixGlobal/ethereum-ruby) by DigixGlobal Pte Ltd (https://dgx.io).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

