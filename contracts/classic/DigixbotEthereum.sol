import "contracts/DigixbotConfiguration.sol";
import "contracts/DigixbotUsers.sol";

contract DigixbotEthereum {

  address config;

  mapping(bytes32 => uint) balances;

  event UserIdLogger(bytes32 indexed _debug);

  function DigixbotEthereum(address _config) {
    config = _config;
  }

  function() {
    bytes32 _userid = getUserId(msg.sender);
    UserIdLogger(_userid);
    balances[_userid] += msg.value;
  }

  function depositCoin(bytes32 _userid, uint _amount) ifbot {
    balances[_userid] += _amount;
  }

  function getConfig() public returns (address) {
    return config;
  }

  function getUsersContract() public returns (address) {
    return DigixbotConfiguration(config).getUsersContract();
  }

  function getBotContract() public returns (address) {
    return DigixbotConfiguration(config).getBotContract();
  }

  function getUserId(address _address) public returns (bytes32) {
    return DigixbotUsers(getUsersContract()).getUserId(_address);
  }

  function getUserAccount(bytes32 _userid) public returns(address) {
    return DigixbotUsers(getUsersContract()).getUserAccount(_userid);
  }

  modifier ifbot { if (msg.sender == getBotContract()) _ }
  modifier ifusers { if (msg.sender == getUsersContract()) _ }

  function sendCoin(bytes32 _sender, bytes32 _recipient, uint _amt) ifbot {
    if (_amt >= 100000000000000000) {
      if (balances[_sender] >= _amt) {
        balances[_sender] -= _amt;
        balances[_recipient] += _amt;
      }
    }
  }

  function withdrawCoin(bytes32 _user, uint _amount) ifbot {
    address _requester = getUserAccount(_user);
    if (_requester != 0x0000000000000000000000000000000000000000) {
      if (_amount >= 1000000000000000000) {
        if (balances[_user] >= _amount) {
          balances[_user] -= _amount;
          _requester.send(_amount);
        }
      }
    }
  }

  function withdrawCoinExt(uint _amount) {
    bytes32 _requester = getUserId(msg.sender);
    if (balances[_requester] >= _amount) {
      balances[_requester] -= _amount;
      address(msg.sender).send(_amount);
    }
  }

  function getBalance(bytes32 _uid) public returns (uint) {
    return balances[_uid];
  }

  function totalBalance() public returns (uint) {
    return this.balance;
  }

}
