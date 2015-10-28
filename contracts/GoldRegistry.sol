import "contracts/DigixConfiguration.sol";
import "contracts/GenericInterface.sol";
import "contracts/Gold.sol";

contract GoldRegistry is GenericInterface {
 
  address config;

  Directory.AddressBoolMap entries;
  Directory.AddressAddressMap custodianPending;

  struct Asset {
    address vendor;
    address custodian;
    bytes32 vendorDoc;
    bytes32 custodianDoc;
  }

  mapping (address => Directory.AddressBoolMap) vendorAssets;
  mapping (address => Directory.AddressBoolMap) custodianAssets;
  mapping (address => Asset) registeredAssets;

  function GoldRegistry(address _conf) {
    config = _conf;
  }

  event AddGold(address indexed gold, address indexed vendor);
  event CustodianAssignment(address indexed gold, address indexed custodian, address indexed vendor);
  event RemoveGold(address indexed gold, address indexed custodian);

  function registerGold(address _gold, address _owner, bytes32 _doc) ifvendor {
    if (!Directory.insert(entries, _gold)) throw;
    if (!Directory.insert(vendorAssets[msg.sender], _gold)) throw;
    Asset _asset = registeredAssets[_gold];
    _asset.vendor = msg.sender;
    _asset.vendorDoc = _doc;
    Gold(_gold).register(_owner);
  }

  function isRegistered(address _gold) public returns (bool) {
    return Directory.contains(entries, _gold);
  }

  function isVendorOf(address _gold, address _vndr) public returns (bool) {
    return Directory.contains(vendorAssets[_vndr], _gold);
  }

  function isCustodianOf(address _gold, address _cstdn) public returns (bool) {
    return Directory.contains(custodianAssets[_cstdn], _gold);
  }

  function delegateCustodian(address _gold, address _cstdn) ifvendor {
    if (isVendorOf(_gold, msg.sender)) {
      if (!Directory.insert(custodianPending, _gold, _cstdn)) throw;
      CustodianAssignment(_gold, _cstdn, msg.sender);
    }
  }

  function receiveFromVendor(address _gold, bytes32 _doc) ifcustodian {
    if (Directory.containsAndMatches(custodianPending, _gold, msg.sender)) {
      if (!Directory.remove(custodianPending, _gold)) throw;
      if (!Directory.insert(custodianAssets[msg.sender], _gold)) throw; 
      Asset _asset = registeredAssets[_gold];
      _asset.custodian = msg.sender;
      _asset.custodianDoc = _doc;
      Gold(_gold).activate(); 
    }
  }

  function submitAudit(address _gold, bytes32 _doc, bool _passed) ifauditor {

  }

  function requestRedemption(address _gold) ifowner {

  }

  function markRedeemed(address _gold) ifcustodian {

  }

}
