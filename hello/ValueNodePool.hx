package hello;

import haxe.rtti.Generic;

/**
* Object pool for recycling ValueNode objects.
*/
class ValueNodePool<T> implements Generic  {
  public var _first:ValueNode<T>;

  public function new() {
    _first = null;
  }

  /**
  * Create a new node (reusing a node from the pool, if possible).
  */
  inline public function create(value:T):ValueNode<T> {
    if (_first != null) {
      var node = _first;
      _first = node.next;
      node.reset(value);
      return node;
    } else {
      return new ValueNode<T>(value, this);
    }
  }

  /**
  * Put a node into the pool for reuse.
  */
  inline public function put(list:ValueNode<T>) {
    list.next = _first;
    _first = list;
  }
}
