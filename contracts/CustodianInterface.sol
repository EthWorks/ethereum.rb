import "contracts/Interface.sol";
import "contracts/Gold.sol";
import "contracts/GoldRegistry.sol";

contract CustodianInterface is Interface {

  function CustodianInterface(address _config) {
    owner = msg.sender;
    config = _config;
  }

  function receiveFromVendor(address _gold, bytes32 _doc) ifemployee {
    GoldRegistry(goldRegistry()).receiveFromVendor(_gold, _doc);
  }

  function transferCustodian(address _gold, address _cstdn) ifemployee {
  }
  
  function isRedeemable(address _gold) public returns (bool) {
    return true;
  }

}




