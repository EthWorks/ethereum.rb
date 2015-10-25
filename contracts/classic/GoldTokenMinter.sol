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

contract GoldRegistry  {

  address owner;
  address participantregistry;

  enum GoldStatusCodes { PendingVerification, Active, RedemptionQueue, Redeemed, Minted }

  struct Audit {
    uint id;
    uint time;
    bool pass;
    address auditor;
    bytes32 extradata;
    bytes32 documentation;
  }

  struct GoldStatus {
    uint code;
    bool vendorverify;
    bool custodianverify;
    bool minted;
    uint auditcount;
    bool registered;
    uint lastauditid;
    Audit lastaudit;
    mapping (uint => Audit) audits;
  }

  struct GoldInfo {
    address vendor;
    address custodian;
    uint weight;
    bytes32 serial;
    bytes32 sku;
    bytes32 documentation;
  }

  struct GoldData {
    bool initialized;
    bool minted;
    uint weight;
    bytes32 serial;
    bytes32 sku;
    bytes32 documentation;
  }

  struct RegistryData {
    bool initialized;
    bool registered;
    address registry;
    address vendor;
    address custodian;
    address minter;
  }

  mapping (address => GoldStatus) goldstatusdb;
  mapping (address => GoldInfo) goldinfodb;

  modifier ifowner { if (msg.sender == owner) _ }

  event GoldPurchase(address indexed gold, address indexed buyer, uint weight);
  event GoldRedemption(address indexed gold);
  event VendorVerification(address indexed gold, address indexed vendor, uint indexed time);
  event CustodianVerification(address indexed gold, address indexed custodian, uint indexed time);
  event CustodianTransfer(address indexed gold, address indexed oldcustodian, address indexed newcustodian);
  event AuditEvent(address indexed gold, address indexed auditor, uint indexed lastauditid);

  function GoldRegistry() {
    owner = msg.sender;
  }

  function setConfiguration(address pr) ifowner {
    participantregistry = pr;
  }

  function getOwner() returns (address o) {
    o = owner;
  }

  function setOwner(address nown) ifowner {
    owner = nown;
  }

  function getParticipantRegistry() returns (address pr) {
    pr = participantregistry;
  }

  function checkCustodian() returns (bool ccheck) {
    ParticipantRegistry prg = ParticipantRegistry(participantregistry);
    ccheck = prg.isCustodian(tx.origin); 
  }

  function checkVendor() returns (bool vcheck) {
    ParticipantRegistry prg = ParticipantRegistry(participantregistry);
    vcheck = prg.isVendor(tx.origin);
  }

  function checkAuditor() returns (bool acheck) {
    ParticipantRegistry prg = ParticipantRegistry(participantregistry);
    acheck = prg.isAuditor(tx.origin);
  }

  function checkRegistrar() returns (bool rcheck) {
    ParticipantRegistry prg = ParticipantRegistry(participantregistry);
    rcheck = prg.isRegistrar(tx.origin);
  }

  modifier ifregistrar { if (checkRegistrar() == true) _ }
  modifier ifvendor { if (checkVendor() == true) _ }
  modifier ifcustodian { if (checkCustodian() == true) _ }
  modifier ifauditor { if (checkAuditor() == true) _ }

  function registerGold() ifregistrar {
    GoldInfo gidb = goldinfodb[msg.sender];
    GoldStatus gsdb = goldstatusdb[msg.sender];
    Gold gld = Gold(msg.sender);
    if (gsdb.registered == true) return;
    gidb.vendor = gld.registryRequestVendor();
    gidb.custodian = gld.registryRequestCustodian();
    gidb.weight = gld.registryRequestWeight();
    gidb.serial = gld.registryRequestSerialNumber();
    gidb.sku = gld.registryRequestSku();
    gidb.documentation = gld.registryRequestDocumentation();
    gsdb.vendorverify = false;
    gsdb.custodianverify = false;
    gsdb.minted = false;
    gsdb.registered = true;
  }

  function getGoldStatusCode(address gaddr) returns (uint gsc) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    gsc = gsdb.code;
  }

  function getGoldStatusVendorverify(address gaddr) returns (bool gsvv) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    gsvv = gsdb.vendorverify;
  }

  function getGoldStatusCustodianverify(address gaddr) returns (bool gscv) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    gscv = gsdb.custodianverify;
  }

  function getGoldStatusMinted(address gaddr) returns (bool gsms) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    gsms = gsdb.minted;
  }

  function getGoldStatusAuditcount(address gaddr) returns (uint gsac) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    gsac = gsdb.auditcount;
  }

  function getGoldStatusRegistered(address gaddr) returns (bool gsrs) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    gsrs = gsdb.registered;
  }

  function getGoldStatusLastauditid(address gaddr) returns (uint gsla) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    gsla = gsdb.lastauditid;
  }

  function getGoldInfoVendor(address gaddr) returns (address giva) {
    GoldInfo gidb = goldinfodb[gaddr];
    giva = gidb.vendor;
  }

  function getGoldInfoCustodian(address gaddr) returns (address gica) {
    GoldInfo gidb = goldinfodb[gaddr];
    gica = gidb.custodian;
  }

  function getGoldInfoWeight(address gaddr) returns (uint giwt) {
    GoldInfo gidb = goldinfodb[gaddr];
    giwt = gidb.weight;
  }

  function getGoldInfoSerial(address gaddr) returns (bytes32 gisn) {
    GoldInfo gidb = goldinfodb[gaddr];
    gisn = gidb.serial;
  }

  function getGoldInfoSku(address gaddr) returns (bytes32 gisk) {
    GoldInfo gidb = goldinfodb[gaddr];
    gisk = gidb.sku;
  }

  function getGoldInfoDocumentation(address gaddr) returns (bytes32 gidc) {
    GoldInfo gidb = goldinfodb[gaddr];
    gidc = gidb.documentation;
  }

  function getLastAuditId(address gaddr) returns (uint ai) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    Audit laud = gsdb.lastaudit;
    ai = laud.id;
  }

  function getLastAuditTime(address gaddr) returns (uint at) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    Audit laud = gsdb.lastaudit;
    at = laud.time;
  }

  function getLastAuditPass(address gaddr) returns (bool ap) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    Audit laud = gsdb.lastaudit;
    ap = laud.pass;
  }

  function getLastAuditAuditor(address gaddr) returns (address aa) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    Audit laud = gsdb.lastaudit;
    aa = laud.auditor;
  }

  function getLastAuditExtradata(address gaddr) returns (bytes32 ae) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    Audit laud = gsdb.lastaudit;
    ae = laud.extradata;
  }

  function getLastAuditDocumentation(address gaddr) returns (bytes32 ad) {
    GoldStatus gsdb = goldstatusdb[gaddr];
    Audit laud = gsdb.lastaudit;
    ad = laud.documentation;
  }

  function custodianVerify(address gaddr) ifcustodian {
    GoldStatus gsdb = goldstatusdb[gaddr];
    gsdb.custodianverify = true;
    CustodianVerification(gaddr, tx.origin, block.timestamp);
  }

  function vendorVerify(address gaddr) ifvendor {
    GoldStatus gsdb = goldstatusdb[gaddr];
    gsdb.vendorverify = true;
    VendorVerification(gaddr, tx.origin, block.timestamp);
  }

  function custodianTransfer(address gaddr, address ncaddr) ifcustodian {
    GoldInfo gidb = goldinfodb[gaddr];
    GoldStatus gsdb = goldstatusdb[gaddr];
    gidb.custodian = ncaddr;
    gsdb.custodianverify = false;
    CustodianTransfer(gaddr, tx.origin, ncaddr);
  }

  function auditReport(address gaddr, bool ares, bytes32 ed, bytes32 doc) ifauditor {
    GoldInfo gidb = goldinfodb[gaddr];
    GoldStatus gsdb = goldstatusdb[gaddr];
    gsdb.auditcount++;
    uint auditcount = gsdb.auditcount;
    Audit adt = gsdb.audits[auditcount];
    gsdb.lastaudit = Audit({id: auditcount, time: block.timestamp, pass: ares, auditor: tx.origin, extradata: ed, documentation: doc});
    adt = gsdb.lastaudit;
    AuditEvent(gaddr, tx.origin, auditcount);
  }

}

contract Gold {

  struct GoldData {
    bool initialized;
    bool minted;
    uint weight;
    bytes32 serial;
    bytes32 sku;
    bytes32 documentation;
  }

  struct RegistryData {
    bool initialized;
    bool registered;
    address registry;
    address vendor;
    address custodian;
    address minter;
  }

  address owner;
  GoldData golddata;
  RegistryData registrydata;

  event SendGoldEvent(address indexed gold, address indexed recipient);

  modifier ifowner { if (msg.sender == owner) _ }

  function Gold() {
    owner = msg.sender;
    golddata.minted = false;
    golddata.initialized = false;
    registrydata.initialized = false;
  }

  function getOwner() returns (address oaddr) {
    oaddr = owner;
  }

  function initGoldData(uint wt, bytes32 sn, bytes32 sk, bytes32 doc) ifowner {
    if (golddata.initialized == true) return;
    golddata = GoldData({initialized: true, minted: false, weight: wt, serial: sn, sku: sk, documentation: doc});
  }

  function initRegistryData(address raddr, address vaddr, address caddr) ifowner {
    if (registrydata.initialized == true) return;
    registrydata = RegistryData({initialized: true, registered: false, registry: raddr, vendor: vaddr, custodian: caddr, minter: address(this)});
    GoldRegistry goldregistry = GoldRegistry(raddr);
  }

  function sendRegistration() {
    if ((registrydata.initialized == true) && (golddata.initialized == true)) {
      GoldRegistry gr = goldRegistry();
      gr.registerGold();
      registrydata.registered = true;
    }
  }

  function registryRequestCustodian() public returns (address caddr) {
    caddr = registrydata.custodian;
  }

  function registryRequestVendor() public returns (address vaddr) {
    vaddr = registrydata.vendor;
  }

  function registryRequestWeight() public returns (uint wt) {
    wt = golddata.weight;
  }

  function registryRequestSerialNumber() public returns (bytes32 sn) {
    sn = golddata.serial;
  }

  function registryRequestSku() public returns (bytes32 sk) {
    sk = golddata.sku;
  }

  function registryRequestDocumentation() public returns (bytes32 doc) {
    doc = golddata.documentation;
  }

  function getGoldDataInitialized() returns (bool gdis) {
    gdis = golddata.initialized;
  }

  function getGoldDataMinted() returns (bool gdms) {
    gdms = golddata.minted;
  }

  function getGoldDataWeight() returns (uint gdwt) {
    gdwt = golddata.weight;
  }

  function getGoldDataSerial() returns (bytes32 gdsn) {
    gdsn = golddata.serial;
  }

  function getGoldDataSku() returns (bytes32 gdsk) {
    gdsk = golddata.sku;
  }

  function getGoldDataDocumentation() returns (bytes32 gddc) {
    gddc = golddata.documentation;
  }

  function getRegistryDataInitialized() returns (bool rdis) {
  rdis = registrydata.initialized;
  }
  
  function getRegistryDataRegistered() returns (bool rdrs) {
    rdrs = registrydata.registered;
  }
  
  function getRegistryDataRegistry() returns (address rdrg) {
    rdrg = registrydata.registry;
  }
  
  function getRegistryDataVendor() returns (address rdva) {
    rdva = registrydata.vendor;
  }
  
  function getRegistryDataCustodian() returns (address rdca) {
    rdca = registrydata.custodian;
  }
  
  function getRegistryDataMinter() returns (address rdma) {
    rdma = registrydata.minter;
  }

  function sendToMinter(uint minttype) ifowner {
    owner = registrydata.minter;
    golddata.minted = true;
    // Notifiy minter contract
  }

  function goldRegistry() returns (GoldRegistry gr) {
    gr = GoldRegistry(registrydata.registry);
  }


}


contract GoldTokenLedger {
    
    mapping (address => uint256) balances;

    address owner;
    address minter;

    modifier ifowner { if (msg.sender == owner) _ }
    modifier ifminter { if (msg.sender == minter) _ }

    event GoldTokenSendEvent(address indexed _sender, address indexed _recipient, uint _amount);
    event GoldTokenMintEvent(address indexed _goldcontract, address indexed _recipient, uint _amount);
    event SetMinterEvent(address indexed _minter, uint indexed _time);


    function GoldTokenLedger() {
        owner = msg.sender; 
    }

    function setMinter(address maddr) ifowner {
        minter = maddr;
        SetMinterEvent(maddr, block.timestamp);
    }

    function getMinter() returns (address maddr) {
        maddr = minter;
    }

    function getOwner() returns (address oaddr) {
        oaddr = owner;
    }

    function setOwner() returns (address oaddr) {
        oaddr = owner;
    }

    function getBalance(address user) returns (uint balance) {
        return balances[user];
    }

    function sendToken(uint256 amount, address recipient) {
        if (balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            balances[recipient] += amount;
            GoldTokenSendEvent(msg.sender, recipient, amount);
        }
    }

    function mint(uint256 amount, address recipient) ifminter {
        balances[recipient] += amount;
        GoldTokenMintEvent(msg.sender, recipient, amount);
    }

}


contract GoldTokenMinter {

  address owner;
  address ledger;
  uint basefeepermille;

  modifier onlyowner { if (msg.sender == owner) _ }
  
  event GoldMinterEvent(address indexed _g, address indexed _u, uint indexed _a);

  function GoldTokenMinter() {
     owner = msg.sender;
     basefeepermille = 13;
  }

  function setConfig(address laddr, uint fee) onlyowner {
     ledger = laddr;
     basefeepermille = fee;
  }

  function getLedger() returns (address) {
     return ledger;
  }

  function calculateAmount(address goldaddr) returns (uint amount) {
    Gold usergold = Gold(goldaddr);
    var goldweight = usergold.getGoldDataWeight();
    var weightpm = goldweight * 1000;
    var feepm = goldweight * basefeepermille;
    var feecalcpm = weightpm - feepm;
    var amountpm = feecalcpm / 10;
    amount = uint(amountpm);
  }

  function mint(address goldaddr) {
    GoldTokenLedger digixgoldledger = GoldTokenLedger(ledger);
    address recipient = msg.sender;
    uint amount = calculateAmount(goldaddr);
    if (amount <= 0)
      return;
    else
      digixgoldledger.mint(amount, recipient);
  }

}



//#include [ParticipantRegistry]
//#include [GoldRegistry]
//#include [Gold]
//#include [GoldTokenLedger]
//#include [GoldTokenMinter]
