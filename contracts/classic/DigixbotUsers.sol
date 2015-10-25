contract DigixbotUsers {

  struct User {
    bytes32 id; 
    address account;
    bool configured;
    bool lockaccount;
    bool locktip;
  }

  address owner;
  address config;

  mapping(bytes32 => User) users;
  mapping(address => bytes32) ids;

  event EventLog(uint indexed _eventType, bytes32 indexed _eventData);
  enum EventTypes { AddUser, SetAccount }

  function DigixbotUsers(address _config) {
    owner = msg.sender;
    config = _config;
  }

  function getOwner() public returns (address) {
    return owner;
  }

  function getConfig() public returns (address) {
    return config;
  }

  function getBotContract() public returns (address) {
    return DigixbotConfiguration(config).getBotContract();
  }

  modifier ifowner { if (msg.sender == owner) _ }
  modifier ifbot { if (msg.sender == getBotContract()) _ }

  function addUser(bytes32 _id) ifbot {
    users[_id].id = _id;
    users[_id].configured = true;
    users[_id].lockaccount = false;
    users[_id].locktip = false;
    EventLog(uint(EventTypes.AddUser), _id);
  }

  function userCheck(bytes32 _id) public returns (bool) {
    return users[_id].configured;
  }

  function setUserAccount(bytes32 _id, address _account) ifbot {
    bool _acctlock = accountLockCheck(_id);
    if (_acctlock == false) {
      users[_id].account = _account;
      ids[_account] = _id; 
      EventLog(uint(EventTypes.SetAccount), _id);
    }
  }

  function accountLockCheck(bytes32 _id) public returns (bool) {
    return users[_id].lockaccount;
  }

  function lockAccount(bytes32 _id) ifbot {
    if (userAddressCheck(_id) == true) {
      users[_id].lockaccount = true;
    }
  }

  function userAddressCheck(bytes32 _id) public returns (bool) {
    address _user = getUserAccount(_id); 
    return _user != 0x0000000000000000000000000000000000000000;
  }

  function unlockAccount(bytes32 _id) ifbot {
    users[_id].lockaccount = false;
  }

  function tipLockCheck(bytes32 _id) public returns (bool) {
    return users[_id].locktip;
  }
  
  function lockTip(bytes32 _id) ifbot {
    if (userAddressCheck(_id) == true) {
      users[_id].locktip = true;
    }
  }

  function unlockTip(bytes32 _id) ifbot {
    users[_id].locktip = false;
  }

  function getUserId(address _account) public returns (bytes32) {
    return ids[_account];
  }

  function getUserAccount(bytes32 _id) public returns (address) {
    return users[_id].account;
  }

}

