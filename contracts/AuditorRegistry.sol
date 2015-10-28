contract AuditorRegistry {

  address config;
  Directory.AddressBoolMap auditors;

  function CustodianRegistry(address _conf) {
    config = _conf;
  }

  function isAuditor(address _audt) public returns (bool) {
    return Directory.contains(auditors, _audt);
  }
}

