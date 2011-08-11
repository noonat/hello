package;

class SignalListener {
  public var added:Bool;
  public var listener:Dynamic;
  public var next:SignalListener;
  public var prev:SignalListener;

  public function new() {
    added = true;
    listener = null;
    next = null;
    prev = null;
  }
}
