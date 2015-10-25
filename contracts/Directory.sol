library Directory {

  struct Data { mapping(address => bool) entries; }

  function insert(Data storage self, address acct) returns (bool) {
    if (self.entries[acct])
      return false; 
    self.entries[acct] = true;
    return true;
  }

  function remove(Data storage self, address acct) returns (bool) {
    if (!self.entries[acct])
      return false;
    self.entries[acct] = false;
    return true;
  }

  function contains(Data storage self, address acct) returns (bool) {
    return self.entries[acct];
  }

}


