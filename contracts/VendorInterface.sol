import "contracts/Interface.sol";
import "contracts/Gold.sol";
import "contracts/GoldRegistry.sol";
import "contracts/DoublyLinked.sol";

contract VendorInterface is Interface {

  DoublyLinked.List openOrders;

  enum OrderStatus { Open, Cancelled, Completed }

  struct Order {
    bytes32 sku;
    address buyer;
    uint status;
  }

  mapping (bytes32 => Order) orders;

  function VendorInterface(address _config) {
    owner = msg.sender;
    config = _config;
  }
  
  function registerGold(address _asset, address _owner, bytes32 _doc) ifemployee {
    GoldRegistry(goldRegistry()).registerGold(_asset, _owner, _doc);
  }

  function delegateCustodian(address _asset, address _cstdn) ifemployee {
    GoldRegistry(goldRegistry()).delegateCustodian(_asset, _cstdn);
  }

  function append(bytes32 _data) {
    DoublyLinked.append(openOrders, _data);
  }

  function createOrder(bytes32 _orderId, bytes32 _sku, address _buyer) {
    Order _order = orders[_orderId];
    _order.sku = _sku;
    _order.buyer = _buyer;
    _order.status = uint(OrderStatus.Open);
    DoublyLinked.append(openOrders, _orderId);
  }

  function start() returns (uint80) {
    return DoublyLinked.iterate_start(openOrders);
  }

  function getOrder(uint80 _idx) returns (bytes32 _orderId, bytes32 _sku, address _buyer) {
    _orderId = DoublyLinked.iterate_get(openOrders, _idx);
    _sku = orders[_orderId].sku;
    _buyer = orders[_orderId].buyer;
  }

  function next(uint80 _idx) returns(uint80) {
    return DoublyLinked.iterate_next(openOrders, _idx);
  }
    
  function valid(uint80 _idx) returns(bool) {
    return DoublyLinked.iterate_valid(openOrders, _idx);
  }

  function prev(uint80 _idx) returns(uint80) {
    return DoublyLinked.iterate_prev(openOrders, _idx);
  }

  function processOrder(bytes32 _orderId) returns (bool success) {
    var it = DoublyLinked.iterate_start(openOrders);
    while (DoublyLinked.iterate_valid(openOrders, it)) {
      if (DoublyLinked.iterate_get(openOrders, it) == _orderId) {
        DoublyLinked.remove(openOrders, it);
        orders[_orderId].status = uint(OrderStatus.Completed);
        return true;
      }
      it = DoublyLinked.iterate_next(openOrders, it);
    }
    return false;
  }

}


