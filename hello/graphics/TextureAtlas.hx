package hello.graphics;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class TextureAtlas {
  public var source(getSource, never):BitmapData;
  public var sourceFlipped(getSourceFlipped, never):BitmapData;
  public var sourceRect(getSourceRect, never):Rectangle;
  var _resource:ResourceData;
  var _source:BitmapData;
  var _sourceFlipped:BitmapData;
  var _sourceRect:Rectangle;
  var _textures:Hash<Texture>;

  static var _matrix:Matrix = new Matrix();
  static var _pointRegex:EReg = ~/\{(\d+),\s*(\d+)\}/;
  static var _rectRegex:EReg = ~/\{\{(\d+),\s*(\d+)\},\s*\{(\d+),\s*(\d+)\}\}/;

  public function new(source:Dynamic) {
    if (Std.is(source, String)) {
      _resource = Resources.getResource(Std.string(source));
      if (_resource == null) {
        throw 'Invalid resource "' + source + '"';
      }
      _source = _resource.content;
    } else if (Std.is(source, BitmapData)) {
      _source = source;
    } else {
      throw 'TextureAtlas source must be a resource id string or BitmapData';
    }
    _sourceFlipped = null;
    _sourceRect = _source.rect;
    _textures = new Hash<Texture>();
  }

  public function getTexture(id:String):Texture {
    return _textures.get(id);
  }

  public function setTexture(id:String, clipRect:Rectangle):Texture {
    var texture = new Texture(id, this);
    texture.clipRect.x = clipRect.x;
    texture.clipRect.y = clipRect.y;
    texture.clipRect.width = clipRect.width;
    texture.clipRect.height = clipRect.height;
    texture.rect.width = clipRect.width;
    texture.rect.height = clipRect.height;
    _textures.set(texture.id, texture);
    return texture;
  }

  public function setTexturesFromPropertyList(id:String) {
    var text = Resources.getString(id);
    var data = PropertyList.read(text != null ? text : id);
    if (Reflect.hasField(data, 'frames')) {
      var frames = Reflect.field(data, 'frames');
      for (id in Reflect.fields(frames)) {
        var frameData = Reflect.field(frames, id);
        var texture = new Texture(id, this);
        if (Reflect.hasField(frameData, 'textureRect')) {
          if (_rectRegex.match(Reflect.field(frameData, 'textureRect'))) {
            texture.clipRect.x = Std.parseFloat(_rectRegex.matched(1));
            texture.clipRect.y = Std.parseFloat(_rectRegex.matched(2));
            texture.clipRect.width = Std.parseFloat(_rectRegex.matched(3));
            texture.clipRect.height = Std.parseFloat(_rectRegex.matched(4));
          }
        }
        if (Reflect.hasField(frameData, 'spriteColorRect')) {
          if (_rectRegex.match(Reflect.field(frameData, 'spriteColorRect'))) {
            texture.clipOffset.x = Std.parseFloat(_rectRegex.matched(1));
            texture.clipOffset.y = Std.parseFloat(_rectRegex.matched(2));
          }
        }
        if (Reflect.hasField(frameData, 'spriteSourceSize')) {
          if (_pointRegex.match(Reflect.field(frameData, 'spriteSourceSize'))) {
            texture.rect.width = Std.parseFloat(_pointRegex.matched(1));
            texture.rect.height = Std.parseFloat(_pointRegex.matched(2));
          }
        }
        _textures.set(texture.id, texture);
      }
    }
  }

  inline function getSource():BitmapData {
    return _source;
  }

  inline function getSourceFlipped():BitmapData {
    if (_sourceFlipped == null) {
      _matrix.identity();
      _matrix.a = -1;
      _matrix.tx = _source.width;
      _sourceFlipped = new BitmapData(
        _source.width, _source.height, _source.transparent, 0);
      _sourceFlipped.draw(_source, _matrix);
    }
    return _sourceFlipped;
  }

  inline function getSourceRect():Rectangle {
    return _sourceRect;
  }
}