package;

/**
 * A signal class, inspired by Robert Penner's as3-signals, but lighter
 * weight for use with FlashPunk.
 * 
 *    var onHurt:Signal = new Signal();
 *    onHurt.add(function(damage:Number):Void {
 *      trace(damage, 'damage?! ouch!');
 *    });
 *    onHurt.dispatch(42);  // calls the listener
 */
class Signal<T> {
  var _dispatching:Bool;
  var _listenerHead:SignalListener;
  var _listenerTail:SignalListener;
  var _removed:Array<SignalListener>;

  /**
   * Constructor.
   */
  public function new() {
    _dispatching = false;
    _listenerHead = null;
    _listenerTail = null;
    _removed = null;
  }

  /**
   * Add a listener to this signal.
   * @param listener Function to add.
   */
  inline public function add(listener:T):Void {
    if (find(listener) == null) {
      var sl:SignalListener = new SignalListener();
      sl.added = true;
      sl.listener = listener;
      sl.prev = _listenerTail;
      sl.next = null;
      if (_listenerHead == null) {
        _listenerHead = sl;
        _listenerTail = sl;
      } else {
        _listenerTail.next = sl;
        _listenerTail = sl;
      }
    }
  }

  /**
   * Find a the SignalListener for a listener function on this signal.
   * @param listener Function to find.
   * @return Matching SignalListener, or null if the function wasn't a listener on this signal.
   */
  inline public function find(listener:T):SignalListener {
    var sl:SignalListener = _listenerHead;
    while (sl != null) {
      if (sl.listener == listener) {
        break;
      }
      sl = sl.next;
    }
    return sl;
  }

  /**
   * Remove a listener from this signal.
   * @param listener Function to remove.
   */
  inline public function remove(listener:T):Void {
    var sl:SignalListener = find(listener);
    if (sl != null) {
      _remove(sl);
    }
  }

  /**
   * Remove all listeners from this signal.
   */
  inline public function removeAll():Void {
    var sl:SignalListener = _listenerHead;
    while (sl != null) {
      var sln:SignalListener = sl.next;
      _remove(sl);
      sl = sln;
    }
    _listenerHead = _listenerTail = null;
  }

  /**
   * Trigger this signal, invoking all of the listeners in the order they were added.
   * @param args Arguments to pass along to the listeners.
   */
  public function dispatch(args:Array<Dynamic> = null):Void {
    _dispatching = true;
    var sl:SignalListener = _listenerHead;
    // This is split up for performance
    var numArgs:Int = args == null ? 0 : args.length;
    if (numArgs == 0) {
      while (sl != null) {
        if (sl.added) {
          sl.listener();
        }
        sl = sl.next;
      }
    } else if (numArgs == 1) {
      var arg:Dynamic = args[0];
      while (sl != null) {
        if (sl.added) {
          sl.listener(arg);
        }
        sl = sl.next;
      }
    } else if (numArgs == 2) {
      var arg1:Dynamic = args[0];
      var arg2:Dynamic = args[1];
      while (sl != null) {
        if (sl.added) {
          sl.listener(arg1, arg2);
        }
        sl = sl.next;
      }
    } else {
      while (sl != null) {
        if (sl.added) {
          Reflect.callMethod(null, sl.listener, args);
        }
        sl = sl.next;
      }
    }
    _dispatching = false;
    if (_removed != null && _removed.length > 0) {
      var i:Int = _removed.length;
      while (i-- > 0) {
        _remove(_removed[i]);
      }
      _removed = null;
    }
  }

  /**
   * Remove a signal listener, or mark it for removal if a dispatch is in progress.
   * @param sl Signal listener to remove from the linked list.
   */
  inline function _remove(sl:SignalListener):Void {
    if (sl != null) {
      if (_dispatching && sl.added) {
        if (_removed == null) {
          _removed = [sl];
        } else {
          _removed[_removed.length] = sl;
        }
        sl.added = false;
      } else {
        if (sl == _listenerHead) {
          _listenerHead = sl.next;
        }
        if (sl == _listenerTail) {
          _listenerTail = sl.prev;
        }
        if (sl.prev != null) {
          sl.prev.next = sl.next;
        }
        if (sl.next != null) {
          sl.next.prev = sl.prev;
        }
        sl.next = sl.prev = null;
        sl.listener = null;
        sl.added = false;
      }
    }
  }
}
