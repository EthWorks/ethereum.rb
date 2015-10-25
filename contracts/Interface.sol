import "contracts/VendorRegistry.sol";
import "contracts/CustodianRegistry.sol";
import "contracts/AuditorRegistry.sol";

contract Interface {

  address owner;
  address config;

  Directory.Data employees;

  modifier ifowner { if(owner == msg.sender) _ }
  modifier ifemployee { if(isEmployee(msg.sender)) _ }

  function registerEmployee(address _acct) ifowner {
    if (!Directory.insert(employees, _acct))
      throw;
  }

  function unregisterEmployee(address _acct) ifowner {
    if (!Directory.remove(employees, _acct))
      throw;
  }

  function isEmployee(address _acct) public returns (bool) {
    return Directory.contains(employees, _acct);
  }

  function goldRegistry() public returns (address) {
    return DigixConfiguration(config).getConfigEntry("registry/gold");
  }
  
  function vendorRegistry() public returns (address) {
    return DigixConfiguration(config).getConfigEntry("registry/vendor");
  }
  
  function custodianRegistry() public returns (address) {
    return DigixConfiguration(config).getConfigEntry("registry/custodian");
  }
  
  function auditorRegistry() public returns (address) {
    return DigixConfiguration(config).getConfigEntry("registry/auditor");
  }

  function isCustodian(address _cust) public returns (bool) {
    return CustodianRegistry(custodianRegistry()).isCustodian(_cust);
  }

  function isAuditor(address _adtr) public returns (bool) {
    return AuditorRegistry(auditorRegistry()).isAuditor(_adtr);
  }

  function isVendor(address _vndr) public returns (bool) {
    return VendorRegistry(vendorRegistry()).isVendor(_vndr);
  }

}
