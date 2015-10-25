contract ParticipantRegistry {

  enum ParticipantTypes { Admin, Vendor, Custodian, Auditor }
  struct ParticipantDatabase {
    mapping (address => bool) auditors;
    mapping (address => bool) vendors;
    mapping (address => bool) custodians;
    mapping (address => bool) registrars;
  }

  address owner;
  ParticipantDatabase participantdb;

  event AddParticipant(address indexed participant, uint indexed participanttype);
  event RemoveParticipant(address indexed participant, uint indexed participanttype);

  modifier ifowner { if (msg.sender == owner) _ }
  modifier ifregistrar { if ((participantdb.registrars[tx.origin]) || (tx.origin == owner)) _ }
  modifier onlyvendor { if (isVendor(tx.origin) == true) _ }
  modifier onlycustodian { if (isCustodian(tx.origin) == true) _ }
  modifier onlyauditor { if (isAuditor(tx.origin) == true) _ }

  function ParticipantRegistry() {
    owner = msg.sender;
  }

  function getOwner() returns (address oa) {
    oa = owner;
  }

  function setOwner(address nown) ifowner {
    owner = nown;
  }

  function registerAdmin(address regraddr) ifowner {
    participantdb.registrars[regraddr] = true;
    AddParticipant(regraddr, uint(ParticipantTypes.Admin));
  }

  function unregisterAdmin(address regraddr) ifowner {
    participantdb.registrars[regraddr] = false;
    RemoveParticipant(regraddr, uint(ParticipantTypes.Admin));
  }

  function registerVendor(address vendoraddress) ifregistrar {
    participantdb.vendors[vendoraddress] = true;
    AddParticipant(vendoraddress, uint(ParticipantTypes.Vendor));
  }

  function unregisterVendor(address vendoraddress) ifregistrar {
    participantdb.vendors[vendoraddress] = false;
    RemoveParticipant(vendoraddress, uint(ParticipantTypes.Vendor));
  }

  function registerCustodian(address custodianaddress) ifregistrar {
    participantdb.custodians[custodianaddress] = true;
    AddParticipant(custodianaddress, uint(ParticipantTypes.Custodian));
  }

  function unregisterCustodian(address custodianaddress) ifregistrar {
    participantdb.custodians[custodianaddress] = false;
    RemoveParticipant(custodianaddress, uint(ParticipantTypes.Custodian));
  }

  function registerAuditor(address auditoraddress) ifregistrar {
    participantdb.auditors[auditoraddress] = true;
    AddParticipant(auditoraddress, uint(ParticipantTypes.Auditor));
  }

  function unregisterAuditor(address auditoraddress) ifregistrar {
    participantdb.auditors[auditoraddress] = false;
    RemoveParticipant(auditoraddress, uint(ParticipantTypes.Auditor));
  }

  function isVendor(address vendoraddress) returns (bool) {
    return participantdb.vendors[vendoraddress];
  }

  function isCustodian(address custodianaddress) returns (bool) {
    return participantdb.custodians[custodianaddress];
  }

  function isAuditor(address auditoraddress) returns (bool) {
    return participantdb.auditors[auditoraddress];
  }

  function isRegistrar(address regraddr) returns (bool) {
    return participantdb.registrars[regraddr];
  }
}



//#include [ParticipantRegistry]
