package;

class Segment {
  public var x1(getX1, setX1):Float;
  public var y1(getY1, setY1):Float;
  public var x2(getX2, setX2):Float;
  public var y2(getY2, setY2):Float;
  public var deltaX(getDeltaX, setDeltaX):Float;
  public var deltaY(getDeltaY, setDeltaY):Float;
  public var deltaSquared(getDeltaSquared, never):Float;
  public var scaleX(getScaleX, never):Float;
  public var scaleY(getScaleY, never):Float;
  public var signX(getSignX, never):Float;
  public var signY(getSignY, never):Float;
  var _x1:Float;
  var _y1:Float;
  var _x2:Float;
  var _y2:Float;
  var _deltaX:Float;
  var _deltaY:Float;
  var _deltaSquared:Float;
  var _scaleX:Float;
  var _scaleY:Float;
  var _signX:Float;
  var _signY:Float;

  public function new(x1:Float, y1:Float, x2:Float, y2:Float) {
    set(x1, y1, x2, y2);
  }

  /**
  * Return the linear time for the point when it is projected onto the line.
  * Clamp the time to 0, 1 if you want to project it onto the segment.
  */
  inline public function getTimeForPoint(x:Float, y:Float):Float {
    return (
      (_deltaX * (x - _x1) + _deltaY * (y - _y1)) /
      (_deltaX * _deltaX + _deltaY * _deltaY));
  }

  inline public function set(x1:Float, y1:Float, x2:Float, y2:Float) {
    _x1 = x1;
    _y1 = y1;
    _x2 = x2;
    _y2 = y2;
    updateX();
    updateY();
  }

  function updateX() {
    _deltaX = _x2 - _x1;
    _deltaSquared = _deltaX * _deltaX + _deltaY * _deltaY;
    _scaleX = 1.0 / _deltaX;
    _signX = Lo.sign(_scaleX);
  }

  function updateY() {
    _deltaY = _y2 - _y1;
    _deltaSquared = _deltaX * _deltaX + _deltaY * _deltaY;
    _scaleY = 1.0 / _deltaY;
    _signY = Lo.sign(_scaleY);
  }

  inline function getX1():Float {
    return _x1;
  }

  inline function setX1(value:Float):Float {
    if (_x1 != value) {
      _x1 = value;
      updateX();
    }
    return value;
  }

  inline function getY1():Float {
    return _y1;
  }

  inline function setY1(value:Float):Float {
    if (_y1 != value) {
      _y1 = value;
      updateY();
    }
    return value;
  }

  inline function getX2():Float {
    return _x2;
  }

  inline function setX2(value:Float):Float {
    if (_x2 != value) {
      _x2 = value;
      updateX();
    }
    return value;
  }

  inline function getY2():Float {
    return _y2;
  }

  inline function setY2(value:Float):Float {
    if (_y2 != value) {
      _y2 = value;
      updateY();
    }
    return value;
  }

  inline function getDeltaX():Float {
    return _deltaX;
  }

  inline function setDeltaX(value:Float) {
    x2 = _x1 + value;
    return value;
  }

  inline function getDeltaY():Float {
    return _deltaY;
  }

  inline function setDeltaY(value:Float):Float {
    y2 = _y1 + value;
    return value;
  }

  inline function getDeltaSquared():Float {
    return _deltaSquared;
  }

  inline function getScaleX():Float {
    return _scaleX;
  }

  inline function getScaleY():Float {
    return _scaleY;
  }

  inline function getSignX():Float {
    return _signX;
  }

  inline function getSignY():Float {
    return _signY;
  }
}
