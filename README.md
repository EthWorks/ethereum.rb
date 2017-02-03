# Ethereum Ruby library - Ethereum.rb

[![Build Status](https://travis-ci.org/marekkirejczyk/ethereum.rb.svg?branch=master)](https://travis-ci.org/marekkirejczyk/ethereum.rb) [![security](https://hakiri.io/github/NullVoxPopuli/MetaHash/master.svg)](https://hakiri.io/github/NullVoxPopuli/MetaHash/master) [![Dependency Status](https://gemnasium.com/marekkirejczyk/ethereum.rb.svg)](https://gemnasium.com/marekkirejczyk/ethereum.rb) [![Code Climate](https://codeclimate.com/github/marekkirejczyk/ethereum.rb/badges/gpa.svg)](https://codeclimate.com/github/marekkirejczyk/ethereum.rb)

The goal of ethereum.rb is to make interacting with ethereum blockchain from ruby as easy as possible (but not easier).

## Highlights

* Compile Solidity contracts with solc compiler
* Deploy and interact with contracts on the blockchain
* Recieve contract events
* Run json rpc calls from ruby
* Connect to node via IPC or HTTP
* Helpful rake tasks for common actions

## Installation

Before installing gem make sure you meet all [prerequisites](https://github.com/marekkirejczyk/ethereum.rb/blob/master/PREREQUISITES.md).

To install gem simply add this line to your application's Gemfile:

```ruby
gem 'ethereum.rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ethereum.eb

## Basic Usage

### Running a node

Right after parity installation you will have one default account. There is a rake task to run test node, that you can run from your application directory:

    $ rake ethereum:node:test
    
It will run parity node, unlock the first account on the account list, but you need to supply it with password. To do that adding create file containing password accessable from the following path:

`~/.parity/pass`

To run operations modifiying blockchain you will need test ether, you can get it [here](http://faucet.ropsten.be:3001/).

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
contract = Ethereum::Contract.create(file: "mycontract.sol", client: client)
address = contract.deploy_and_wait
```

Deployment may take up to couple minutes.
If you want to complie multiple contracts at once, you can create new instances using newly declared clasess:

```ruby
Ethereum::Contract.create(file: "mycontract.sol", client: client)
contract = MyContract.new
contract = contract.deploy_and_wait
```

All names used to name contract in solidity source will transalte to name of classes in ruby (camelized).
If class of given name exist it will be undefined first to avoid name collision. 

### Get contract from blockchain

The other way to obtain contract instance is get one form the blockchain. To do so you need a contract name, contract address and ABI definition.
`client` parameter is optional.

```ruby
contract = Ethereum::Contract.create(name: "MyContract", address: "0x01a4d1A62F01ED966646acBfA8BB0b59960D06dd ", abi: abi, client: client)
```

Note that you need to specify contract name, that will be used to define new class in ruby, as it is not a part of ABI definition.

If you want to create new contract, that is not yet deployed from ABI definition you need to supply binary code too:

```ruby
contract = Ethereum::Contract.create(name: "MyContract", address: "0x01a4d1A62F01ED966646acBfA8BB0b59960D06dd ", abi: abi, code: "...")
```

### Transacting and Calling Solidity Functions

Functions defined in a contract are exposed using the following conventions: 

```
contract.transact.[function_name](params) 
contract.transact_and_wait.[function_name](params)  
contract.call.[function_name](params)
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

And here is how to access it's methods:

```ruby
contract.transact_and_wait.register("0x5b6cb65d40b0e27fab87a2180abcab22174a2d45", "minter.contract.dgx")
contract.transact.register("0x385acafdb80b71ae001f1dbd0d65e62ec2fff055", "anthony@eufemio.dgx")
contract.call.get_some_value("0x385acafdb80b71ae001f1dbd0d65e62ec2fff055")
```

Note that as `register` method will change contract state, so you need to use `transact` family of methods (or `transact_and_wait` for synchronous version) to call it.

For method like `getSomeValue`, that does not affect state of the contract (and don't need to propagate change to blockchain therefore) you can use call method. It will retrive value from local copy of the blockchain.


## Utils rake tasks

There is plenty of useful rake tasks for interacting with blockchain:

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
Logs from communication between ruby app and node are available under following path:
```
/tmp/ethereum_ruby_http.log
```

## Roadmap

* Dynamic arrays serialization 
* Signing transactions 


## Development

Make sure `rake ethereum:test:setup` passes before running tests. 

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Then, run `rake spec` to run the tests. 

Test that do send transactions to blockchain are marked with `blockchain` tag. Good practice is to run first fast tests that use no ether and only if they pass, run slow tests that do spend ether. To do that  use the following line:

    $ bundle exec rspec --tag ~blockchain && bundle exec rspec --tag blockchain

You need ethereum node up and running for tests to pass and it needs to be working on testnet (Ropsten).

## Acknowledgements and license

This library has been forked from [ethereum-ruby](https://github.com/DigixGlobal/ethereum-ruby) by DigixGlobal Pte Ltd (https://dgx.io).

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

