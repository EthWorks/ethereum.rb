import "contracts/DigixbotUsers.sol";
import "contracts/DigixbotConfiguration.sol";

contract Coin {
  function getBotContract() returns(address );
  function getUserId(address _address) returns(bytes32 );
  function withdrawCoin(bytes32 _user,uint256 _amount);
  function depositCoin(bytes32 _uid,uint256 _amt);
  function getBalance(bytes32 _uid) returns(uint256 );
  function totalBalance() returns(uint256 );
  function getConfig() returns(address );
  function getUsersContract() returns(address );
  function sendCoin(bytes32 _sender,bytes32 _recipient,uint256 _amt);
}

contract Digixbot {
  address owner;
  address config;

  function Digixbot(address _config) {
    owner = msg.sender;
    config = _config;
  }

  modifier ifowner { if(msg.sender == owner) _ }

  function getConfig() public returns (address) {
    return config;
  }

  function addUser(bytes32 _userid) ifowner {
    DigixbotUsers(getUsersContract()).addUser(_userid); 
  }

  function setUserAccount(bytes32 _userid, address _account) ifowner {
    bool _acctlock = accountLockCheck(_userid);
    if (_acctlock == false) {
      DigixbotUsers(getUsersContract()).setUserAccount(_userid, _account);
    }
  }

  function getUserAccount(bytes32 _userid) public returns (address) {
    return DigixbotUsers(getUsersContract()).getUserAccount(_userid);
  }

  function getUsersContract() public returns (address) {
    return DigixbotConfiguration(config).getUsersContract();
  }

  function getCoinWallet(bytes4 _coin) public returns(address) {
    return DigixbotConfiguration(config).getCoinWallet(_coin);
  }

  function userCheck(bytes32 _id) public returns(bool) {
    return DigixbotUsers(getUsersContract()).userCheck(_id);
  }

  function sendCoin(bytes4 _coin, bytes32 _from, bytes32 _to, uint _amount) ifowner {
    bool _tiplock = tipLockCheck(_from);
    if (_tiplock == false) {
      Coin(getCoinWallet(_coin)).sendCoin(_from, _to, _amount); 
    }
  }
    
  function withdrawCoin(bytes4 _coin, bytes32 _userid, uint _amount) ifowner {
    Coin(getCoinWallet(_coin)).withdrawCoin(_userid, _amount);
  }

  function getCoinBalance(bytes4 _coin, bytes32 _userid) public returns(uint) {
    return Coin(getCoinWallet(_coin)).getBalance(_userid);
  }

  function getTotalBalance(bytes4 _coin) public returns(uint) {
    return Coin(getCoinWallet(_coin)).totalBalance();
  }

  function accountLockCheck(bytes32 _id) public returns (bool) {
    return DigixbotUsers(getUsersContract()).accountLockCheck(_id);
  }
  
  function tipLockCheck(bytes32 _id) public returns (bool) {
    return DigixbotUsers(getUsersContract()).tipLockCheck(_id);
  }

  function lockAccount(bytes32 _id) ifowner {
    DigixbotUsers(getUsersContract()).lockAccount(_id);
  }

  function lockTip(bytes32 _id) ifowner {
    DigixbotUsers(getUsersContract()).lockTip(_id);
  }

  function unlockAccount() {
    address _userscontract = getUsersContract();
    bytes32 _userid = DigixbotUsers(_userscontract).getUserId(msg.sender);
    DigixbotUsers(_userscontract).unlockAccount(_userid);
  }

  function unlockTip() {
    address _userscontract = getUsersContract();
    bytes32 _userid = DigixbotUsers(_userscontract).getUserId(msg.sender);
    DigixbotUsers(_userscontract).unlockTip(_userid);
  }
  

}
