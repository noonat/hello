package hello.graphics;

import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

class Texture {
   /**
   * Texture atlas ID, or null.
   */
   public var id:String;

   /**
   * The atlas this texture belongs to.
   */
   public var atlas:TextureAtlas;

   /**
   * If the original texture was trimmed before being merged into the atlas,
   * this is the offset from the top-left of the original texture.
   */
   public var clipOffset:Point;

   /**
   * The rectangle (within the atlas) of the trimmed texture.
   */
   public var clipRect:Rectangle;

   /**
   * The original size of the texture.
   */
   public var rect:Rectangle;

   /**
   * Texture atlas bitmap data.
   */
   public var source(getSource, never):BitmapData;

   /**
   * Texture atlas bitmap data, flipped on the X axis.
   */
   public var sourceFlipped(getSourceFlipped, never):BitmapData;

   /**
   * Texture atlas rectangle.
   */
   public var sourceRect(getSourceRect, never):Rectangle;

   static var _matrix:Matrix = new Matrix();
   static var _point:Point = new Point();
   static var _rect:Rectangle = new Rectangle();

   public function new(id:String, atlas:TextureAtlas, clipOffset:Point=null, clipRect:Rectangle=null, rect:Rectangle=null) {
      if (id == null) {
         throw 'Invalid texture: id cannot be null';
      }
      if (atlas == null) {
         throw 'Invalid texture "' + id + '": atlas cannot be null';
      }
      this.id = id;
      this.atlas = atlas;
      this.clipOffset = clipOffset != null ? clipOffset.clone() : new Point();
      this.clipRect = clipRect != null ? clipRect.clone() : new Rectangle();
      this.rect = rect != null ? rect.clone() : new Rectangle();
   }

   inline public function copyInto(destBitmapData:BitmapData, x:Float, y:Float, flipped:Bool=false, mergeAlpha:Bool=true) {
      _point.x = Std.int(x);
      _point.y = Std.int(y) + clipOffset.y;
      _rect.x = clipRect.x;
      _rect.y = clipRect.y;
      _rect.width = clipRect.width;
      _rect.height = clipRect.height;
      if (flipped) {
         _rect.x = sourceRect.width - _rect.x - _rect.width;
      } else {
         _point.x += clipOffset.x;
      }
      destBitmapData.copyPixels(
         flipped ? sourceFlipped : source, _rect, _point, null, null, mergeAlpha);
   }

   inline public function copyRectInto(destBitmapData:BitmapData, x:Float, y:Float, sourceX:Float, sourceY:Float, sourceWidth:Float, sourceHeight:Float, flipped:Bool=false, mergeAlpha:Bool=true) {
      _point.x = Std.int(x);
      _point.y = Std.int(y);
      _rect.x = (clipRect.x - clipOffset.x) + sourceX;
      _rect.y = (clipRect.y - clipOffset.y) + sourceY;
      _rect.width = sourceWidth;
      _rect.height = sourceHeight;
      if (_rect.x < clipRect.x) {
         if (!flipped) {
            _point.x += clipRect.x - _rect.x;
         }
         _rect.left = clipRect.x;
      }
      if (_rect.y < clipRect.y) {
         _point.y += clipRect.y - _rect.y;
         _rect.top = clipRect.y;
      }
      if (_rect.right > clipRect.right) {
         _rect.right = clipRect.right;
      }
      if (_rect.bottom > clipRect.bottom) {
         _rect.bottom = clipRect.bottom;
      }
      if (flipped) {
         _rect.x = sourceRect.width - _rect.x - _rect.width;
      }
      destBitmapData.copyPixels(
         flipped ? sourceFlipped : source, _rect, _point, null, null, mergeAlpha);
   }

   inline public function drawInto(destBitmapData:BitmapData, x:Float, y:Float, flipped:Bool=false, colorTransform:ColorTransform=null) {
      _matrix.identity();
      _matrix.tx = Std.int(x);
      _matrix.ty = Std.int(y) + clipOffset.y;
      _rect.x = clipRect.x;
      _rect.y = clipRect.y;
      _rect.width = clipRect.width;
      _rect.height = clipRect.height;
      if (flipped) {
         _rect.x = sourceRect.width - _rect.x - _rect.width;
      } else {
         _matrix.tx += clipOffset.x;
      }
      _matrix.tx -= _rect.x;
      _matrix.ty -= _rect.y;
      _rect.x += _matrix.tx;
      _rect.y += _matrix.ty;
      destBitmapData.draw(
         flipped ? sourceFlipped : source, _matrix, colorTransform, null, _rect);
   }

   inline public function drawRectInto(destBitmapData:BitmapData, x:Float, y:Float, sourceX:Float, sourceY:Float, sourceWidth:Float, sourceHeight:Float, flipped:Bool=false, colorTransform:ColorTransform=null) {
      _matrix.identity();
      _matrix.tx = Std.int(x);
      _matrix.ty = Std.int(y);
      _rect.x = (clipRect.x - clipOffset.x) + sourceX;
      _rect.y = (clipRect.y - clipOffset.y) + sourceY;
      _rect.width = sourceWidth;
      _rect.height = sourceHeight;
       if (_rect.x < clipRect.x) {
         if (!flipped) {
            _matrix.tx += clipRect.x - _rect.x;
         }
         _rect.left = clipRect.x;
      }
      if (_rect.y < clipRect.y) {
         _matrix.ty += clipRect.y - _rect.y;
         _rect.top = clipRect.y;
      }
      if (_rect.right > clipRect.right) {
         _rect.right = clipRect.right;
      }
      if (_rect.bottom > clipRect.bottom) {
         _rect.bottom = clipRect.bottom;
      }
      if (flipped) {
         _rect.x = sourceRect.width - _rect.x - _rect.width;
      }
      _matrix.tx -= _rect.x;
      _matrix.ty -= _rect.y;
      _rect.x += _matrix.tx;
      _rect.y += _matrix.ty;
      destBitmapData.draw(
         flipped ? sourceFlipped : source, _matrix, colorTransform, null, _rect);
   }

   inline function getSource():BitmapData {
      return atlas.source;
   }

   inline function getSourceFlipped():BitmapData {
      return atlas.sourceFlipped;
   }

   inline function getSourceRect():Rectangle {
      return atlas.sourceRect;
   }

   static public function createFromSource(source:Dynamic, id:String='default'):Texture {
      var atlas = new TextureAtlas(source);
      return atlas.setTextureFromRect(id, atlas.sourceRect);
   }
}
