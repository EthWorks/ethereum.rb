library Directory {

  struct AddressBytesMap { mapping(address => bytes32) bytesentries; }

  struct AddressAddressMap { mapping(address => address) addrentries; }

  struct AddressBoolMap { mapping(address => bool) boolentries; }

  function insert(AddressBytesMap storage self, address key, bytes32 val) returns (bool) {
    if (self.bytesentries[key] == val) return false;
    self.bytesentries[key] = val;
    return true;
  }

  function insert(AddressBoolMap storage self, address key) returns (bool) {
    if (self.boolentries[key]) return false; 
    self.boolentries[key] = true;
    return true;
  }

  function insert(AddressAddressMap storage self, address key, address val) returns (bool) {
    if (self.addrentries[key] == val) return false;
    self.addrentries[key] = val;
    return true;
  }

  function remove(AddressBytesMap storage self, address key) returns (bool) {
    if (self.bytesentries[key] == 0x0) return false;
    self.bytesentries[key] = 0x0;
    return true;
  }

  function remove(AddressBoolMap storage self, address key) returns (bool) {
    if (!self.boolentries[key]) return false;
    self.boolentries[key] = false;
    return true;
  }

  function remove(AddressAddressMap storage self, address key) returns (bool) {
    if (self.addrentries[key] == 0x0000000000000000000000000000000000000000) return false;
    self.addrentries[key] = 0x0000000000000000000000000000000000000000;
    return true;
  }
  
  function contains(AddressBytesMap storage self, address key) returns (bool) {
    if (self.bytesentries[key] != 0x0) return true;
  }

  function contains(AddressBoolMap storage self, address key) returns (bool) {
    return self.boolentries[key];
  }

  function contains(AddressAddressMap storage self, address key) returns (bool) {
    if (self.addrentries[key] != 0x0000000000000000000000000000000000000000) return true;
  }
  
  function containsAndMatches(AddressBytesMap storage self, address key, bytes32 val) returns (bool) {
    return (self.bytesentries[key] == val);
  }

  function containsAndMatches(AddressAddressMap storage self, address key, address val) returns (bool) {
    return (self.addrentries[key] == val);
  }

}


