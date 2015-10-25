import "contracts/Interface.sol";

contract CustodianInterface is Interface {

  function CustodianInterface(address _config) {
    owner = msg.sender;
    config = _config;
  }
  
  function publishReceipt(address _gold, bytes32 _file) ifemployee {
    
  }

  function isRedeemable(address _gold) public returns (bool) {
    return true;
  }

}




