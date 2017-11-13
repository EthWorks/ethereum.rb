var TestContractOne = artifacts.require("./contracts/TestContractOne.sol");

contract('TestContractOne', function(accounts) {
  it("adds and subtracts value", function() {
	 var tc;
	 var u = accounts[2];
	 var initial_counter;
	 var final_counter;

	 return TestContractOne.deployed()
	     .then(function(i) {
		       tc = i;
		       return tc.counterFor.call(u);
		   })
	     .then(function(v) {
		       initial_counter = v.toNumber();
		       return tc.addCounter(u, 10);
		   })
	     .then(function(r) {
		       return tc.counterFor.call(u);
		   })
	     .then(function(v) {
		       final_counter = v.toNumber();
		       assert.equal(final_counter - initial_counter, 10, "counter was not increased correctly");
		  });
     });
});
