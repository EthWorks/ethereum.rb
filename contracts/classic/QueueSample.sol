////////////////////////////////////////////////////////////
// This is an example contract hacked together at a meetup.
// It is by far not complete and only used to show some
// features of Solidity.
////////////////////////////////////////////////////////////
contract QueueContract
{
    struct Queue {
        uint[] data;
        uint front;
        uint back;
    }
    /// @dev the number of elements stored in the queue.
    function length(Queue storage q) constant internal returns (uint) {
        return q.back - q.front;
    }
    /// @dev the number of elements this queue can hold
    function capacity(Queue storage q) constant internal returns (uint) {
        return q.data.length - 1;
    }
    /// @dev push a new element to the back of the queue
    function push(Queue storage q, uint data) internal
    {
        if ((q.back + 1) % q.data.length == q.front)
            return; // throw;
        q.data[q.back] = data;
        q.back = (q.back + 1) % q.data.length;
    }
    /// @dev remove and return the element at the front of the queue
    function pop(Queue storage q) internal returns (uint r)
    {
        if (q.back == q.front)
            return; // throw;
        r = q.data[q.front];
        delete q.data[q.front];
        q.front = (q.front + 1) % q.data.length;
    }
}

contract QueueUserMayBeDeliveryDroneCotnrol is QueueContract {
    Queue requests;
    function QueueUserMayBeDeliveryDroneCotnrol() {
        requests.data.length = 200;
    }
    function addRequest(uint d) {
        push(requests, d);
    }
    function popRequest() returns (uint) {
        return pop(requests);
    }
    function queueLength() returns (uint) {
        return length(requests);
    }
}
