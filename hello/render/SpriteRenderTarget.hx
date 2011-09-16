package hello.render;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.geom.Matrix;

class SpriteRenderTarget extends RenderTarget {
   public var angle(getAngle, setAngle):Float;
   public var originX(getOriginX, setOriginX):Float;
   public var originY(getOriginY, setOriginY):Float;
   public var scale(getScale, setScale):Float;
   public var sprite(getSprite, never):Sprite;
   public var x(getX, setX):Float;
   public var y(getY, setY):Float;
   var _angle:Float;
   var _bitmapIndex:Int;
   var _bitmaps:Array<Bitmap>;
   var _matrix:Matrix;
   var _matrixNeedsUpdate:Bool;
   var _originX:Float;
   var _originY:Float;
   var _scale:Float;
   var _sprite:Sprite;
   var _x:Float;
   var _y:Float;

   public function new(width:Int, height:Int, transparent:Bool=true) {
      super(width, height, transparent);
      _angle = 0;
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
      _sprite.addChild(_debug);
#end
   }

   override public function dispose() {
      _sprite.parent.removeChild(_sprite);
      _bitmaps[0].bitmapData.dispose();
      _bitmaps[1].bitmapData.dispose();
   }

   override public function flip() {
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

      super.flip();

      _bitmaps[_bitmapIndex].visible = true;
      _bitmapIndex = (_bitmapIndex + 1) % 2;
      _bitmaps[_bitmapIndex].visible = false;
      _buffer = _bitmaps[_bitmapIndex].bitmapData;
      _buffer.fillRect(_bufferRect, backgroundColor);
   }

   inline function getAngle():Float {
      return _angle;
   }

   inline function setAngle(value:Float):Float {
      if (_angle != value * Lo.RAD) {
         _angle = value * Lo.RAD;
         _matrixNeedsUpdate = true;
      }
      return value;
   }

   inline function getOriginX():Float {
      return _originX;
   }

   inline function setOriginX(value:Float):Float {
      if (_originX != value) {
         _originX = value;
         _matrixNeedsUpdate = true;
      }
      return value;
   }

   inline function getOriginY():Float {
      return _originY;
   }

   inline function setOriginY(value:Float):Float {
      if (_originY != value) {
         _originY = value;
         _matrixNeedsUpdate = true;
      }
      return value;
   }

   inline function getScale():Float {
      return _scale;
   }

   inline function setScale(value:Float):Float {
      if (_scale != value) {
         _scale = value;
         _matrixNeedsUpdate = true;
      }
      return value;
   }

   inline function getSprite():Sprite {
      return _sprite;
   }

   inline function getX():Float {
      return _x;
   }

   inline function setX(value:Float):Float {
      if (_x != value) {
         _x = value;
         _matrixNeedsUpdate = true;
      }
      return value;
   }

   inline function getY():Float {
      return _y;
   }

   inline function setY(value:Float):Float {
      if (_y != value) {
         _y = value;
         _matrixNeedsUpdate = true;
      }
      return value;
   }
}
