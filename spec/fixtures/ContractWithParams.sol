contract ContractWithParams {

  address setting;

  function ContractWithParams(address _setting) {
    setting = _setting;
  }

  function getSetting() public constant returns (address) {
    return setting;
  }

}

