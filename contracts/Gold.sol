import "contracts/GenericInterface.sol";
import "contracts/GoldRegistry.sol";

contract Gold is GenericInterface {

  uint256 weight;
  uint256 serial;
  uint256 lastStoragePayment;
  uint256 base;
  uint256 auditCount;
  bool registered;
  bool active;

  modifier ifowner { if(owner == msg.sender) _ }
  modifier ifcansend { if(canSend()) _ }
  modifier ifunregistered { if(registered == false) _ }

  event GoldAuditReport(bool indexed passed, address indexed document, address indexed auditor);

  function Gold(address _conf, uint256 _wt) {
    base = 1000000000;
    owner = msg.sender;
    config = _conf;
    auditCount = 0;
    weight = base * _wt;
    registered = false;
    active = false;
    lastStoragePayment = block.timestamp;
  }

  function register(address _owner) ifgoldregistry  {
    owner = _owner;
  }

  function activate() ifgoldregistry {
    active = true;
  }

  function getCalculatedFees() public returns (uint256) {
    uint256 _totalfee = 0;
    uint256 _dayseconds = 60; // 86400 seconds buy for testing we set to one minute
    uint256 _lp = lastStoragePayment;
    uint256 _wt = weight;
    uint256 _dailyRatePpb = getStorageRate();
    uint256 _startRun = block.timestamp;
    while ((_startRun - _lp) > _dayseconds) {
      uint256 _calculatedFee = ((_wt * _dailyRatePpb) / base);
      _wt -= _calculatedFee;
      _totalfee += _calculatedFee;
      _lp += _dayseconds;
    }
    return _totalfee;
  }

  function mint() ifowner ifcansend {
     
  }

  function transferOwner(address _recipient) ifowner ifcansend {
    owner = _recipient;
  }

  function getOwner() public returns (address) {
    return owner;
  }

  function getLastStoragePayDate() public returns (uint256) {
    return lastStoragePayment;
  }

  function getStorageRate() public returns (uint256) {
    return DigixConfiguration(config).getConfigEntryInt("rates/storage");
  }

  function getWeightMinusFees() public returns (uint256) {
    return (weight - getCalculatedFees());
  }

  function hasFees() public returns (bool) {
    return (getCalculatedFees() > 0);
  }

  function isActive() public returns (bool) {
    return active;
  }

  function isYellow() public returns (bool) {
    uint256 daylength = 60;
    return ((block.timestamp - lastStoragePayment) > (daylength * 30));
  }
  
  function isRed() public returns (bool) {
    uint256 daylength = 60;
    return ((block.timestamp - lastStoragePayment) > (daylength * 90));
  }

  function canSend() public returns (bool) {
    return (!isRed());
  }
  
  function getWeight() public returns (uint256) {
    return weight;
  }

}
