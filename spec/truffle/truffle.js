module.exports = {
    networks: {
	development: {
	    host: "localhost",
	    port: 8545,
	    network_id: "*", // Match any network id
	    // The sandbox contract used by truffle Solidity testing takes 5741753 gas, so we need to
	    // set up a large default gas value (I couldn't figure out if and where to set the transaction
	    // gas for the "before all" hook)
	    // Note that testrpc also needs to bump its gas limit, for example:
	    // testrpc -l 6000000
	    gas: 5900000
	}
    },
    mocha: {
	reporter: 'spec'
	// reporter: 'list'
	// reporter: 'doc'
	// reporter: 'html'
    }
};
