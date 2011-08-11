import haxe.rtti.Generic;

class ValueNode<T> implements haxe.rtti.Generic {
  public var list:ValueList<T>;
  public var next:ValueNode<T>;
  public var prev:ValueNode<T>;
  public var value:T;
  public var _pool:ValueNodePool<T>;

  public function new(value:T, pool:ValueNodePool<T>=null) {
    _pool = pool;
    reset(value);
  }

  inline public function free() {
    if (list != null) {
      list.unlink(this);
      list = null;
    }
    next = null;
    prev = null;
    value = null;
    if (_pool != null) {
      _pool.put(this);
    }
  }

  inline public function reset(v:T) {
    list = null;
    next = null;
    prev = null;
    value = v;
  }
}
