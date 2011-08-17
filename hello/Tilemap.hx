package hello;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
using Mixins;

class Tilemap extends Graphic {
  public var cols(getCols, never):Int;
  public var rows(getRows, never):Int;
  public var tileWidth(getTileWidth, never):Int;
  public var tileHeight(getTileHeight, never):Int;
  public var tilesetCount(getTilesetCount, never):Int;
  public var usePositions:Bool;
  public var width(getWidth, never):Int;
  public var height(getHeight, never):Int;
  private var _buffer:BitmapData;
  private var _bufferRect:Rectangle;
  private var _cols:Int;
  private var _rows:Int;
  private var _rect:Rectangle;
  private var _tilemap:BitmapData;
  private var _tilemapRect:Rectangle;
  private var _tileset:Texture;
  private var _tilesetCols:Int;
  private var _tilesetRows:Int;
  private var _tilesetCount:Int;
  private var _tileRect:Rectangle;
  private var _width:Int;
  private var _height:Int;

  public function new(tileset:Texture, width:Int, height:Int, tileWidth:Int, tileHeight:Int) {
    super();
    if (tileset == null) {
      throw 'Tileset texture cannot be null.';
    }
    if (tileWidth <= 0 || tileHeight <= 0) {
      throw 'Tile width and height must be greater than zero';
    }
    if (width <= 0 || height <= 0) {
      throw 'Tilemap width and height must be greater than zero';
    }
    _width = width - (width % tileWidth);
    _height = height - (height % tileHeight);
    _buffer = new BitmapData(_width, _height, true, 0);
    _bufferRect = _buffer.rect;
    _cols = Std.int(_width / tileWidth);
    _rows = Std.int(_height / tileHeight);
    _rect = new Rectangle();
    _tileRect = new Rectangle(0, 0, tileWidth, tileHeight);
    _tilemap = new BitmapData(_cols, _rows, false, 0);
    _tilemapRect = _tilemap.rect;
    _tileset = tileset;
    _tilesetCols = Std.int(_tileset.rect.width / tileWidth);
    _tilesetRows = Std.int(_tileset.rect.height / tileHeight);
    _tilesetCount = _tilesetCols * _tilesetRows;
  }

  override public function render() {
    var px = x - Lo.cameraX * scrollX;
    var py = y - Lo.cameraY * scrollY;
    if (entity != null && relative) {
      px += entity.x;
      py += entity.y;
    }
    var rx:Float = 0.0;
    var ry:Float = 0.0;
    var rw:Float = Lo.min(_bufferRect.width, Lo.width);
    var rh:Float = Lo.min(_bufferRect.height, Lo.height);
    if (px < 0) {
      rx -= px;
      px = 0.0;
    } else {
      rw -= px;
    }
    if (py < 0) {
      ry -= py;
      py = 0.0;
    } else {
      rh -= py;
    }
    if (rw > 0 && rh > 0) {
      _point.x = px;
      _point.y = py;
      _rect.x = rx;
      _rect.y = ry;
      _rect.width = rw;
      _rect.height = rh;
      Render.buffer.copyPixels(_buffer, _rect, _point, null, null, true);
    }
  }

  inline public function getTile(col:Int, row:Int) {
    if (usePositions) {
      col = Std.int(col / _tileRect.width);
      row = Std.int(row / _tileRect.height);
    }
    return _tilemap.getPixel(col % _cols, row % _rows);
  }

  public function setTile(col:Int, row:Int, index:Int=0) {
    if (usePositions) {
      col = Std.int(col / _tileRect.width);
      row = Std.int(row / _tileRect.height);
    }
    index %= _tilesetCount;
    col %= _cols;
    row %= _rows;
    var tx = (index % _tilesetCols) * _tileRect.width;
    var ty = Std.int(index / _tilesetCols) * _tileRect.height;
    var x = col * _tileRect.width;
    var y = row * _tileRect.height;
    _tilemap.setPixel(col, row, index);
    _tileset.copyRectInto(
      _buffer, x, y, tx, ty, _tileRect.width, _tileRect.height, false, false);
  }

  public function setRect(col:Int, row:Int, width:Int = 1, height:Int = 1, index:Int = 0):Void {
    if (usePositions) {
      col = Std.int(col / _tileRect.width);
      row = Std.int(row / _tileRect.height);
      width = Std.int(width / _tileRect.width);
      height = Std.int(height / _tileRect.height);
    }
    var oldUsePositions = usePositions;
    usePositions = false;
    col %= _cols;
    row %= _rows;
    var colMin = col;
    var colMax = col + width;
    var rowMax = row + height;
    while (row < rowMax) {
      while (col < colMax) {
        setTile(col, row, index);
        ++col;
      }
      col = colMin;
      ++row;
    }
    usePositions = oldUsePositions;
  }

  public function clearTile(col:Int, row:Int) {
    if (usePositions) {
      col = Std.int(col / _tileRect.width);
      row = Std.int(row / _tileRect.height);
    }
    col %= _cols;
    row %= _rows;
    _tileRect.x = col * _tileRect.width;
    _tileRect.y = row * _tileRect.height;
    _buffer.fillRect(_tileRect, 0);
  }

  public function clearRect(col:Int, row:Int, width:Int, height:Int):Void {
    if (usePositions) {
      col = Std.int(col / _tileRect.width);
      row = Std.int(row / _tileRect.height);
      width = Std.int(width / _tileRect.width);
      height = Std.int(height / _tileRect.height);
    }
    var oldUsePositions = usePositions;
    usePositions = false;
    col %= _cols;
    row %= _rows;
    var colMin = col;
    var colMax = col + width;
    var rowMax = row + height;
    while (row < rowMax) {
      while (col < colMax) {
        clearTile(col, row);
        ++col;
      }
      col = colMin;
      ++row;
    }
    usePositions = oldUsePositions;
  }

  public function randomizeRect(col:Int, row:Int, width:Int, height:Int, tiles:Array<Int>) {
    if (usePositions) {
      col = Std.int(col / _tileRect.width);
      row = Std.int(row / _tileRect.height);
      width = Std.int(width / _tileRect.width);
      height = Std.int(height / _tileRect.height);
    }
    var oldUsePositions = usePositions;
    usePositions = false;
    col %= _cols;
    row %= _rows;
    var colMin = col;
    var colMax = col + width;
    var rowMax = row + height;
    while (row < rowMax) {
      while (col < colMax) {
        setTile(col, row, Lo.choose(tiles));
        ++col;
      }
      col = colMin;
      ++row;
    }
    usePositions = oldUsePositions;
  }

  public function loadFromString(str:String, columnSep:String=",", rowSep:String="\n") {
    var row = StringTools.trim(str).split(rowSep);
    for (y in 0...row.length) {
      if (row[y] == '') {
        continue;
      }
      var col = row[y].split(columnSep);
      for (x in 0...col.length) {
        if (col[x] == '') {
          continue;
        }
        setTile(x, y, Std.parseInt(col[x]));
      }
    }
  }

  public function saveToString(columnSep:String=",", rowSep:String="\n"):String {
    var s = '';
    for (y in 0..._rows) {
      for (x in 0..._cols) {
        s += Std.string(getTile(x, y));
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

  // public function createGrid(solidTiles:Array<Int>, cls:Class<Grid>=null):Grid {
  //   if (cls == null) {
  //     cls = Grid;
  //   }
  //   var grid:Grid = Type.createInstance(cls, [_width, _height, tileWidth, tileHeight]);
  //   for (row in 0..._rows) {
  //     for (col in 0..._cols) {
  //       if (solidTiles.indexOf(getTile(col, row)) != -1) {
  //         grid.setTile(col, row, true);
  //       }
  //     }
  //   }
  //   return grid;
  // }

  inline public function getTilesetIndex(col:Int, row:Int):Int {
    return (row % _tilesetRows) * _tilesetCols + (col % _tilesetCols);
  }

  inline function getTilesetCount():Int {
    return _tilesetCount;
  }

  inline function getTileWidth():Int {
    return Std.int(_tileRect.width);
  }

  inline function getTileHeight():Int {
    return Std.int(_tileRect.height);
  }

  inline function getCols():Int {
    return _cols;
  }

  inline function getRows():Int {
    return _rows;
  }

  inline function getWidth():Int {
    return _width;
  }

  inline function getHeight():Int {
    return _height;
  }
}
