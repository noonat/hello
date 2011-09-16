package hello.graphics;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.StageQuality;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class Image extends Graphic {
   static public var defaultSmooth:Bool = true;
   static var _matrix:Matrix = new Matrix();

   public var alpha(getAlpha, setAlpha):Float;
   public var angle(getAngle, setAngle):Float;
   public var clipRect:Rectangle;
   public var color(getColor, setColor):Int;
   public var colorTransform(getColorTransform, never):ColorTransform;
   public var isFlipped(getIsFlipped, setIsFlipped):Bool;
   public var originX:Float;
   public var originY:Float;
   public var smooth:Bool;
   public var texture:Texture;
   public var width(getWidth, never):Float;
   public var height(getHeight, never):Float;
   var _alpha:Float;
   var _angle:Float;
   var _angleBitmap:Bitmap;
   var _angleBitmapData:BitmapData;
   var _angleChanged:Bool;
   var _color:Int;
   var _colorTransform:ColorTransform;
   var _isFlipped:Bool;

   public function new(texture:Texture, clipRect:Rectangle=null) {
      super();
      this.texture = texture;
      this.clipRect = clipRect;
      if (clipRect != null) {
         originX = clipRect.width / 2;
         originY = clipRect.height / 2;
      } else {
         originX = texture.rect.width / 2;
         originY = texture.rect.height / 2;
      }
      smooth = defaultSmooth;
      _alpha = 1.0;
      _angle = 0;
      _color = 0xffffff;
      _colorTransform = new ColorTransform();
      _isFlipped = false;
   }

   override public function render(renderer:Render) {
      var x = this.x;
      var y = this.y;
      if (entity != null && isRelative) {
         x += entity.x;
         y += entity.y;
      }
      if (_angle != 0) {
         if (_angleChanged || _angleBitmap == null) {
            _angleChanged = false;
            updateAngleBitmap();
         }
         _matrix.a = 1;
         _matrix.b = 0;
         _matrix.c = 0;
         _matrix.d = 1;
         _matrix.tx = -originX * _matrix.a;
         _matrix.ty = -originY * _matrix.d;
         _matrix.rotate(_angle * Lo.RAD);
         _matrix.tx += originX + x - Lo.cameraX;
         _matrix.ty += originY + y - Lo.cameraY;
         _angleBitmap.smoothing = smooth;
         if (smooth) {
            Lo.quality = StageQuality.HIGH;
         }
         renderer.draw(_angleBitmap, _matrix, colorTransform, null, null, smooth);
         if (smooth) {
            Lo.resetQuality();
         }
      } else {
         if (clipRect != null) {
            renderer.drawTextureRect(texture, x, y, clipRect.x, clipRect.y, clipRect.width, clipRect.height, isFlipped, colorTransform);
         } else {
            renderer.drawTexture(texture, x, y, isFlipped, colorTransform);
         }
      }
   }

   inline function updateAngleBitmap() {
      var rect = clipRect != null ? clipRect : texture.rect;
      if (_angleBitmapData != null && (_angleBitmapData.width != rect.width || _angleBitmapData.height != rect.height)) {
         _angleBitmapData.dispose();
         _angleBitmapData = null;
      }
      if (_angleBitmapData == null) {
         _angleBitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0);
         if (_angleBitmap == null) {
            _angleBitmap = new Bitmap(_angleBitmapData);
         } else {
            _angleBitmap.bitmapData = _angleBitmapData;
         }
      }
      texture.copyRectInto(_angleBitmapData, 0, 0, rect.x, rect.y, rect.width,
         rect.height, _isFlipped, false);
   }

   inline function getAlpha():Float {
      return _alpha;
   }

   inline function setAlpha(value:Float):Float {
      if (_alpha != value) {
         _alpha = value;
         _colorTransform.alphaMultiplier = value;
      }
      return value;
   }

   inline function getAngle():Float {
      return _angle;
   }

   inline function setAngle(value:Float):Float {
      value %= 360;
      if (value < 0) {
         value += 360;
      }
      if (_angle != value) {
         _angle = value;
         _angleChanged = true;
      }
      return value;
   }

   inline function getColor():Int {
      return _color;
   }

   inline function setColor(value:Int):Int {
      value &= 0xffffff;
      if (_color != value) {
         _color = value;
         _colorTransform.redMultiplier   = (_color >> 16 & 255) / 255.0;
         _colorTransform.greenMultiplier = (_color >> 8 & 255) / 255.0;
         _colorTransform.blueMultiplier  = (_color & 255) / 255.0;
      }
      return value;
   }

   inline function getColorTransform():ColorTransform {
      return _color != 0xffffff || _alpha != 1.0 ? _colorTransform : null;
   }

   function getIsFlipped():Bool {
      return _isFlipped;
   }

   inline function setIsFlipped(value:Bool) {
      if (_isFlipped != value) {
         _isFlipped = value;
         if (_angle != 0) {
            _angleChanged = true;
         }
      }
      return value;
   }

   inline function getWidth():Float {
      return (clipRect != null ? clipRect : texture.rect).width;
   }

   inline function getHeight():Float {
      return (clipRect != null ? clipRect : texture.rect).height;
   }
}
