import "contracts/GenericRegistry.sol";

contract VendorRegistry is GenericRegistry {

  Directory.AddressBoolMap vendors;

  struct Vendor {
    bytes32 name;
  }

  mapping (address => Vendor) vendorNames;
  
  function VendorRegistry(address _conf) {
    config = _conf;
  }

  function register(address _acct) ifadmin {
    if (!Directory.insert(vendors, _acct))
      throw;
  }

  function unregister(address _acct) ifadmin {
    if (!Directory.remove(vendors, _acct))
      throw;
  }

  function isVendor(address _acct) public returns (bool) {
    return Directory.contains(vendors, _acct);
  }

  function setVendorName(address _vendor, bytes32 _name) ifadmin {
    vendorNames[_vendor].name = _name;
  }

  function getVendorName(address _vendor) public returns (bytes32) {
    return vendorNames[_vendor].name;
  }

}
