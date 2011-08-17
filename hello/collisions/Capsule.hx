package hello.collisions;

class Capsule extends Segment {
  public var circle1(getCircle1, never):Circle;
  public var circle2(getCircle2, never):Circle;
  public var radius(getRadius, setRadius):Float;
  public var radiusSquared(getRadiusSquared, never):Float;
  var _circle1:Circle;
  var _circle2:Circle;
  var _radius:Float;
  var _radiusSquared:Float;
  static var _entity:Entity;

  public function new(x1:Float, y1:Float, x2:Float, y2:Float, radius:Float) {
    if (_entity == null) {
      _entity = new Entity();
    }
    _circle1 = new Circle(0, 0);
    _circle1.entity = _entity;
    _circle2 = new Circle(0, 0);
    _circle2.entity = _entity;
    this.radius = radius;
    super(x1, y1, x2, y2);
  }

  inline public function setFromEdge(aabb:AABB, flags1:Int, flags2:Int, radius:Float) {
    setWithRadius(
      aabb.entity.x + ((flags1 & 1 != 0) ? aabb.maxX : aabb.minX),
      aabb.entity.y + ((flags1 & 2 != 0) ? aabb.maxY : aabb.minY),
      aabb.entity.x + ((flags2 & 1 != 0) ? aabb.maxX : aabb.minX),
      aabb.entity.y + ((flags2 & 2 != 0) ? aabb.maxY : aabb.minY),
      radius);
  }

  inline public function setWithRadius(x1:Float, y1:Float, x2:Float, y2:Float, radius:Float) {
    super.set(x1, y1, x2, y2);
    this.radius = radius;
  }

  override function updateX() {
    super.updateX();
    _circle1.set(_radius, _x1, _y1);
    _circle2.set(_radius, _x2, _y2);
  }

  override function updateY() {
    super.updateY();
    _circle1.set(_radius, _x1, _y1);
    _circle2.set(_radius, _x2, _y2);
  }

  inline function getCircle1():Circle {
    return _circle1;
  }

  inline function getCircle2():Circle {
    return _circle2;
  }

  inline function getRadius():Float {
    return _radius;
  }

  inline function setRadius(value:Float):Float {
    if (_radius != value) {
      _radius = value;
      _radiusSquared = _radius * _radius;
      _circle1.radius = _radius;
      _circle2.radius = _radius;
    }
    return value;
  }

  inline function getRadiusSquared():Float {
    return _radiusSquared;
  }
}
