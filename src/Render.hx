package;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;

class Render {
  static public var backgroundColor:Int = 0x000000;
  static public var buffer(getBuffer, never):BitmapData;
  static var _bitmapIndex:Int;
  static var _bitmaps:Array<Bitmap>;
  static var _buffer:BitmapData;
  static var _bufferRect:Rectangle;
  static var _sprite:Sprite;
  #if debug
  static var _debug:Shape;
  #end

  static public function init() {
    _buffer = new BitmapData(Lo.width, Lo.height, false, 0);
    _bufferRect = _buffer.rect;
    _bitmaps = new Array<Bitmap>();
    _bitmaps[0] = new Bitmap(_buffer);
    _bitmaps[0].visible = false;
    _bitmaps[1] = new Bitmap(_buffer.clone());
    _bitmapIndex = 0;
    _sprite = new Sprite();
    _sprite.addChild(_bitmaps[0]);
    _sprite.addChild(_bitmaps[1]);
    #if debug
    _debug = new Shape();
    _sprite.addChild(_debug);
    #end
    Lib.current.addChild(_sprite);
  }

  static public function flip() {
    flush();
    #if debug
    _buffer.draw(_debug);
    _debug.graphics.clear();
    #end
    _bitmaps[_bitmapIndex].visible = true;
    _bitmapIndex = (_bitmapIndex + 1) % 2;
    _bitmaps[_bitmapIndex].visible = false;
    _buffer = _bitmaps[_bitmapIndex].bitmapData;
    _buffer.fillRect(_bufferRect, backgroundColor);
  }

  static public function flush() {
    
  }

  static inline function getBuffer():BitmapData {
    return _buffer;
  } 
}
