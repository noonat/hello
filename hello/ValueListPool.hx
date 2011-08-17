package hello;

import haxe.rtti.Generic;

/**
* Object pool for recycling ValueList objects.
*/
class ValueListPool<T> implements haxe.rtti.Generic {
  public var _first:ValueList<T>;
  public var _nodePool:ValueNodePool<T>;

  public function new(nodePool:ValueNodePool<T>=null) {
    _first = null;
    _nodePool = nodePool;
  }

  /**
  * Create a new list (reusing a list from the pool, if possible).
  */
  inline public function create():ValueList<T> {
    if (_first != null) {
      var list = _first;
      _first = list._next;
      list.reset();
      return list;
    } else {
      return new ValueList<T>(_nodePool, this);
    }
  }

  /**
  * Put a list into the pool for reuse.
  */
  inline public function put(list:ValueList<T>) {
    list._next = _first;
    _first = list;
  }
}
