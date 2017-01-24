pragma solidity ^0.4.8;

contract TestContract {

    address public owner;

    function TestContract() { owner = msg.sender; }

    function kill() {
        if (msg.sender == owner) {
            selfdestruct(owner);
            killed();
        }
    }

    mapping(bytes32 => bytes32) public signatures;

    function set(bytes32 id, bytes32 sig) public {
      if (msg.sender != owner) throw;
      signatures[id] = sig;
      changed();
    }

    function get(bytes32 id) constant returns (bytes32, string) {
        return (signatures[id], "żółć");
    }

    function unset(bytes32 id) {
        if (msg.sender != owner) throw;
        signatures[id] = bytes32(0x0);
    }

    event changed();
    event killed();

}