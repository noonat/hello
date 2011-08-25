package hello;

/**
 * A signal class, inspired by Robert Penner's as3-signals, but lighter
 * weight for use with FlashPunk.
 *
 *    var onHurt:Signal = new Signal();
 *    onHurt.add(function(damage:Number) {
 *      trace(damage, 'damage?! ouch!');
 *    });
 *    onHurt.dispatch(42);  // calls the listener
 */
class Signal<T> {
  public var hasListeners(getHasListeners, never):Bool;
  var _isDispatching:Bool;
  var _listenerHead:SignalListener;
  var _listenerTail:SignalListener;
  var _removed:Array<SignalListener>;

  /**
   * Constructor.
   */
  public function new() {
    _isDispatching = false;
    _listenerHead = null;
    _listenerTail = null;
    _removed = [];
  }

  /**
   * Add a listener to this signal.
   * @param listener Function to add.
   */
  inline public function add(listener:T) {
    if (find(listener) == null) {
      var node = new SignalListener();
      node.isActive = true;
      node.listener = listener;
      node.prev = _listenerTail;
      node.next = null;
      if (_listenerHead == null) {
        _listenerHead = node;
        _listenerTail = node;
      } else {
        _listenerTail.next = node;
        _listenerTail = node;
      }
    }
  }

  /**
   * Find a the SignalListener for a listener function on this signal.
   * @param listener Function to find.
   * @return Matching SignalListener, or null if the function wasn't a listener on this signal.
   */
  inline public function find(listener:T):SignalListener {
    var node = _listenerHead;
    while (node != null) {
      if (node.listener == listener) {
        break;
      }
      node = node.next;
    }
    return node;
  }

  /**
   * Remove a listener from this signal.
   * @param listener Function to remove.
   */
  inline public function remove(listener:T) {
    var node = find(listener);
    if (node != null) {
      removeNode(node);
    }
  }

  /**
   * Remove all listeners from this signal.
   */
  inline public function removeAll() {
    var node = _listenerHead;
    while (node != null) {
      var next = node.next;
      removeNode(node);
      node = next;
    }
    _listenerHead = _listenerTail = null;
  }

  /**
   * Trigger this signal, invoking all of the listeners in the order they were added.
   * @param args Arguments to pass along to the listeners.
   */
  public function dispatch(args:Array<Dynamic>=null) {
    removeMarkedNodes();
    _isDispatching = true;
    // This is split up for performance
    var numArgs = args == null ? 0 : args.length;
    if (numArgs == 0) {
      dispatch0();
    } else if (numArgs == 1) {
      dispatch1(args[0]);
    } else if (numArgs == 2) {
      dispatch2(args[0], args[1]);
    } else {
      var node = _listenerHead;
      while (node != null) {
        if (node.isActive) {
          Reflect.callMethod(null, node.listener, args);
        }
        node = node.next;
      }
    }
    _isDispatching = false;
    removeMarkedNodes();
  }

  inline public function dispatch0() {
    var node = _listenerHead;
    while (node != null) {
      if (node.isActive) {
        node.listener();
      }
      node = node.next;
    }
  }

  inline public function dispatch1(arg:Dynamic) {
    var node = _listenerHead;
    while (node != null) {
      if (node.isActive) {
        node.listener(arg);
      }
      node = node.next;
    }
  }

  inline public function dispatch2(arg1:Dynamic, arg2:Dynamic) {
    var node = _listenerHead;
    while (node != null) {
      if (node.isActive) {
        node.listener(arg1, arg2);
      }
      node = node.next;
    }
  }

  /**
   * Remove a signal listener, or mark it for removal if a dispatch is in progress.
   * @param sl Signal listener to remove from the linked list.
   */
  inline function removeNode(node:SignalListener) {
    if (node != null) {
      if (_isDispatching && node.isActive) {
        _removed[_removed.length] = node;
        node.isActive = false;
      } else {
        if (node == _listenerHead) {
          _listenerHead = node.next;
        }
        if (node == _listenerTail) {
          _listenerTail = node.prev;
        }
        if (node.prev != null) {
          node.prev.next = node.next;
        }
        if (node.next != null) {
          node.next.prev = node.prev;
        }
        node.next = null;
        node.prev = null;
        node.listener = null;
        node.isActive = false;
      }
    }
  }

  /**
  * Remove any nodes that were previously marked for removal.
  */
  inline function removeMarkedNodes() {
    if (_removed.length > 0) {
      var node:SignalListener;
      while ((node = _removed.pop()) != null) {
        removeNode(node);
      }
    }
  }

  inline function getHasListeners():Bool {
    return _listenerHead != null;
  }
}
