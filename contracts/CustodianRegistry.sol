import "contracts/Directory.sol";
import "contracts/GenericRegistry.sol";

contract CustodianRegistry is GenericRegistry {

  Directory.AddressBoolMap custodians;

  struct Custodian {
    bytes32 name;
  }

  mapping (address => Custodian) custodianNames;

  function CustodianRegistry(address _conf) {
    config = _conf;
  }
  
  function register(address _acct) ifadmin {
    if (!Directory.insert(custodians, _acct))
      throw;
  }

  function unregister(address _acct) ifadmin {
    if (!Directory.remove(custodians, _acct))
      throw;
  }

  function setCustodianName(address _cstdn, bytes32 _name) ifadmin {
    custodianNames[_cstdn].name = _name;
  }

  function getCustodianName(address _cstdn) public returns (bytes32) {
    return custodianNames[_cstdn].name;
  }

  function isCustodian(address _cust) public returns (bool) {
    return Directory.contains(custodians, _cust);
  }

}
