package hello.collisions;

/**
* Spatial partioning class. Divides a space into a uniform grid of square
* cells. It provides methods for efficiently doing collision tests. World
* inherits from this class.
*/
class Space {
  var _cells:IntHash<SpaceCell>;
  var _cellSize:Int;
  var _stamp:Int;
  var _tmpAABB:AABB;
  var _tmpEntity:Entity;
  var _tmpCircle:Circle;
  var _x:Float;
  var _y:Float;

  public function new(cellSize:Int=32) {
    _cells = new IntHash<SpaceCell>();
    _cellSize = cellSize;
    _stamp = 0;
    _tmpEntity = new Entity();
    _tmpAABB = new AABB(0, 0);
    _tmpAABB.entity = _tmpEntity;
    _tmpCircle = new Circle(0, 0);
    _tmpCircle.entity = _tmpEntity;
    _x = 0;
    _y = 0;
  }

  /**
  * Find all entities that an entity is colliding with.
  */
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

  /**
  * Find all entities colliding with a circle.
  */
  inline public function collideCircle(x:Float, y:Float, radius:Float, mask:Int=0):ValueList<Entity> {
    _tmpEntity.x = 0;
    _tmpEntity.y = 0;
    _tmpEntity.bounds = _tmpCircle;
    _tmpCircle.set(radius, x, y);
    return collide(_tmpEntity, mask);
  }

  /**
  * Find all entities colliding with a rectangle.
  */
  inline public function collideRect(x:Float, y:Float, width:Float, height:Float, mask:Int=0):ValueList<Entity> {
    _tmpEntity.x = 0;
    _tmpEntity.y = 0;
    _tmpEntity.bounds = _tmpAABB;
    _tmpAABB.setMinMax(x, y, x + width, y + height);
    return collide(_tmpEntity, mask);
  }

  /**
  * Find the earliest intersection between a segment and the entities in the
  * space. For more details on how this algorithm works, see:
  * http://www.cs.yorku.ca/~amana/research/grid.pdf
  */
  inline public function intersectSegment(segment:Segment, mask:Int=0):CollisionSweep {
    ++_stamp;
    var sweep = CollisionSweep.create(segment);
    var x1 = segment.x1 - _x;
    var y1 = segment.y1 - _y;
    var x2 = segment.x2 - _x;
    var y2 = segment.y2 - _y;
    var dx = segment.deltaX;
    var dy = segment.deltaY;

    // Calculate our starting grid offset and step.
    // (This is the paper's x, y, stepX, stepY.)
    var gx:Int = Std.int(x1 / _cellSize);
    var gy:Int = Std.int(y1 / _cellSize);
    var gsx:Int = dx < 0 ? -1 : 1;
    var gsy:Int = dy < 0 ? -1 : 1;
    if (!intersectSegmentCell(gx, gy, sweep)) {
      // Calculate the starting time offset and step.
      // This is placed along the edge of the current cell.
      // (This is the paper's tMaxX, tMaxY, tDeltaX, tDeltaY.)

      var tx:Float, tsx:Float = (_cellSize * gsx) / dx;
      if (dx == 0) {
        tx = 1;
      } else {
        tx = gx * _cellSize;
        if (dx > 0) {
          tx += _cellSize - 1;
        }
        tx = (tx - x1) / dx;
        if (tx > 1) {
          tx = 1;
        }
      }

      var ty:Float, tsy:Float = (_cellSize * gsy) / dy;
      if (dy == 0) {
        ty = 1;
      } else {
        ty = gy * _cellSize;
        if (dy > 0) {
          ty += _cellSize - 1;
        }
        ty = (ty - y1) / dy;
        if (ty > 1) {
          ty = 1;
        }
      }

      // Iterate until it hits something or reaches the end of the line.
      while (tx < 1 || ty < 1) {
        if (tx < ty) {
          gx += gsx;
          tx += tsx;
          if (intersectSegmentCell(gx, gy, sweep)) {
            break;
          }
        } else {
          gy += gsy;
          ty += tsy;
          if (intersectSegmentCell(gx, gy, sweep)) {
            break;
          }
        }
      }
    }

    return sweep;
  }

  /**
  * Convenience method to call `intersectSegment` without having to actually
  * create the segment.
  */
  inline public function intersectSegmentXY(x1:Float, y1:Float, x2:Float, y2:Float, mask:Int=0):CollisionSweep {
    return intersectSegment(new Segment(x1, y1, x2, y2), mask);
  }

  /**
  * Internal helper for `intersectSegment`, to collide against entities in a
  * given space cell. Returns true if the sweep hit anything.
  */
  inline function intersectSegmentCell(col:Int, row:Int, sweep:CollisionSweep):Bool {
    var intersected = false;
    var cell = getCell(col, row);
    if (cell != null) {
      var node = cell.entities.first;
      while (node != null) {
        var entity = node.value;
        node = node.next;
        if (entity.isCollidable && entity.stamp != _stamp) {
          entity.stamp = _stamp;
          if (entity.hasFlags(sweep.mask)
          && entity.bounds.intersectSegment(sweep)) {
            intersected = true;
          }
        }
      }
    }
    return intersected;
  }

  /**
  * Sweep an entity through the world, from from `(segment.x1, segment.y1)`
  * to `(segment.x2, segment.y2)`, testing for collisions with any entities
  * that intersect the movement. Returns a `CollisionSweep` object. If a
  * collision occurred, `sweep.hit` will be set to the hit position.
  *
  * `sweep.x` and `sweep.y` will be set to the furthest position the entity
  * reached (the end point of the move, if no collision). `sweep.time` will
  * be set to the percentage of the move completed (from 0 to 1).
  *
  * You shouldn't need to call this method directly; instead, use
  * `entity.moveBy()` or `entity.moveTo()`.
  */
  inline public function sweep(entity:Entity, segment:Segment, mask:Int=0):CollisionSweep {
    ++_stamp;

    var sweep = CollisionSweep.create(segment);
    var minX = Lo.min(segment.x1, segment.x2);
    var minY = Lo.min(segment.y1, segment.y2);
    var maxX = Lo.max(segment.x1, segment.x2);
    var maxY = Lo.max(segment.y1, segment.y2);
    minX -= entity.bounds.halfWidth;
    minY -= entity.bounds.halfHeight;
    maxX += entity.bounds.halfWidth;
    maxY += entity.bounds.halfHeight;

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
            && minX <= other.maxX && minY <= other.maxY) {
              entity.bounds.sweep(sweep, other.bounds);
            }
          }
        }
      }
      row++;
    }

    return sweep;
  }

  /**
  * Convenience method to call `sweep` without having to actually create the
  * segment for the move.
  */
  inline public function sweepXY(entity:Entity, x:Float, y:Float, mask:Int=0):CollisionSweep {
    return sweep(entity, new Segment(entity.originX, entity.originY, x, y), mask);
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
