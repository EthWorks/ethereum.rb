import "contracts/DigixConfiguration.sol";
import "contracts/Directory.sol";
import "contracts/VendorRegistry.sol";
import "contracts/CustodianRegistry.sol";
import "contracts/AuditorRegistry.sol";

contract GoldRegistry {
 
  address config;

  Directory.Data active;

  function GoldRegistry(address _conf) {
    config = _conf;
  }

  modifier ifvendor { if(isVendor(msg.sender)) _ }
  modifier ifcustodian { if(isCustodian(msg.sender)) _ }
  modifier ifauditor { if(isAuditor(msg.sender)) _ }

  function vendorRegistry() public returns (address) {
    return DigixConfiguration(config).getConfigEntry("registry/vendor");
  }

  function custodianRegistry() public returns (address) {
    return DigixConfiguration(config).getConfigEntry("registry/custodian");
  }
  
  function auditorRegistry() public returns (address) {
    return DigixConfiguration(config).getConfigEntry("registry/auditor");
  }

  function isVendor(address _vend) public returns (bool) {
    return VendorRegistry(vendorRegistry()).isVendor(_vend);
  }
  
  function isCustodian(address _cust) public returns (bool) {
    return CustodianRegistry(custodianRegistry()).isCustodian(_cust);
  }
  
  function isAuditor(address _audt) public returns (bool) {
    return AuditorRegistry(custodianRegistry()).isAuditor(_audt);
  }

  function registerGold(address _gold) {

  }

}
