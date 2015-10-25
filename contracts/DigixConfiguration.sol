contract DigixConfiguration {
  
  address owner;
  Directory.Data admins;

  mapping (bytes32 => address) configurations;

  event SetOwner(address indexed owner, address indexed by);
  event AddConfigEntry(bytes32 indexed key, address indexed val, address indexed by);
  event RegisterAdmin(address indexed account, address indexed by);
  event UnregisterAdmin(address indexed account, address indexed by);

  function DigixConfiguration() {
    owner = msg.sender;
  }

  modifier ifowner { if(msg.sender == owner) _ }
  modifier ifadmin { if((msg.sender == owner) || isAdmin(msg.sender)) _ }

  function getOwner() public constant returns (address) {
    return owner;
  }

  function setOwner(address _newowner) ifowner {
    address _oldaddress = owner;
    owner = _newowner;
    SetOwner(_newowner, msg.sender);
  }

  function addConfigEntry(bytes32 _key, address _val) ifowner {
    address _oldaddress = configurations[_key];
    configurations[_key] = _val;
    AddConfigEntry(_key, _val, msg.sender);
  }

  function getConfigEntry(bytes32 _key) public constant returns (address) {
    return configurations[_key];
  }
  
  function registerAdmin(address _acct) ifowner {
    if (!Directory.insert(admins, _acct))
      throw;
    RegisterAdmin(_acct, msg.sender);
  }

  function unregisterAdmin(address _acct) ifowner {
    if (!Directory.remove(admins, _acct))
      throw;
    UnregisterAdmin(_acct, msg.sender);
  }

  function isAdmin(address _acct) public returns (bool) {
    return Directory.contains(admins, _acct);
  }

}
