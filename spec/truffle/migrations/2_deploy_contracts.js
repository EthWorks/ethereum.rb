var TestContractOne = artifacts.require("./contracts/TestContractOne.sol");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(TestContractOne)
	.then(function() {
		  deployer.logger.log("Deployed TestContractOne at " + TestContractOne.address);
	      })
	.catch(function(e) {
		   deployer.logger.log("error: " + e);
	       });
};
