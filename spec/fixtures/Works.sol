pragma solidity ^0.4.2;

contract Works {

    address public owner;

    function Works() { owner = msg.sender; }

    function kill() { if (msg.sender == owner) selfdestruct(owner); }

    mapping(bytes32 => bytes32) public signatures;

    function set(bytes32 id, bytes32 sig) public {
      if (msg.sender != owner) throw;
      signatures[id] = sig;
    }

    function get(bytes32 id) constant returns (bytes32) {
        return signatures[id];
    }

    function unset(bytes32 id) {
        if (msg.sender != owner) throw;
        signatures[id] = bytes32(0x0);
    }

}