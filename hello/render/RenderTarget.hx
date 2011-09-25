package hello.render;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.StageQuality;
import flash.geom.Rectangle;

class RenderTarget {
   public var backgroundColor:Int;
   public var buffer(getBuffer, never):BitmapData;
   public var bufferRect(getBufferRect, never):Rectangle;
   public var width(getWidth, never):Int;
   public var height(getHeight, never):Int;
   var _buffer:BitmapData;
   var _bufferRect:Rectangle;
   var _width:Int;
   var _height:Int;
#if debug
   var _debug:Shape;
#end

   public function new(width:Int, height:Int, transparent:Bool=false) {
      backgroundColor = 0xff000000;
      _buffer = new BitmapData(width, height, transparent, 0);
      _bufferRect = _buffer.rect;
      _width = width;
      _height = height;
#if debug
      _debug = new Shape();
#end
   }

   public function dispose() {
      _buffer.dispose();
      _buffer = null;
   }

   public function flip() {
#if debug
      Lo.quality = StageQuality.HIGH;
      _buffer.draw(_debug);
      _debug.graphics.clear();
      Lo.resetQuality();
#end
   }

   inline function getBuffer():BitmapData {
      return _buffer;
   }

   inline function getBufferRect():Rectangle {
      return _bufferRect;
   }

   inline function getWidth():Int {
      return _width;
   }

   inline function getHeight():Int {
      return _height;
   }
}
