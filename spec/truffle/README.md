# Sample Truffle project for testing

This directory contains a simple Truffle project for testing the Truffle integration.
It has been tested with [Truffle 4](https://github.com/trufflesuite/truffle/releases/tag/v4.0.0)
and [TestRPC](https://github.com/ethereumjs/testrpc).

### Running Truffle

The project includes the generated artifact files for the TestContractOne contract, so for testing
purposes you do not need to run Truffle. If you do, you should start TestRPC with a high enough gas
limit that the migrations don't run out, for example:

```
testrpc -l 6000000 -m "one two three four"
```
(the `-m` flag sets the wallet mnemonic so that accounts are created consistently across restarts).

### Running tests

There is an rspec test context in spec/etereum/contract_spec.rb that exercises the Truffle integration;
you don't need to be running TestRPC in order to run the rspec tests.

