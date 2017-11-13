pragma solidity ^0.4.17;

contract TestContractOne {
    mapping(address => uint256) internal counters;

    function TestContractOne() public {
    }

    function counterFor(address _a) public view returns (uint256) {
        return counters[_a];
    }
    
    function addCounter(address _to, uint32 _counter) public {
        require(_counter <= 100);
        require((counters[_to] + _counter) > counters[_to]);
        counters[_to] += _counter;
    }

    function removeCounter(address _from, uint32 _counter) public {
        require(_counter <= 100);
        require(counters[_from] >= _counter);
        counters[_from] -= _counter;
    }
}

