package;

private typedef CollideFunction = Dynamic -> Bool;

class Hitbox {
  public var entity:Entity;
  public var halfWidth(getHalfWidth, setHalfWidth):Float;
  public var halfHeight(getHalfHeight, setHalfHeight):Float;
  public var minX(getMinX, never):Float;
  public var minY(getMinY, never):Float;
  public var maxX(getMaxX, never):Float;
  public var maxY(getMaxY, never):Float;
  public var width(getWidth, never):Float;
  public var height(getHeight, never):Float;
  public var x(getX, setX):Float;
  public var y(getY, setY):Float;
  var _class:String;
  var _collideFuncs:Hash<CollideFunction>;
  var _halfWidth:Float;
  var _halfHeight:Float;
  var _minX:Float;
  var _minY:Float;
  var _maxX:Float;
  var _maxY:Float;
  var _width:Float;
  var _height:Float;
  var _x:Float;
  var _y:Float;

  public function new(halfWidth:Float, halfHeight:Float, x:Float=0, y:Float=0) {
    this.halfWidth = halfWidth;
    this.halfHeight = halfHeight;
    this.x = x;
    this.y = y;
    _class = Type.getClassName(Type.getClass(this));
    _collideFuncs = new Hash<CollideFunction>();
    _collideFuncs.set(Type.getClassName(Hitbox), collideHitboxHitbox);
  }

  public function collide(other:Hitbox):Bool {
    var func = _collideFuncs.get(other._class);
    if (func != null) {
      return func(other);
    } else {
      func = other._collideFuncs.get(_class);
      if (func != null) {
        return func(this);
      }
    }
    return false;
  }

  inline public function set(halfWidth:Float, halfHeight:Float, ?x:Float, ?y:Float) {
    this.halfWidth = halfWidth;
    this.halfHeight = halfHeight;
    this.x = x == null ? halfWidth : x;
    this.y = y == null ? halfHeight : y;
  }

  function collideHitboxHitbox(other:Hitbox):Bool {
    return (
      entity.x + maxX > other.entity.x + other.minX &&
      entity.y + maxY > other.entity.y + other.minY &&
      entity.x + minX < other.entity.x + other.maxX &&
      entity.y + minY < other.entity.y + other.maxY);
  }

  inline function getHalfWidth():Float {
    return _halfWidth;
  }

  inline function setHalfWidth(value:Float):Float {
    _halfWidth = value;
    _width = value * 2;
    _minX = _x - _halfWidth;
    _maxX = _x + _halfWidth;
    return value;
  }

  inline function getHalfHeight():Float {
    return _halfHeight;
  }

  inline function setHalfHeight(value:Float):Float {
    _halfHeight = value;
    _height = value * 2;
    _minY = _y - _halfHeight;
    _maxY = _y + _halfHeight;
    return value;
  }

  inline function getWidth():Float {
    return _width;
  }

  inline function getHeight():Float {
    return _height;
  }

  inline function getMinX():Float {
    return _minX;
  }

  inline function getMinY():Float {
    return _minY;
  }

  inline function getMaxX():Float {
    return _maxX;
  }

  inline function getMaxY():Float {
    return _maxY;
  }

  inline function getX():Float {
    return _x;
  }

  inline function setX(value:Float):Float {
    _x = value;
    _minX = _x - _halfWidth;
    _maxX = _x + _halfWidth;
    return value;
  }

  inline function getY():Float {
    return _y;
  }

  inline function setY(value:Float):Float {
    _y = value;
    _minY = _y - _halfHeight;
    _maxY = _y + _halfHeight;
    return value;
  }
}
