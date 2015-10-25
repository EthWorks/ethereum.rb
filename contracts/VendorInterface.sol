import "contracts/Interface.sol";
import "contracts/Gold.sol";

contract VendorInterface is Interface {

  function VendorInterface(address _config) {
    owner = msg.sender;
    config = _config;
  }
  
  function registerGold(address _asset) ifemployee {
    var b = _asset;
  }

  function uploadReceipt(address _asset, bytes32 _ipfsHash) ifemployee {

  }

  function assignCustodian(address _asset, address _custodian) ifemployee {

  }

}


