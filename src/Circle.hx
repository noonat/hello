package;

class Circle extends Bounds {
  public var radius(getRadius, setRadius):Float;
  public var radiusSquared(getRadiusSquared, never):Float;
  var _radius:Float;
  var _radiusSquared:Float;

  public function new(radius:Float, ?x:Float, ?y:Float) {
    super(BoundsType.CIRCLE);
    _circle = this;
    set(radius, x, y);
  }

  inline public function collideBounds(other:Bounds):Bool {
    var result:Bool;
    switch (other.type) {
      case BoundsType.AABB:
        result = Collide.testAABBCircle(other.aabb, this);
      case BoundsType.CIRCLE:
        result = Collide.testCircleCircle(this, other.circle);
      default:
        result = false;
    }
    return result;
  }

  inline public function set(radius:Float, ?x:Float, ?y:Float) {
    this.radius = radius;
    this.x = x == null ? radius : x;
    this.y = y == null ? radius : y;
  }

  inline function getRadius():Float {
    return _radius;
  }

  inline function setRadius(value:Float):Float {
    _radius = value;
    _radiusSquared = value * value;
    _halfWidth = value;
    _halfHeight = value;
    _width = value * 2;
    _height = value * 2;
    return value;
  }

  inline function getRadiusSquared():Float {
    return _radiusSquared;
  }
}
