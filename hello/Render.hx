package hello;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.IBitmapDrawable;
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
import hello.render.RenderTarget;

private typedef RenderTargetFriend = {
   var _debug:Shape;
};

class Render {
   static public var defaultGraphicsQuality:StageQuality = StageQuality.HIGH;

   public var graphics(getGraphics, never):Graphics;
   public var graphicsDirty(getGraphicsDirty, setGraphicsDirty):Bool;
   public var graphicsQuality:StageQuality;
   public var target(getTarget, setTarget):RenderTarget;
   var _debug:Shape;
   var _target:RenderTarget;
   var _tmpGraphics:Graphics;
   var _tmpGraphicsDirty:Bool;
   var _tmpMatrix:Matrix;
   var _tmpPoint:Point;
   var _tmpRect:Rectangle;
   var _tmpShape:Shape;

   public function new(target:RenderTarget) {
      this.target = target;
      graphicsQuality = defaultGraphicsQuality;
      _tmpMatrix = new Matrix();
      _tmpPoint = new Point();
      _tmpRect = new Rectangle();
      _tmpShape = new Shape();
      _tmpGraphics = _tmpShape.graphics;
      _tmpGraphicsDirty = false;
   }

   public function flip() {
      if (_target != null) {
         _target.flip();
         _debug = getTargetFriend(_target)._debug;
      }
   }

   public function flush() {
      if (_tmpGraphicsDirty) {
         if (_target != null) {
            Lo.quality = graphicsQuality;
            _target.buffer.draw(_tmpShape);
            Lo.resetQuality();
         }
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
      sourceWidth = Std.int(Lo.min(sourceWidth, _target.width - destX));
      if (sourceWidth > 0) {
         sourceHeight = Std.int(Lo.min(sourceHeight, _target.height - destY));
         if (sourceHeight > 0) {
            _tmpPoint.x = destX;
            _tmpPoint.y = destY;
            _tmpRect.x = sourceX;
            _tmpRect.y = sourceY;
            _tmpRect.width = sourceWidth;
            _tmpRect.height = sourceHeight;
            _target.buffer.copyPixels(
               source, _tmpRect, _tmpPoint, null, null, mergeAlpha);
         }
      }
   }

   inline public function draw(source:IBitmapDrawable, matrix:Matrix=null, colorTransform:ColorTransform=null, blendMode:BlendMode=null, clipRect:Rectangle=null, smoothing:Bool=false) {
      target.buffer.draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
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
         texture.drawInto(_target.buffer, x, y, flipped, colorTransform);
      } else {
         texture.copyInto(_target.buffer, x, y, flipped);
      }
   }

   inline public function drawTextureRect(texture:Texture, x:Float, y:Float, sourceX:Float, sourceY:Float, sourceWidth:Float, sourceHeight:Float, isFlipped:Bool=false, colorTransform:ColorTransform=null) {
      x -= Lo.cameraX;
      y -= Lo.cameraY;
      if (colorTransform != null) {
         texture.drawRectInto(
            _target.buffer, x, y, sourceX, sourceY, sourceWidth, sourceHeight,
            isFlipped, colorTransform);
      } else {
         texture.copyRectInto(
            _target.buffer, x, y, sourceX, sourceY, sourceWidth, sourceHeight,
            isFlipped);
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

   inline function getGraphics():Graphics {
      return _tmpGraphics;
   }

   inline function getGraphicsDirty():Bool {
      return _tmpGraphicsDirty;
   }

   inline function setGraphicsDirty(value:Bool):Bool {
      return _tmpGraphicsDirty = value;
   }

   inline function getTarget():RenderTarget {
      return _target;
   }

   function setTarget(value:RenderTarget):RenderTarget {
      if (value == null) {
         throw 'ERROR: Render.target must not be set to a null value';
      }
      if (_target != value) {
         if (_target != null) {
            flush();
         }
         _target = value;
         _debug = getTargetFriend(_target)._debug;
      }
      return value;
   }

   inline function getTargetFriend(target:RenderTarget):RenderTargetFriend {
      return untyped target;
   }
}
