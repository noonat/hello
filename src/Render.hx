package;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageQuality;
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

  #if debug
  static inline public function debugCircle(x:Float, y:Float, radius:Float, color:Int=0xffffff, alpha:Float=1.0, thickness:Float=2):Void {
    _debug.graphics.lineStyle(thickness, color & 0xffffff, alpha);
    _debug.graphics.drawCircle(x, y, radius);
  }

  static inline public function debugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:Int=0xffff00, alpha:Float=1.0, thickness:Float=2):Void {
    _debug.graphics.lineStyle(thickness, color & 0xffffff, alpha);
    _debug.graphics.moveTo(x1 - Lo.cameraX, y1 - Lo.cameraY);
    _debug.graphics.lineTo(x2 - Lo.cameraX, y2 - Lo.cameraY);
  }

  static inline public function debugRect(x:Float, y:Float, w:Float, h:Float, color:Int=0x00ff00, alpha:Float=1.0, thickness:Float=2):Void {
    _debug.graphics.lineStyle(thickness, color & 0xffffff, alpha);
    _debug.graphics.drawRect(x - Lo.cameraX, y - Lo.cameraY, w, h);
  }
  #end
}
