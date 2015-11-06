# Ethereum library for Ruby

A simple library for Ethereum.

## Features

* Pure Ruby implementation
* IPC Client with batch calls support
* HTTP Client with batch calls support
* Compile and deploy Solidity contracts
* Deploy contracts with constructor parameters.
* Expose deployed contracts as Ruby classes
* Test solidity contracts with a Ruby testing framework of your choice
* Call and wait for the result of Solidity function calls.
* Contract events 

## Ruby Compatibility

* Ruby 2.x
* Ruby 1.9.x
* JRuby
* Rubinius

## Requirements

We currently support UNIX/Linux environments and Windows IPC support on the roadmap.

You will need to have a properly working Ruby installation.  We recommend [RVM](http://rvm.io/)

To use this library you will need to have a running Ethereum node with IPC support enabled (default).  We currently support [Go-Ethereum client](https://github.com/ethereum/go-ethereum)

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

```ruby
client = Ethereum::IpcClient.new("#{ENV['HOME']}/.ethereum_testnet/geth.ipc")
```

### Solidity contract compilation and deployment

```ruby
init = Ethereum::Initializer.new("#{ENV['PWD']}/spec/fixtures/SimpleNameRegistry.sol", client)
init.build_all
simple_name_registry_instance = SimpleNameRegistry.new
simple_name_registry_instance.deploy_and_wait(60)
```

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

## Roadmap

* Add Windows IPC Client (named pipes)
* Add support for creating and sending of raw transactions
* Offline account creation
* ContractTransaction class
* Add more examples
* API documentation
* Unit testing and contract testing examples.  Use [web3.js](https://github.com/ethereum/web3.js) tests as a baseline.

## Support 

Please join our Gitter chat room or open a new issue in this repository

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/DigixGlobal/ethereum-ruby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DigixGlobal/ethereum-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

