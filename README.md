# Ethereum Ruby library - Ethereum.rb

[![Build Status](https://travis-ci.org/EthWorks/ethereum.rb.svg?branch=master)](https://travis-ci.org/EthWorks/ethereum.rb) [![security](https://hakiri.io/github/NullVoxPopuli/MetaHash/master.svg)](https://hakiri.io/github/NullVoxPopuli/MetaHash/master) [![Dependency Status](https://gemnasium.com/marekkirejczyk/ethereum.rb.svg)](https://gemnasium.com/marekkirejczyk/ethereum.rb) [![Code Climate](https://codeclimate.com/github/marekkirejczyk/ethereum.rb/badges/gpa.svg)](https://codeclimate.com/github/marekkirejczyk/ethereum.rb)

The goal of ethereum.rb is to make interacting with ethereum blockchain from ruby as fast and easy as possible (but not easier!).

## Maintainer
Project is currently maintained by [@kurotaky](https://github.com/kurotaky).

## Highlights

* Simple syntax, programmer friendly
* Deploy and interact with contracts on the blockchain
* Contract - ruby object mapping to solidity contract
* Signing transactions with [ruby-eth](https://github.com/se3000/ruby-eth) gem.
* Compile Solidity contracts with solc compiler from ruby
* Receive events from contract
* Make direct json rpc calls to node from ruby application
* Connect to node via IPC or HTTP
* Helpful rake tasks for common actions

## Installation

Before installing gem make sure you meet all [prerequisites](https://github.com/marekkirejczyk/ethereum.rb/blob/master/PREREQUISITES.md), especially that you have:
* compatible ethereum node installed
* compatible solidity compiler installed
* wallet with some ethereum on it

Before you run a program check that the node is running and accounts you want to spend from are unlocked.

To install gem simply add this line to your application's Gemfile:

```ruby
gem 'ethereum.rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ethereum.rb

## Basic Usage

You can create contract from solidity source and deploy it to the blockchain, with following code:

```ruby
contract = Ethereum::Contract.create(file: "greeter.sol")
address = contract.deploy_and_wait("Hello from ethereum.rb!")
```

Deployment may take up to couple of minutes. Once deployed you can start interacting with contract, e.g. calling it's methods:

```ruby
contract.call.greet # => "Hello from ethereum.rb!"
```

You can see example contract [greeter here](https://github.com/marekkirejczyk/ruby_ethereum_example/blob/master/contracts/greeter.sol).

> If contract method name uses camel case you must convert it to snake case when use call: `call.your_method`.

## Smart contracts

### Compile multiple contracts at once

If you want to complie multiple contracts at once, you can create new instances using newly declared ruby clasess:

```ruby
Ethereum::Contract.create(file: "mycontracts.sol", client: client)
contract = MyContract1.new
contract = contract.deploy_and_wait
contract2 = MyContract2.new
contract2 = contract.deploy_and_wait
```

All names used to name contract in solidity source will translate to name of classes in ruby (camelized).

Note: If class of given name exist it will be undefined first to avoid name collision.

### Get contract from blockchain

The other way to obtain contract instance is get one that already exist in the blockchain. To do so you need a contract name, contract address and ABI definition.

```ruby
contract = Ethereum::Contract.create(name: "MyContract", address: "0x01a4d1A62F01ED966646acBfA8BB0b59960D06dd ", abi: abi)
```

Note that you need to specify contract name, that will be used to define new class in ruby, as it is not a part of ABI definition.

Alternatively you can obtain abi definition and name from contract source file:

```ruby
contract = Ethereum::Contract.create(file: "MyContract.sol", address: "0x01a4d1A62F01ED966646acBfA8BB0b59960D06dd ")
```

If you want to create new contract, that is not yet deployed from ABI definition you will need also to supply binary code:

```ruby
contract = Ethereum::Contract.create(name: "MyContract", abi: abi, code: "...")
```

### Simple Truffle integration

If you use Truffle to build and deploy contracts, you can pick up the Truffle artifacts to initialize
a contract. For example, if you have a MyContract in the Truffle directory at `/my/truffle/project`:

```ruby
contract = Ethereum::Contract.create(name: "MyContract", truffle: { paths: [ '/my/truffle/project' ] }, client: client, address: '0x01a4d1A62F01ED966646acBfA8BB0b59960D06dd')
```

The contract factory will attempt to load the deployed address from the Truffle artifacts if the client's network is present:

```ruby
contract = Ethereum::Contract.create(name: "MyContract", truffle: { paths: [ '/my/truffle/project' ] }, client: client)
```

### Interacting with contract

Functions defined in a contract are exposed using the following conventions:

```ruby
contract.transact.[function_name](params)
contract.transact_and_wait.[function_name](params)  
contract.call.[function_name](params)
```

**Example Contract in Solidity**
```
contract SimpleRegistry {
  event LogRegister(bytes32 key, string value);
  mapping (bytes32 => string) public registry;

  function register(bytes32 key, string value) {
    registry[key] = value;
    LogRegister(key, value);
  }

  function get(bytes32 key) public constant returns(string) {
    return registry[key];
  }

}
```

For contract above here is how to access it's methods:

```ruby
contract.transact_and_wait.register("performer", "Beastie Boys")
```

Will send transaction to the blockchain and wait for it to be mined.

```ruby
contract.transact.register("performer", "Black Eyed Peas")
```

Will send transaction to the blockchain return instantly.

```ruby
contract.call.get("performer") # => "Black Eyed Peas"
```

Will call method of the contract and return result.
Note that no transaction need to be send to the network as method is read-only.
On the other hand `register` method will change contract state, so you need to use `transact` or `transact_and_wait` to call it.

### Receiving Contract Events

Using the example smart contract described above, one can listen for `LogRegister` events by using filters.

You can get a list of events from a certain block number to the latest:

```ruby
require 'ostruct'

event_abi = contract.abi.find {|a| a['name'] == 'LogRegister'}
event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}
decoder = Ethereum::Decoder.new

filter_id = contract.new_filter.log_register(
  {
    from_block: '0x0',
    to_block: 'latest',
    address: '0x....',
    topics: []
  }
)

events = contract.get_filter_logs.log_register(filter_id)

events.each do |event|
  transaction_id = event[:transactionHash]
  transaction = ethereum.eth_get_transaction_receipt(transaction_id)
  args = decoder.decode_arguments(event_inputs, entry['data'])
  puts "#{transaction.inspect} with args: #{args}"
end
```

### IPC Client Connection

By default methods interacting with contracts will use default Json RPC Client that will handle connection to ethereum node.
Default client communicate via IPC. If you want to create custom client or use multiple clients you can create them yourself.

To create IPC client instance of simply create Ethereum::IpcClient:

```ruby
client = Ethereum::IpcClient.new
```

You can also customize it with path to ipc file path and logging flag:

```ruby
client = Ethereum::IpcClient.new("~/.parity/mycustom.ipc", false)
```

If no ipc file path given, IpcClient looks for ipc file in default locations for parity and geth.
The second argument is optional. If it is true then logging is on.

By default logging is on and logs are saved in "/tmp/ethereum_ruby_http.log".

To create Http client use following:

```ruby
client = Ethereum::HttpClient.new('http://localhost:8545')
```

You can supply client when creating a contract:

```ruby
contract = Ethereum::Contract.create(client: client, ...)
```

You can also obtain default client:

```ruby
client = Ethereum::Singleton.instance
```

### Calling json rpc methods

Ethereum.rb allows you to interact directly with Ethereum node using json rpc api calls.
Api calls translates directly to client methods. E.g. to call `eth_gasPrice` method:

```ruby
client.eth_gas_price # => {"jsonrpc"=>"2.0", "result"=>"0x4a817c800", "id"=>1}
```

Note: methods are transated to underscore notation.

Full list of json rpc methods is available [here](https://github.com/ethereum/wiki/wiki/JSON-RPC#user-content-json-rpc-methods)

### Signed transactions

Ethereum.rb supports signing transactions with key using [ruby-eth gem](https://github.com/se3000/ruby-eth).

To create a new key simply do the following:

```ruby
key = Eth::Key.new
```

Then you can use the key to deploy contracts and send transactions, i.e.:

```ruby
contract = Ethereum::Contract.create(file: "...")
contract.key = key
contract.deploy_and_wait("Allo Allo!")
contract.transact_and_wait.set("greeting", "Aloha!")
```

You can also transfer ether transfer using custom keys:

```ruby
client.transfer(key, "0x342bcf27DCB234FAb8190e53E2d949d7b2C37411", amount)
client.transfer_and_wait(key, "0x949d7b2C37411eFB763fcDCB234FAb8190e53E2d", amount)
```

### Custom gas price and gas limit

You can change gas price or gas limit in the client:

```ruby
client.gas_limit = 2_000_000_
client.gas_price = 24_000_000_000
```

or per contract:
```ruby
contract.gas_limit = 2_000_000_
contract.gas_price = 24_000_000_000
```

## Utils

### Url helpers for rails applications

Often in the application you want to link to blockchain explorer. This can be problematic if you want links to work with different networks (ropsten, mainnet, kovan) depending on environment you're working on.
Following helpers will generate link according to network connected:

```ruby
link_to_tx("See the transaction", "0x3a4e53b01274b0ca9087750d96d8ba7f5b6b27bf93ac65f3174f48174469846d")
link_to_address("See the wallet", "0xE08cdFD4a1b2Ef5c0FC193877EC6A2Bb8f8Eb373")
```
They use [etherscan.io](http://etherscan.io/) as a blockexplorer.

Note: Helpers work in rails environment only, works with rails 5.0+.

### Utils rake tasks

There are couple of rake tasks to help in wallet maintenance, i.e.:

```ruby
rake ethereum:contract:deploy[path]             # Compile and deploy contract
rake ethereum:contract:compile[path]            # Compile a contract
rake ethereum:transaction:byhash[id]            # Get info about transaction
rake ethereum:transaction:send[address,amount]  # Send [amount of] ether to an account
```

## Debbuging
Logs from communication between ruby app and node are available under following path:
```
/tmp/ethereum_ruby_http.log
```

## Roadmap

* Rubydoc documentation

## Development

Run `bin/console` for an interactive prompt that will allow you to experiment.

Make sure `rake ethereum:test:setup` passes before running tests.

Then, run `rake spec` to run the tests.

Test that do send transactions to blockchain are marked with `blockchain` tag. Good practice is to run first fast tests that use no ether and only if they pass, run slow tests that do spend ether. To do that  use the following line:

```bash
$ bundle exec rspec --tag ~blockchain && bundle exec rspec --tag blockchain
```

You need ethereum node up and running for tests to pass and it needs to be working on testnet (Ropsten).

## Acknowledgements and license

This library has been forked from [ethereum-ruby](https://github.com/DigixGlobal/ethereum-ruby) by DigixGlobal Pte Ltd (https://dgx.io).

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
