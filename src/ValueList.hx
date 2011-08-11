package;

import haxe.rtti.Generic;

/**
* A generic linked list class that supports object pooling.
*/
class ValueList<T> implements haxe.rtti.Generic {
  public var first:ValueNode<T>;
  public var _next:ValueList<T>;
  public var _pool:ValueListPool<T>;
  public var _nodePool:ValueNodePool<T>;

  public function new(nodePool:ValueNodePool<T>=null, pool:ValueListPool<T>=null) {
    _nodePool = nodePool;
    _pool = pool;
    reset();
  }

  /**
  * Add a value to the front of the list. This will add the value even if the
  * value already exists in the list.
  */
  inline public function add(value:T):ValueNode<T> {
    var node;
    if (_nodePool != null) {
      node = _nodePool.create(value);
    } else {
      node = new ValueNode<T>(value);
    }
    if (first != null) {
      first.prev = node;
    }
    node.list = this;
    node.next = first;
    node.prev = null;
    first = node;
    return node;
  }

  /**
  * Remove all values from the list.
  */
  inline public function clear() {
    var node = first;
    while (node != null) {
      var next = node.next;
      node.free();
      node = next;
    }
    first = null;
  }

  /**
  * Remove all values from the list, and recycle the list.
  */
  inline public function free() {
    clear();
    if (_pool != null) {
      _pool.put(this);
    }
  }

  /**
  * Return true if the value exists in the list. This is an O(n) search.
  */
  inline public function has(value:T):Bool {
    var node = first;
    var result = false;
    while (node != null) {
      var next = node.next;
      if (node.value == value) {
        result = true;
        break;
      }
      node = next;
    }
    return result;
  }

  /**
  * Remove a value from the list. If more than one node points to this value,
  * all nodes will be removed.
  */
  inline public function remove(value:T) {
    var node = first;
    while (node != null) {
      var next = node.next;
      if (node.value == value) {
        unlink(node);
        node.free();
      }
      node = next;
    }
  }

  /**
  * Remove the value at the front of the list and return it, or return null
  * if the list is empty.
  */
  inline public function shift():T {
    var node = first;
    if (node != null) {
      var value = node.value;
      if (node.next != null) {
        node.next.prev = null;
      }
      first = node.next;
      node.list = null;
      node.free();
      return value;
    } else {
      return null;
    }
  }

  inline public function unlink(node:ValueNode<T>) {
    if (node.list == this) {
      if (node.next != null) {
        node.next.prev = node.prev;
      }
      if (node.prev != null) {
        node.prev.next = node.next;
      }
      if (first == node) {
        first = node.next;
      }
      node.list = null;
      node.next = null;
      node.prev = null;
    }
  }

  inline public function reset() {
    first = null;
    _next = null;
  }
}