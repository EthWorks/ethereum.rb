contract DigixbotConfiguration {

  struct Coin {
    bytes4 name;
    address wallet;
    bool locked;
  }

  address owner;
  address botcontract;
  address userscontract;
  bool locked;

  mapping(bytes4 => Coin) coins;

  modifier ifowner { if (msg.sender == owner) _ }
  modifier unlesslocked { if (locked == false) _ }

  function DigixbotConfiguration() {
    owner = msg.sender;
    locked = false;
  }

  function getOwner() public constant returns (address) {
    return owner;
  }

  function setBotContract(address _botcontract) ifowner unlesslocked {
    botcontract = _botcontract;
  }
  
  function getBotContract() public returns (address) {
    return botcontract;
  }

  function setUsersContract(address _userscontract) ifowner unlesslocked {
    userscontract = _userscontract;
  }

  function getUsersContract() public returns (address) {
    return userscontract;
  }

  function lockConfiguration() ifowner {
    locked = true;
  }

  function addCoin(bytes4 _name, address _wallet) ifowner {
    Coin _cta = coins[_name];
    if (_cta.locked == false) {
      _cta.name = _name;
      _cta.wallet = _wallet;
      _cta.locked = true;
    }
  }

  function getCoinWallet(bytes4 _coin) public constant returns (address) {
    return coins[_coin].wallet;
  }

} 

