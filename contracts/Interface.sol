import "contracts/GenericInterface.sol";

contract Interface is GenericInterface {

  address owner;

  Directory.AddressBoolMap employees;

  modifier ifowner { if(owner == msg.sender) _ }
  modifier ifemployee { if(isEmployee(msg.sender)) _ }
  modifier ifemployeeorigin { if(isEmployee(tx.origin)) _ }

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

}
