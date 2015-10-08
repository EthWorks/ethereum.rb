contract SimpleNameRegistry {
  address owner;
  mapping(address => bytes32) public aEntries;
  mapping(bytes32 => address) public nEntries;
  uint8 public first;
  uint16 public second;
  uint32 public third;
  bytes8 public fourth;
  bytes16 public fifth;
  bytes32 public sixth;

  modifier ifowner { if (msg.sender == owner) _ }

  function SimpleNameRegistry() {
    owner = msg.sender;
    first = 1;
    second = 200;
    third = 30000000;
    fourth = "f00fc7c8";
    fifth = "f00fc7c8f00fc7c8";
    sixth = "f00fc7c8f00fc7c8f00fc7c8";
  }

  function sampleBool(bool _b) {
    var b = _b;
  }

  function sampleMulti(bool _b, bytes32 _a, int8 _c, bytes4 _d) {

  }

  function sampleBoolRetTrue() public returns (bool b) {
    b = true;
  }

  function sampleBoolRetFalse() public returns (bool b) {
    b = false;
  }

  function register(address _a, bytes32 _n) ifowner {
    aEntries[_a] = _n;
    nEntries[_n] = _a;
  }

  function getName(address _a) public returns (bytes32 n) {
    n = aEntries[_a];
  }

  function getAddress(bytes32 _n) public returns (address a) {
    a = nEntries[_n];
  }

  function threeParams() public constant returns (address a, bytes32 b, uint c) {
    a = msg.sender;
    b = "change the world";
    c = 31337;
  }

}

contract SimpleContract {
  address owner;
  function SimpleContract() {
    owner = msg.sender;
  }
}