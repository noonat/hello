package hello;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import hello.graphics.Texture;

class Render {
  static public var angle(getAngle, setAngle):Float;
  static public var backgroundColor:Int = 0x000000;
  static public var buffer(getBuffer, never):BitmapData;
  static public var originX(getOriginX, setOriginX):Float;
  static public var originY(getOriginY, setOriginY):Float;
  static public var scale(getScale, setScale):Float;
  static public var x(getX, setX):Float;
  static public var y(getY, setY):Float;
  static var _angle:Float;
  static var _bitmapIndex:Int;
  static var _bitmaps:Array<Bitmap>;
  static var _buffer:BitmapData;
  static var _bufferRect:Rectangle;
  static var _matrix:Matrix;
  static var _matrixNeedsUpdate:Bool;
  static var _originX:Float;
  static var _originY:Float;
  static var _scale:Float;
  static var _sprite:Sprite;
  static var _x:Float;
  static var _y:Float;
  #if debug
  static var _debug:Shape;
  #end

  static public function init() {
    _angle = 0;
    _buffer = new BitmapData(Lo.width, Lo.height, false, 0);
    _bufferRect = _buffer.rect;
    _bitmaps = new Array<Bitmap>();
    _bitmaps[0] = new Bitmap(_buffer);
    _bitmaps[0].visible = false;
    _bitmaps[1] = new Bitmap(_buffer.clone());
    _bitmapIndex = 0;
    _matrix = new Matrix();
    _matrixNeedsUpdate = true;
    _originX = 0;
    _originY = 0;
    _scale = 1;
    _sprite = new Sprite();
    _sprite.addChild(_bitmaps[0]);
    _sprite.addChild(_bitmaps[1]);
    _x = 0;
    _y = 0;
    #if debug
    _debug = new Shape();
    _sprite.addChild(_debug);
    #end
    Lib.current.addChild(_sprite);
  }

  static public function flip() {
    flush();
    if (_matrixNeedsUpdate) {
      _matrix.b = _matrix.c = 0;
      _matrix.a = _scale;
      _matrix.d = _scale;
      _matrix.tx = -_originX * _matrix.a;
      _matrix.ty = -_originY * _matrix.d;
      if (_angle != 0) {
        _matrix.rotate(_angle);
      }
      _matrix.tx += _originX * _scale + _x;
      _matrix.ty += _originY * _scale + _y;
      _sprite.transform.matrix = _matrix;
    }
    #if debug
    Lo.stage.quality = StageQuality.HIGH;
    _buffer.draw(_debug);
    _debug.graphics.clear();
    Lo.stage.quality = StageQuality.LOW;
    #end
    _bitmaps[_bitmapIndex].visible = true;
    _bitmapIndex = (_bitmapIndex + 1) % 2;
    _bitmaps[_bitmapIndex].visible = false;
    _buffer = _bitmaps[_bitmapIndex].bitmapData;
    _buffer.fillRect(_bufferRect, backgroundColor);
  }

  static public function flush() {

  }

  static inline public function drawTexture(texture:Texture, x:Float, y:Float, flipped:Bool=false, mergeAlpha:Bool=true) {
    texture.copyInto(_buffer, x, y, flipped, mergeAlpha);
  }

  static inline public function drawTextureRect(texture:Texture, x:Float, y:Float, sourceX:Float, sourceY:Float, sourceWidth:Float, sourceHeight:Float, flipped:Bool=false, mergeAlpha:Bool=true) {
    texture.copyRectInto(_buffer, x, y, sourceX, sourceY, sourceWidth, sourceHeight, flipped, mergeAlpha);
  }

  static inline function getBuffer():BitmapData {
    return _buffer;
  }

  static inline function getAngle():Float {
    return _angle;
  }

  static inline function setAngle(value:Float):Float {
    if (_angle != value * Lo.RAD) {
      _angle = value * Lo.RAD;
      _matrixNeedsUpdate = true;
    }
    return value;
  }

  static inline function getOriginX():Float {
    return _originX;
  }

  static inline function setOriginX(value:Float):Float {
    if (_originX != value) {
      _originX = value;
      _matrixNeedsUpdate = true;
    }
    return value;
  }

  static inline function getOriginY():Float {
    return _originY;
  }

  static inline function setOriginY(value:Float):Float {
    if (_originY != value) {
      _originY = value;
      _matrixNeedsUpdate = true;
    }
    return value;
  }

  static inline function getScale():Float {
    return _scale;
  }

  static inline function setScale(value:Float):Float {
    if (_scale != value) {
      _scale = value;
      _matrixNeedsUpdate = true;
    }
    return value;
  }

  static inline function getX():Float {
    return _x;
  }

  static inline function setX(value:Float):Float {
    if (_x != value) {
      _x = value;
      _matrixNeedsUpdate = true;
    }
    return value;
  }

  static inline function getY():Float {
    return _y;
  }

  static inline function setY(value:Float):Float {
    if (_y != value) {
      _y = value;
      _matrixNeedsUpdate = true;
    }
    return value;
  }

  #if debug
  static inline public function debugCircle(x:Float, y:Float, radius:Float, color:Int=0xffffff, alpha:Float=1.0, thickness:Float=0):Void {
    _debug.graphics.lineStyle(thickness, color & 0xffffff, alpha);
    _debug.graphics.drawCircle(x, y, radius);
  }

  static inline public function debugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:Int=0xffff00, alpha:Float=1.0, thickness:Float=0):Void {
    _debug.graphics.lineStyle(thickness, color & 0xffffff, alpha);
    _debug.graphics.moveTo(x1 - Lo.cameraX, y1 - Lo.cameraY);
    _debug.graphics.lineTo(x2 - Lo.cameraX, y2 - Lo.cameraY);
  }

  static inline public function debugRect(x:Float, y:Float, w:Float, h:Float, color:Int=0x00ff00, alpha:Float=1.0, thickness:Float=0):Void {
    _debug.graphics.lineStyle(thickness, color & 0xffffff, alpha);
    _debug.graphics.drawRect(x - Lo.cameraX, y - Lo.cameraY, w, h);
  }
  #end
}
