package hello;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import hello.collisions.Bounds;
import hello.collisions.CollisionHit;
import hello.collisions.CollisionSweep;
import hello.graphics.Texture;

class Renderer {
   public var angle(getAngle, setAngle):Float;
   public var backgroundColor:Int;
   public var buffer(getBuffer, never):BitmapData;
   public var graphics(getGraphics, never):Graphics;
   public var graphicsDirty(getGraphicsDirty, setGraphicsDirty):Bool;
   public var graphicsQuality:StageQuality;
   public var originX(getOriginX, setOriginX):Float;
   public var originY(getOriginY, setOriginY):Float;
   public var quality(getQuality, setQuality):StageQuality;
   public var scale(getScale, setScale):Float;
   public var width(getWidth, never):Int;
   public var height(getHeight, never):Int;
   public var x(getX, setX):Float;
   public var y(getY, setY):Float;
   var _angle:Float;
   var _bitmapIndex:Int;
   var _bitmaps:Array<Bitmap>;
   var _buffer:BitmapData;
   var _bufferRect:Rectangle;
   var _matrix:Matrix;
   var _matrixNeedsUpdate:Bool;
   var _originX:Float;
   var _originY:Float;
   var _quality:StageQuality;
   var _scale:Float;
   var _sprite:Sprite;
   var _tmpGraphics:Graphics;
   var _tmpGraphicsDirty:Bool;
   var _tmpMatrix:Matrix;
   var _tmpPoint:Point;
   var _tmpQuality:StageQuality;
   var _tmpRect:Rectangle;
   var _tmpShape:Shape;
   var _width:Int;
   var _height:Int;
   var _x:Float;
   var _y:Float;
#if debug
   var _debug:Shape;
#end

   public function new(width:Int, height:Int) {
      backgroundColor = 0x000000;
      graphicsQuality = StageQuality.HIGH;
      _angle = 0;
      _buffer = new BitmapData(width, height, false, 0);
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
      _quality = StageQuality.LOW;
      _scale = 1;
      _sprite = new Sprite();
      _sprite.addChild(_bitmaps[0]);
      _sprite.addChild(_bitmaps[1]);
      _tmpMatrix = new Matrix();
      _tmpPoint = new Point();
      _tmpQuality = _quality;
      _tmpRect = new Rectangle();
      _tmpShape = new Shape();
      _tmpGraphics = _tmpShape.graphics;
      _tmpGraphicsDirty = false;
      _width = width;
      _height = height;
      _x = 0;
      _y = 0;
#if debug
      _debug = new Shape();
      _sprite.addChild(_debug);
#end
      Lib.current.addChild(_sprite);
   }

   public function flip() {
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
      quality = graphicsQuality;
      _buffer.draw(_debug);
      _debug.graphics.clear();
      resetQuality();
#end

      _bitmaps[_bitmapIndex].visible = true;
      _bitmapIndex = (_bitmapIndex + 1) % 2;
      _bitmaps[_bitmapIndex].visible = false;
      _buffer = _bitmaps[_bitmapIndex].bitmapData;
      _buffer.fillRect(_bufferRect, backgroundColor);
   }

   public function flush() {
      if (_tmpGraphicsDirty) {
         quality = graphicsQuality;
         _buffer.draw(_tmpShape);
         resetQuality();
         _tmpGraphics.clear();
      }
   }

   inline public function copyPixels(source:BitmapData, sourceX:Float, sourceY:Float, sourceWidth:Float, sourceHeight:Float, destX:Float, destY:Float, mergeAlpha:Bool=true) {
      destX = Std.int(destX - Lo.cameraX);
      destY = Std.int(destY - Lo.cameraY);
      if (destX < 0) {
         sourceX -= destX;
         sourceWidth += destX;
         destX = 0;
      }
      if (destY < 0) {
         sourceY -= destY;
         sourceHeight += destY;
         destY = 0;
      }
      sourceWidth = Std.int(Lo.min(sourceWidth, _width - destX));
      if (sourceWidth > 0) {
         sourceHeight = Std.int(Lo.min(sourceHeight, _height - destY));
         if (sourceHeight > 0) {
            _tmpPoint.x = destX;
            _tmpPoint.y = destY;
            _tmpRect.x = sourceX;
            _tmpRect.y = sourceY;
            _tmpRect.width = sourceWidth;
            _tmpRect.height = sourceHeight;
            _buffer.copyPixels(source, _tmpRect, _tmpPoint, null, null, mergeAlpha);
         }
      }
   }

   inline public function drawCircle(x:Float, y:Float, radius:Float, color:Int=0xffffff, alpha:Float=1.0, thickness:Float=0) {
      graphicsDirty = true;
      graphics.lineStyle(thickness, color, alpha);
      graphics.drawCircle(x - Lo.cameraX, y - Lo.cameraY, radius);
      graphics.lineStyle(Math.NaN);
   }

   inline public function drawRect(x:Float, y:Float, width:Float, height:Float, color:Int=0xffffff, alpha:Float=1.0, thickness:Float=0) {
      graphicsDirty = true;
      graphics.lineStyle(thickness, color, alpha);
      graphics.drawRect(x - Lo.cameraX, y - Lo.cameraY, width, height);
      graphics.lineStyle(Math.NaN);
   }

   inline public function drawTexture(texture:Texture, x:Float, y:Float, flipped:Bool=false, colorTransform:ColorTransform=null) {
      x -= Lo.cameraX;
      y -= Lo.cameraY;
      if (colorTransform != null) {
         texture.drawInto(_buffer, x, y, flipped, colorTransform);
      } else {
         texture.copyInto(_buffer, x, y, flipped);
      }
   }

   inline public function drawTextureRect(texture:Texture, x:Float, y:Float, sourceX:Float, sourceY:Float, sourceWidth:Float, sourceHeight:Float, flipped:Bool=false, colorTransform:ColorTransform=null) {
      x -= Lo.cameraX;
      y -= Lo.cameraY;
      if (colorTransform != null) {
         texture.drawRectInto(_buffer, x, y, sourceX, sourceY, sourceWidth, sourceHeight, flipped, colorTransform);
      } else {
         texture.copyRectInto(_buffer, x, y, sourceX, sourceY, sourceWidth, sourceHeight, flipped);
      }
   }

   inline public function fillBitmap(bitmap:BitmapData, x:Float, y:Float, width:Float, height:Float) {
      x -= Lo.cameraX;
      y -= Lo.cameraY;
      graphicsDirty = true;
      _tmpMatrix.a = 1;
      _tmpMatrix.b = 0;
      _tmpMatrix.c = 0;
      _tmpMatrix.d = 1;
      _tmpMatrix.tx = x;
      _tmpMatrix.ty = y;
      graphics.beginBitmapFill(bitmap, _tmpMatrix);
      graphics.drawRect(x, y, width, height);
      graphics.endFill();
   }

   inline public function fillCircle(x:Float, y:Float, radius:Float, color:Int=0xffffff, alpha:Float=1.0) {
      graphicsDirty = true;
      graphics.beginFill(color, alpha);
      graphics.drawCircle(x - Lo.cameraX, y - Lo.cameraY, radius);
      graphics.endFill();
   }

   inline public function fillRect(x:Float, y:Float, width:Float, height:Float, color:Int=0xffffff, alpha:Float=1.0, roundedWidth:Float=0, roundedHeight:Float=0) {
      x -= Lo.cameraX;
      y -= Lo.cameraY;
      graphicsDirty = true;
      graphics.beginFill(color, alpha);
      if (roundedWidth != 0 || roundedHeight != 0) {
         graphics.drawRoundRect(x, y, width, height, roundedWidth, roundedHeight == 0 ? roundedWidth : roundedHeight);
      } else {
         graphics.drawRect(x, y, width, height);
      }
      graphics.endFill();
   }

   inline public function resetQuality(value:Null<StageQuality>=null) {
      if (value != null) {
         _quality = value;
      }
      if (_tmpQuality != _quality) {
         Lo.stage.quality = _quality;
      }
      _tmpQuality = _quality;
   }

   inline function getBuffer():BitmapData {
      return _buffer;
   }

   inline function getGraphics():Graphics {
      return _tmpGraphics;
   }

   inline function getGraphicsDirty():Bool {
      return _tmpGraphicsDirty;
   }

   inline function setGraphicsDirty(value:Bool):Bool {
      return _tmpGraphicsDirty = value;
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

   inline function getQuality():StageQuality {
      return _tmpQuality;
   }

   inline function setQuality(value:StageQuality):StageQuality {
      if (_tmpQuality != value) {
         _tmpQuality = value;
         Lo.stage.quality = _tmpQuality;
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

   inline function getWidth():Int {
      return _width;
   }

   inline function getHeight():Int {
      return _height;
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

#if debug
   public function debugBounds(bounds:Bounds, ?x:Float, ?y:Float, color:Int=0xffff00, alpha:Float=1.0, thickness:Float=0) {
      if (x == null) {
         x = bounds.entity != null ? bounds.entity.x : 0;
      }
      if (y == null) {
         y = bounds.entity != null ? bounds.entity.y : 0;
      }
      x += bounds.x;
      y += bounds.y;
      switch (bounds.type) {
         case BoundsType.AABB, BoundsType.GRID:
            debugRect(
               x - bounds.halfWidth, y - bounds.halfHeight,
               bounds.width, bounds.height, color, alpha, thickness);

         case BoundsType.CIRCLE:
            debugCircle(x, y, bounds.circle.radius, color, alpha, thickness);
      }
   }

   public function debugCircle(x:Float, y:Float, radius:Float, color:Int=0xffffff, alpha:Float=1.0, thickness:Float=0) {
      _debug.graphics.lineStyle(thickness, color & 0xffffff, alpha);
      _debug.graphics.drawCircle(x - Lo.cameraX, y - Lo.cameraY, radius);
   }

   public function debugHit(hit:CollisionHit, bounds:Bounds, ?x:Float, ?y:Float, color:Int=0xffff00, alpha:Float=1.0, thickness:Float=0) {
      if (x == null) {
         x = (bounds.entity != null ? bounds.entity.x : 0) + hit.deltaX;
      }
      if (y == null) {
         y = (bounds.entity != null ? bounds.entity.y : 0) + hit.deltaY;
      }
      debugBounds(bounds, x, y, color, alpha, thickness);
      debugLine(hit.x, hit.y, hit.x + hit.normalX * 4, hit.y + hit.normalY * 4, color, alpha);
   }

   public function debugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:Int=0xffffff, alpha:Float=1.0, thickness:Float=0) {
      _debug.graphics.lineStyle(thickness, color & 0xffffff, alpha);
      _debug.graphics.moveTo(x1 - Lo.cameraX, y1 - Lo.cameraY);
      _debug.graphics.lineTo(x2 - Lo.cameraX, y2 - Lo.cameraY);
   }

   public function debugRect(x:Float, y:Float, w:Float, h:Float, color:Int=0xffffff, alpha:Float=1.0, thickness:Float=0) {
      _debug.graphics.lineStyle(thickness, color & 0xffffff, alpha);
      _debug.graphics.drawRect(x - Lo.cameraX, y - Lo.cameraY, w, h);
   }

   public function debugSweep(sweep:CollisionSweep, entity:Entity) {
      var bounds = entity.bounds;
      var segment = sweep.segment;
      var x1 = segment.x1 + bounds.x;
      var y1 = segment.y1 + bounds.y;
      var x2 = segment.x2 + bounds.x;
      var y2 = segment.y2 + bounds.y;
      switch (bounds.type) {
         case BoundsType.AABB:
            var sx:Float = Lo.sign(-segment.deltaX);
            var sy:Float = Lo.sign(segment.deltaY);
            debugLine(
               x1 + (bounds.halfWidth * sx), y1 + (bounds.halfHeight * sy),
               x2 + (bounds.halfWidth * sx), y2 + (bounds.halfHeight * sy),
               0xffffff, 0.5);
            debugLine(
               x1 - (bounds.halfWidth * sx), y1 - (bounds.halfHeight * sy),
               x2 - (bounds.halfWidth * sx), y2 - (bounds.halfHeight * sy),
               0xffffff, 0.5);

         case BoundsType.CIRCLE:
            var r = bounds.circle.radius;
            var nx = segment.deltaX;
            var ny = segment.deltaY;
            var len = Math.sqrt(nx * nx + ny * ny);
            if (len > 0) {
               nx /= len;
               ny /= len;
            }
            debugLine(
               x1 - ny * r, y1 + nx * r,
               x2 - ny * r, y2 + nx * r,
               0xffffff, 0.5);
            debugLine(
               x1 + ny * r, y1 - nx * r,
               x2 + ny * r, y2 - nx * r,
               0xffffff, 0.5);

         default:
            return;
      }
      var color = if (sweep.hit != null) {
         debugHit(sweep.hit, bounds, sweep.x, sweep.y, 0xffff00);
         0xff0000;
      } else {
         0x00ff00;
      }
      debugBounds(bounds, x2 - bounds.x, y2 - bounds.y, color);
   }
#end
}