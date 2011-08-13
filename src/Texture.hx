import flash.display.BitmapData;
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
  * this is the offset to the top-left of the original texture.
  */
  public var clipOrigin:Point;

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

  static var _point:Point = new Point();
  static var _rect:Rectangle = new Rectangle();

  public function new(id:String, atlas:TextureAtlas, clipOrigin:Point=null, clipRect:Rectangle=null, rect:Rectangle=null) {
    if (id == null) {
      throw 'Invalid texture: id cannot be null';
    }
    if (atlas == null) {
      throw 'Invalid texture "' + id + '": atlas cannot be null';
    }
    this.id = id;
    this.atlas = atlas;
    this.clipOrigin = clipOrigin != null ? clipOrigin.clone() : new Point();
    this.clipRect = clipRect != null ? clipRect.clone() : new Rectangle();
    this.rect = rect != null ? rect.clone() : new Rectangle();
  }
  
  inline public function copyPixelsInto(destBitmapData:BitmapData, x:Float, y:Float, mergeAlpha:Bool=true) {
    _point.x = x - clipOrigin.x;
    _point.y = y - clipOrigin.y;
    destBitmapData.copyPixels(source, clipRect, _point, null, null, mergeAlpha);
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
}
