package;

class CollisionSweep {
  public var hit:CollisionHit;
  public var mask:Int;
  public var segment:Segment;
  public var time:Float;
  var _next:CollisionSweep;
  static var _first:CollisionSweep;

  function new() {

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
