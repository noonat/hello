package;

class CollisionSweep {
  public var hit:CollisionHit;
  public var mask:Int;
  public var segment:Segment;
  public var time:Float;
  public var x:Float;
  public var y:Float;
  var _next:CollisionSweep;
  static var _first:CollisionSweep;

  function new() {

  }

  inline public function copy(sweep:CollisionSweep) {
    if (sweep.hit == null) {
      if (hit != null) {
        hit.free();
        hit = null;
      }
    } else {
      if (hit == null) {
        hit = CollisionHit.create();
      }
      hit.copy(sweep.hit);
    }
    segment.set(sweep.segment.x1, sweep.segment.y1, sweep.segment.x2, sweep.segment.y2);
    mask = sweep.mask;
    time = sweep.time;
    x = sweep.x;
    y = sweep.y;
  }

  public function free(freeHit:Bool=true) {
    if (_next == null) {
      if (hit != null && freeHit) {
        hit.free();
      }
      hit = null;
      segment = null;
      _next = _first;
      _first = this;
    }
  }

  inline public function reset(segment:Segment, mask:Int) {
    this.mask = mask;
    this.segment = segment;
    time = 1.0;
    x = segment.x1 + segment.deltaX;
    y = segment.y1 + segment.deltaY;
  }

  static public function create(segment:Segment, mask:Int=0) {
    var sweep:CollisionSweep;
    if (_first != null) {
      sweep = _first;
      _first = sweep._next;
      sweep._next = null;
    } else {
      sweep = new CollisionSweep();
    }
    sweep.reset(segment, mask);
    return sweep;
  }
}
