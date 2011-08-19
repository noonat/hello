package hello.collisions;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
* A grid collision object, for use with `Tilemap`.
*/
class Grid extends Bounds {
  public var cols(getCols, never):Int;
  public var rows(getRows, never):Int;
  public var data(getData, never):BitmapData;
  public var tileWidth(getTileWidth, never):Int;
  public var tileHeight(getTileHeight, never):Int;
  public var usePositions:Bool;
  var _cols:Int;
  var _rows:Int;
  var _data:BitmapData;
  var _tileWidth:Int;
  var _tileHeight:Int;
  static var _rect:Rectangle = new Rectangle();
  static var _zero:Point = new Point();

  public function new(width:Int, height:Int, tileWidth:Int, tileHeight:Int) {
    if (width <= 0 || height <= 0 || tileWidth <= 0 || tileHeight <= 0) {
      throw 'Illegal Grid, sizes must be greater than 0';
    }
    super(BoundsType.GRID);
    _grid = this;
    _width = width;
    _height = height;
    _halfWidth = _width / 2;
    _halfHeight = _height / 2;
    x = _halfWidth;
    y = _halfHeight;
    _tileWidth = tileWidth;
    _tileHeight = tileHeight;
    _cols = Std.int(_width / _tileWidth);
    _rows = Std.int(_height / _tileHeight);
    _data = new BitmapData(_cols, _rows, true, 0);
  }

  public function setTile(col:Int, row:Int, isSolid:Bool) {
    if (usePositions) {
      col = Std.int(col / _tileWidth);
      row = Std.int(row / _tileHeight);
    }
    _data.setPixel32(col, row, isSolid ? 0xffffffff : 0);
  }

  inline public function clearTile(col:Int, row:Int) {
    setTile(col, row, false);
  }

  inline public function getTile(col:Int, row:Int):Bool {
    if (usePositions) {
      col = Std.int(col / _tileWidth);
      row = Std.int(row / _tileHeight);
    }
    return _data.getPixel32(col, row) > 0;
  }

  public function setRect(col:Int, row:Int, width:Int, height:Int, isSolid:Bool) {
    if (usePositions) {
      col = Std.int(col / _tileWidth);
      row = Std.int(row / _tileHeight);
      width = Std.int(width / _tileWidth);
      height = Std.int(height / _tileHeight);
    }
    _rect.x = col;
    _rect.y = row;
    _rect.width = width;
    _rect.height = height;
    _data.fillRect(_rect, isSolid ? 0xFFFFFF : 0);
  }

  inline public function clearRect(col:Int=0, row:Int=0, width:Int=1, height:Int=1) {
    setRect(col, row, width, height, false);
  }

  public function loadFromString(s:String, columnSep:String=",", rowSep:String="\n") {
    var row = StringTools.trim(s).split(rowSep);
    for (y in 0...row.length) {
      if (row[y] == '') {
        continue;
      }
      var col = row[y].split(columnSep);
      for (x in 0...col.length) {
        if (col[x] == '') {
          continue;
        }
        setTile(x, y, Std.parseInt(col[x]) > 0);
      }
    }
  }

  public function saveToString(columnSep:String=",", rowSep:String="\n"):String {
    var s = '';
    for (y in 0..._rows) {
      for (x in 0..._cols) {
        s += getTile(x, y) ? '1' : '0';
        if (x != _cols - 1) {
          s += columnSep;
        }
      }
      if (y != _rows - 1) {
        s += rowSep;
      }
    }
    return s;
  }

  inline function getCols():Int {
    return _cols;
  }

  inline function getRows():Int {
    return _rows;
  }

  inline function getData():BitmapData {
    return _data;
  }

  inline function getTileWidth():Int {
    return _tileWidth;
  }

  inline function getTileHeight():Int {
    return _tileHeight;
  }
}
