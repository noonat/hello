package hello;

class SignalListener {
  public var isActive:Bool;
  public var listener:Dynamic;
  public var next:SignalListener;
  public var prev:SignalListener;

  public function new() {
    isActive = true;
    listener = null;
    next = null;
    prev = null;
  }
}
