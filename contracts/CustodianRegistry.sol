contract CustodianRegistry {

  address config;
  Directory.Data custodians;

  function CustodianRegistry(address _conf) {
    config = _conf;
  }

  function isCustodian(address _cust) public returns (bool) {
    return Directory.contains(custodians, _cust);
  }

}
