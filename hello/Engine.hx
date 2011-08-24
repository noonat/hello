package hello;

import flash.Lib;

class Engine {
  static public inline var MAX_ELAPSED:Float = 1.0 / 20.0;
  public var elapsed:Float;
  public var time:Float;
  public var width:Int;
  public var height:Int;
  var _pendingWorld:World;
  var _world:World;

  public var world(getWorld, setWorld):World;
  inline function getWorld():World return _world
  inline function setWorld(value:World):World {
    return _pendingWorld = value;
  }

  public function new() {
    elapsed = 0;
    time = Lib.getTimer() / 1000.0;
  }

  public function tick() {
    var newTime = Lib.getTimer() / 1000.0;
    elapsed = Lo.min(newTime - time, MAX_ELAPSED);
    time = newTime;
    if (_world != null) {
      _world.tick();
    }
    if (_pendingWorld != null) {
      if (_world != null) {
        _world.end();
      }
      _world = _pendingWorld;
      _pendingWorld = null;
      _world.begin();
    }
  }
}
