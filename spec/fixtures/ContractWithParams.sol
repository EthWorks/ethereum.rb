contract ContractWithParams {

  address setting;

  event MyEvent(address indexed _a, uint indexed _b);

  function ContractWithParams(address _setting) {
    setting = _setting;
  }

  function getSetting() public constant returns (address) {
    return setting;
  }

  function genEvent() {
    MyEvent(msg.sender, block.timestamp);
  }

  function getSetting(uint _a) public constant returns (uint) {
    return _a * _a;
  }

}

