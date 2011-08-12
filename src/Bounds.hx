/**
* Base class for all bounding volumes. This class cannot be instantiated
* directly. Instead, use the appropriate subclass, such as AABB or Circle.
*
* entity, x, and y are the only properties that can be set directly 
* the Bounds class. All others must be modified through the subclass.
*/
class Bounds {
  public var type(getType, never):BoundsType;
  var _type:BoundsType;

  // Subclass properties. These provide a way to get access to the typed
  // volume (so HaXe can properly inline things). If the subclass doesn't
  // inherit from the type, the property will be null.
  public var aabb(getAABB, never):AABB;
  public var circle(getCircle, never):Circle;
  var _aabb:AABB;
  var _circle:Circle;

  // Common bounding volume properties
  public var entity:Entity;
  public var halfWidth(getHalfWidth, never):Float;
  public var halfHeight(getHalfHeight, never):Float;
  public var width(getWidth, never):Float;
  public var height(getHeight, never):Float;
  public var minX(getMinX, never):Float;
  public var minY(getMinY, never):Float;
  public var maxX(getMaxX, never):Float;
  public var maxY(getMaxY, never):Float;
  public var x:Float;
  public var y:Float;
  var _class:String;
  var _halfWidth:Float;
  var _halfHeight:Float;
  var _width:Float;
  var _height:Float;

  function new(type:BoundsType) {
    _type = type;
    _halfWidth = 0;
    _halfHeight =0 ;
    _width = 0;
    _height = 0;
    x = 0;
    y = 0;
    _class = Type.getClassName(Type.getClass(this));
  }

  inline public function collide(other:Bounds):Bool {
    var result:Bool;
    switch (_type) {
      case BoundsType.AABB:
        result = _aabb.collideBounds(other);
      case BoundsType.CIRCLE:
        result = _circle.collideBounds(other);
      default:
        result = false;
    }
    return result;
  }

  inline function getType():BoundsType {
    return _type;
  }

  inline function getAABB():AABB {
    return _aabb;
  }

  inline function getCircle():Circle {
    return _circle;
  }

  inline function getHalfWidth():Float {
    return _halfWidth;
  }

  inline function getHalfHeight():Float {
    return _halfHeight;
  }

  inline function getWidth():Float {
    return _width;
  }

  inline function getHeight():Float {
    return _height;
  }

  inline function getMinX():Float {
    return x - _halfWidth;
  }

  inline function getMinY():Float {
    return y - _halfHeight;
  }

  inline function getMaxX():Float {
    return x + _halfWidth;
  }

  inline function getMaxY():Float {
    return y + _halfHeight;
  }
}
