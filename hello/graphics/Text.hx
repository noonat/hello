package hello.graphics;

import flash.display.BitmapData;
import flash.display.StageQuality;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.AntiAliasType;
import flash.text.Font;
import flash.text.FontType;
import flash.text.TextField;
import flash.text.TextFormat;
import hello.Lo;

class Text extends Graphic {
  public static var defaultFont:String = 'Arial';
  public static var defaultSize:Int = 16;
  public static var defaultSmooth:Bool = true;
  static var _fontEmbeddedCache:Hash<Bool>;

  public var alpha(getAlpha, setAlpha):Float;
  public var antiAlias(getAntiAlias, setAntiAlias):AntiAliasType;
  public var angle(getAngle, setAngle):Float;
  public var color(getColor, setColor):Int;
  public var colorTransform(getColorTransform, never):ColorTransform;
  public var font(getFont, setFont):String;
  public var originX:Float;
  public var originY:Float;
  public var size(getSize, setSize):Int;
  public var smooth:Bool;
  public var text(getText, setText):String;
  public var width(getWidth, never):Int;
  public var height(getHeight, never):Int;
  var _alpha:Float;
  var _angle:Float;
  var _color:Int;
  var _colorBitmapData:BitmapData;
  var _colorTransform:ColorTransform;
  var _field:TextField;
  var _font:String;
  var _format:TextFormat;
  var _size:Int;
  var _text:String;
  var _textBitmapData:BitmapData;
  var _textRect:Rectangle;
  var _width:Int;
  var _height:Int;
  static var _matrix:Matrix = new Matrix();

  public function new(text:String, x:Float=0, y:Float=0) {
    if (_fontEmbeddedCache == null) {
      updateFontCache();
    }
    super();
    this.x = x;
    this.y = y;
    smooth = defaultSmooth;
    _alpha = 1.0;
    _angle = 0;
    _color = 0xffffff;
    _colorTransform = new ColorTransform();
    _format = new TextFormat(defaultFont, defaultSize, 0xffffff);
    _field = new TextField();
    _field.embedFonts = isEmbeddedFont(defaultFont);
    _field.antiAliasType = flash.text.AntiAliasType.ADVANCED;
    _field.defaultTextFormat = _format;
    _field.text = _text = text;
    _width = Std.int(_field.textWidth + 4);
    _height = Std.int(_field.textHeight + 4);
    _textBitmapData = new BitmapData(_width, _height, true, 0);
    _textRect = _textBitmapData.rect;
    _colorBitmapData = _textBitmapData;
    updateTextBitmapData();
  }

  public function centerOrigin() {
    originX = _width * 0.5;
    originY = _height * 0.5;
  }

  override public function render() {
    var x = this.x;
    var y = this.y;
    if (entity != null && isRelative) {
      x += entity.x;
      y += entity.y;
    }
    if (_angle != 0) {
      _matrix.a = 1;
      _matrix.b = 0;
      _matrix.c = 0;
      _matrix.d = 1;
      _matrix.tx = -originX * _matrix.a;
      _matrix.ty = -originY * _matrix.d;
      _matrix.rotate(_angle * Lo.RAD);
      _matrix.tx += originX + x - Lo.cameraX;
      _matrix.ty += originY + y - Lo.cameraY;
      if (smooth) {
        Lo.stage.quality = StageQuality.HIGH;
      }
      Render.buffer.draw(_colorBitmapData, _matrix, null, null, null, smooth);
      if (smooth) {
        Lo.stage.quality = StageQuality.LOW;
      }
    } else {
      Render.copyPixels(_colorBitmapData, 0, 0, _width, _height, x, y);
    }
  }

  function updateColorBitmapData() {
    if (_alpha != 1 || _color != 0xffffff) {
      if (_colorBitmapData == _textBitmapData) {
        _colorBitmapData = new BitmapData(_width, _height, true, 0);
      }
      _colorBitmapData.copyPixels(_textBitmapData, _textRect, Lo.zero);
      _colorBitmapData.colorTransform(_textRect, _colorTransform);
    } else if (_colorBitmapData != _textBitmapData) {
      _colorBitmapData.copyPixels(_textBitmapData, _textRect, Lo.zero);
    }
  }

  function updateTextBitmapData() {
    _field.setTextFormat(_format);
    _field.width = _width = Std.int(_field.textWidth + 4);
    _field.height = _height = Std.int(_field.textHeight + 4);
    if (_width != _textBitmapData.width || _height != _textBitmapData.height) {
      if (_colorBitmapData != _textBitmapData) {
        _colorBitmapData.dispose();
      }
      _textBitmapData.dispose();
      _textBitmapData = new BitmapData(_width, _height, true, 0);
      _textRect = _textBitmapData.rect;
      _colorBitmapData = _textBitmapData;
    } else {
      _textBitmapData.fillRect(_textRect, 0);
    }
    _textBitmapData.draw(_field);
    updateColorBitmapData();
  }

  inline function getAlpha():Float {
    return _alpha;
  }

  inline function setAlpha(value:Float):Float {
    if (_alpha != value) {
      _alpha = value;
      _colorTransform.alphaMultiplier = value;
      updateColorBitmapData();
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
    }
    return value;
  }

  inline function getAntiAlias():AntiAliasType {
    return _field.antiAliasType;
  }

  inline function setAntiAlias(value:AntiAliasType):AntiAliasType {
    if (_field.antiAliasType != value) {
      _field.antiAliasType = value;
      updateTextBitmapData();
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
      updateColorBitmapData();
    }
    return value;
  }

  inline function getColorTransform():ColorTransform {
    return _color != 0xffffff || _alpha != 1.0 ? _colorTransform : null;
  }

  inline function getFont():String {
    return _font;
  }

  inline function setFont(value:String):String {
    if (_font != value) {
      if (!_fontEmbeddedCache.exists(_font)) {
        throw 'value "' + _font + '" is not a valid font';
      }
      _format.font = _font = value;
      _field.embedFonts = isEmbeddedFont(_font);
      updateTextBitmapData();
    }
    return value;
  }

  inline function getSize():Int {
    return _size;
  }

  inline function setSize(value:Int):Int {
    if (value < 0) {
      throw 'size value must be >= 0';
    }
    if (_size != value) {
      _format.size = _size = value;
      updateTextBitmapData();
    }
    return value;
  }

  inline function getText():String {
    return _text;
  }

  inline function setText(value:String):String {
    if (_text != value) {
      _field.text = _text = value;
      updateTextBitmapData();
    }
    return value;
  }

  inline function getWidth():Int {
    return _width;
  }

  inline function getHeight():Int {
    return _height;
  }

  static public function isEmbeddedFont(font:String):Bool {
    return _fontEmbeddedCache.get(font) == true;
  }

  static public function updateFontCache() {
    _fontEmbeddedCache = new Hash<Bool>();
    for (font in Font.enumerateFonts()) {
      _fontEmbeddedCache.set(font.fontName, font.fontType != FontType.DEVICE);
    }
  }
}
