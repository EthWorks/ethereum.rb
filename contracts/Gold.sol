contract Gold {

  address config;
  address owner;
  uint lastfeecalc;
  bool locked;

  struct Detail {
    address vendor;
    address custodian;
    uint status;
    uint auditCount;
  }

  struct Info {
    uint weight;
    bytes32 serialNumber;
    bytes32 vendorReceipt;
    bytes32 custodianReceipt;
  }

  struct StorageFee {
    uint due;
    uint lastPayment;
  }

  Detail detail;
  Info info;
  StorageFee storagefee;

  modifier ifowner { if(owner == msg.sender) _ }

  event GoldAuditReport(bool indexed passed, address indexed document, address indexed auditor);

  function Gold(uint _wt) {
    owner = msg.sender;
    detail.auditCount = 0;
    detail.vendor = msg.sender;
    info.weight = _wt;
    storagefee.lastPayment = block.timestamp;
  }

  function lastCalculation() public returns (uint) {
    return storagefee.lastPayment;
  }

  function timeSinceLastCalc() public returns (uint) {
    return (block.timestamp - storagefee.lastPayment);
  }

  function mathTestDiv(uint _a, uint _b) public returns (uint) {
    return (_a / _b);
  }

  function calculateFee(uint _days) public returns (uint) {
    uint base = 1000000000000;
    uint dailyRate = 10277777777;
    var rate = dailyRate * _days;
    var fee = (rate * info.weight);
    return ((info.weight * base) - fee);
  }

  function mathTestMul(uint _a, uint _b) public returns (uint) {
    return (_a * _b);
  }

}
