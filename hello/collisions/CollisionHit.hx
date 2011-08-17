package hello.collisions;

class CollisionHit {
  public var x:Float;
  public var y:Float;
  public var deltaX:Float;
  public var deltaY:Float;
  public var normalX:Float;
  public var normalY:Float;
  public var bounds:Bounds;
  public var entity:Entity;
  var _next:CollisionHit;
  static var _first:CollisionHit;

  function new() {

  }

  inline public function copy(hit:CollisionHit) {
    x = hit.x;
    y = hit.y;
    deltaX = hit.deltaX;
    deltaY = hit.deltaY;
    normalX = hit.normalX;
    normalY = hit.normalY;
    bounds = hit.bounds;
    entity = hit.entity;
  }

  inline public function normalize():Float {
    var length = normalX * normalX + normalY * normalY;
    if (length > 0) {
      length = Math.sqrt(length);
      normalX /= length;
      normalY /= length;
    }
    return length;
  }

  public function free() {
    if (_next == null) {
      _next = _first;
      _first = this;
    }
  }

  inline public function reset() {
    x = 0;
    y = 0;
    deltaX = 0;
    deltaY = 0;
    normalX = 0;
    normalY = 0;
  }

  static public function create() {
    var hit:CollisionHit;
    if (_first != null) {
      hit = _first;
      _first = hit._next;
      hit._next = null;
    } else {
      hit = new CollisionHit();
    }
    hit.reset();
    return hit;
  }
}
