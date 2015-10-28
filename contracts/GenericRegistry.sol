contract GenericRegistry {

  address config;

  function isAdmin(address _acct) public returns (bool) {
    return DigixConfiguration(config).isAdmin(_acct);
  }

  function getConfigAddress() public returns (address) {
    return config;
  }

  modifier ifadmin { if(isAdmin(msg.sender)) _ }

}
