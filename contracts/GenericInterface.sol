import "contracts/Directory.sol";
import "contracts/DoublyLinked.sol";
import "contracts/DigixConfiguration.sol";
import "contracts/VendorRegistry.sol";
import "contracts/CustodianRegistry.sol";
import "contracts/AuditorRegistry.sol";

contract GenericInterface {

  address config;
  address owner;

  function getConfigAddress() public returns (address) {
    return config;
  }

  function goldRegistry() public returns (address) {
    return DigixConfiguration(config).getConfigEntryAddr("registry/gold");
  }
  
  function vendorRegistry() public returns (address) {
    return DigixConfiguration(config).getConfigEntryAddr("registry/vendor");
  }
  
  function custodianRegistry() public returns (address) {
    return DigixConfiguration(config).getConfigEntryAddr("registry/custodian");
  }
  
  function auditorRegistry() public returns (address) {
    return DigixConfiguration(config).getConfigEntryAddr("registry/auditor");
  }

  function isGoldRegistry(address _greg) public returns (bool) {
    return (goldRegistry() == _greg);
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


  modifier ifvendor { if(isVendor(msg.sender)) _ }
  modifier ifowner { if(msg.sender == owner) _ }
  modifier ifcustodian { if(isCustodian(msg.sender)) _ }
  modifier ifauditor { if(isAuditor(msg.sender)) _ }
  modifier ifgoldregistry { if(isGoldRegistry(msg.sender)) _ }

}
