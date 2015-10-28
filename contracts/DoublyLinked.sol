library DoublyLinked {

    struct List {
        uint80 first;
        uint80 last;
        uint80 count;
        Item[] items;
    }

    uint80 constant None = uint80(-1);

    struct Item {
        uint80 prev;
        uint80 next;
        bytes32 data;
    }
    
    function append(List storage self, bytes32 _data) {
        var index = self.items.push(Item({prev: self.last, next: None, data: _data}));
        if (self.last == None)
        {
            if (self.first != None || self.count != 0) throw;
            self.first = self.last = uint80(index - 1);
            self.count = 1;
        }
        else
        {
            self.items[self.last].next = uint80(index - 1);
            self.last = uint80(index - 1);
            self.count ++;
        }
    }

    function remove(List storage self, uint80 _index) {
        Item item = self.items[_index];
        if (item.prev == None)
            self.first = item.next;
        if (item.next == None)
            self.last = item.prev;
        if (item.prev != None)
            self.items[item.prev].next = item.next;
        if (item.next != None)
            self.items[item.next].prev = item.prev;
        delete self.items[_index];
        self.count++;
    }

    // Iterator interface
    function iterate_start(List storage self) returns (uint80) { return self.first; }
    function iterate_valid(List storage self, uint80 _index) returns (bool) { return _index < self.items.length; }
    function iterate_prev(List storage self, uint80 _index) returns (uint80) { return self.items[_index].prev; }
    function iterate_next(List storage self, uint80 _index) returns (uint80) { return self.items[_index].next; }
    function iterate_get(List storage self, uint80 _index) returns (bytes32) { return self.items[_index].data; }
}
