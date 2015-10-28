contract DigixConfiguration {
  
  address owner;
  Directory.AddressBoolMap admins;

  mapping (bytes32 => address) configaddr;
  mapping (bytes32 => uint256) configint;

  event SetOwner(address indexed owner, address indexed by);
  event AddConfigEntryA(bytes32 indexed key, address indexed val, address indexed by);
  event AddConfigEntryI(bytes32 indexed key, uint256 indexed val, address indexed by);
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

  function addConfigEntryAddr(bytes32 _key, address _val) ifowner {
    address _oldaddress = configaddr[_key];
    configaddr[_key] = _val;
    AddConfigEntryA(_key, _val, msg.sender);
  }

  function getConfigEntryAddr(bytes32 _key) public constant returns (address) {
    return configaddr[_key];
  }

  function addConfigEntryInt(bytes32 _key, uint256 _val) ifowner {
    uint256 _oldaddress = configint[_key];
    configint[_key] = _val;
    AddConfigEntryI(_key, _val, msg.sender);
  }

  function getConfigEntryInt(bytes32 _key) public constant returns (uint256) {
    return configint[_key];
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
