package;

class Space {
  var _cells:IntHash<SpaceCell>;
  var _cellSize:Int;
  var _stamp:Int;
  var _x:Float;
  var _y:Float;

  public function new(cellSize:Int=32) {
    _cells = new IntHash<SpaceCell>();
    _cellSize = cellSize;
    _stamp = 0;
    _x = 0;
    _y = 0;
  }

  inline public function collide(entity:Entity, mask:Int=0):ValueList<Entity> {
    ++_stamp;
    var list = Entity.listPool.create();
    var minX = entity.minX;
    var minY = entity.minY;
    var maxX = entity.maxX;
    var maxY = entity.maxY;
    var col1 = getColumn(Std.int(minX));
    var col2 = getColumn(Std.int(Lo.ceil(maxX)));
    var row1 = getRow(Std.int(minY));
    var row2 = getRow(Std.int(Lo.ceil(maxY)));
    var row = row1;
    while (row <= row2) {
      var col = col1;
      while (col <= col2) {
        var cell = getCell(col++, row);
        if (cell == null) {
          continue;
        }
        var node = cell.entities.first;
        while (node != null) {
          var other = node.value;
          node = node.next;
          if (entity != other && other.isCollidable && other.stamp != _stamp) {
            other.stamp = _stamp;
            if (other.hasFlags(mask)
            && maxX >= other.minX && maxY >= other.minY
            && minX <= other.maxX && minY <= other.maxY
            && entity.bounds.collide(other.bounds)) {
              list.add(other);
            }
          }
        }
      }
      row++;
    }
    return list;

  }

  inline public function collideCircle(x:Float, y:Float, radius:Float, mask:Int=0):ValueList<Entity> {
    return null;
  }

  inline public function collideRect(x:Float, y:Float, width:Float, height:Float, mask:Int=0):ValueList<Entity> {
    return null;
  }

  inline public function collideSegment(x1:Float, y1:Float, x2:Float, y2:Float, mask:Int=0):ValueList<Entity> {
    return null;
  }

  /**
  * Update the cell list for an entity.
  */
  public function updateEntityCells(entity:Entity) {
    var x1 = entity.x;
    var y1 = entity.y;
    var x2 = x1 + entity.width;
    var y2 = y1 + entity.height;

    // Remove entity from its old cells
    var cells = entity.cells;
    while (cells.first != null) {
      var cell = cells.shift();
      cell.entities.remove(entity);
    }

    // Add entity to its new cells
    var col1 = getColumn(Std.int(x1));
    var col2 = getColumn(Std.int(Lo.ceil(x2)));
    var row1 = getRow(Std.int(y1));
    var row2 = getRow(Std.int(Lo.ceil(y2)));
    var row = row1;
    while (row <= row2) {
      var col = col1;
      while (col <= col2) {
        var cell = getCell(col, row, true);
        cell.entities.add(entity);
        cells.add(cell);
        ++col;
      }
      ++row;
    }
  }

  /**
  * Return the cell for a given column and row, or null if the cell doesn't
  * exist. If create is true, the cell will be created if it does not exist.
  */
  inline function getCell(col:Int, row:Int, create:Bool=false):SpaceCell {
    var key = getCellKey(col, row);
    var cell = _cells.get(key);
    if (cell == null && create) {
      cell = new SpaceCell(key, col, row);
      _cells.set(key, cell);
    }
    return cell;
  }

  /**
  * Return the cell hash key for a given column and row.
  */
  inline function getCellKey(col:Int, row:Int):Int {
    return (col << 11) | row;
  }

  /**
  * Return the cell column for a world X coordinate.
  */
  inline function getColumn(x:Int):Int {
    return Std.int((x - _x) / _cellSize);
  }

  /**
  * Return the cell row for a world Y coordinate.
  */
  inline function getRow(y:Int):Int {
    return Std.int((y - _y) / _cellSize);
  }
}
