package hello;

import hello.collisions.AABB;
import hello.collisions.Bounds;
import hello.collisions.CollisionSweep;
import hello.collisions.Segment;
import hello.collisions.SpaceCell;

private typedef WorldFriend = {
  function addToLayers(graphic:Graphic):Void;
  function removeFromLayers(graphic:Graphic):Void;
  function addToNames(entity:Entity):Void;
  function removeFromNames(entity:Entity):Void;
  function addToTags(entity:Entity, tag:String):Void;
  function removeFromTags(entity:Entity, tag:String):Void;
};

class Entity {
  public var bounds(getBounds, setBounds):Bounds;
  public var cells(getCells, never):ValueList<SpaceCell>;
  public var graphics(getGraphics, never):ValueList<Graphic>;
  public var flags:Int;
  public var isActive:Bool;
  public var isVisible:Bool;
  public var isCollidable:Bool;
  public var name(getName, setName):String;
  public var stamp:Int;
  public var sweep:CollisionSweep;
  public var world:World;
  public var x(getX, setX):Float;
  public var y(getY, setY):Float;

  // These are just shorthand for hitbox values transformed to entity space.
  public var originX(getOriginX, never):Float;
  public var originY(getOriginY, never):Float;
  public var minX(getMinX, never):Float;
  public var minY(getMinY, never):Float;
  public var maxX(getMaxX, never):Float;
  public var maxY(getMaxY, never):Float;
  public var halfWidth(getHalfWidth, never):Float;
  public var halfHeight(getHalfHeight, never):Float;
  public var width(getWidth, never):Float;
  public var height(getHeight, never):Float;

  var _bounds:Bounds;
  var _cells:ValueList<SpaceCell>;
  var _graphics:ValueList<Graphic>;
  var _graphicsToAdd:ValueList<Graphic>;
  var _graphicsToRemove:ValueList<Graphic>;
  var _name:String;
  var _tags:Hash<Bool>;
  var _tmpSegment:Segment;
  var _x:Float;
  var _y:Float;

  public function new(x:Float=0, y:Float=0, bounds:Bounds=null) {
    this.x = x;
    this.y = y;
    if (bounds != null) {
      this.bounds = bounds;
    } else {
      this.bounds = new AABB(0, 0);
    }
    flags = 0;
    isActive = true;
    isVisible = true;
    isCollidable = true;
    stamp = 0;
    world = null;
    _cells = SpaceCell.listPool.create();
    _graphics = Graphic.listPool.create();
    _name = null;
    _tags = new Hash<Bool>();
  }

  public function added() {

  }

  public function removed() {

  }

  public function update() {

  }

  inline public function moveBy(dx:Float, dy:Float, mask:Int=0):CollisionSweep {
    if (sweep != null) {
      sweep.free();
      sweep = null;
    }
    if (world != null) {
      if (_tmpSegment == null) {
        _tmpSegment = new Segment(originX, originY, originX + dx, originY + dy);
      } else {
        _tmpSegment.set(originX, originY, originX + dx, originY + dy);
      }
      sweep = world.sweep(this, _tmpSegment, mask);
      _x = sweep.x - _bounds.x;
      _y = sweep.y - _bounds.y;
      world.updateEntityCells(this);
    } else {
      _x += dx;
      _y += dy;
    }
    return sweep;
  }

  inline public function addGraphic(graphic:Graphic) {
    if (graphic.entity == null) {
      _graphics.add(graphic);
      graphic.entity = this;
      graphic.added();
      if (world != null) {
        getWorldFriend().addToLayers(graphic);
      }
    }
  }

  inline public function removeGraphic(graphic:Graphic) {
    if (graphic.entity == this) {
      if (world != null) {
        getWorldFriend().removeFromLayers(graphic);
      }
      graphic.removed();
      graphic.entity = null;
      _graphics.remove(graphic);
    }
  }

  inline public function addTag(tag:String) {
    if (!hasTag(tag)) {
      _tags.set(tag, true);
      if (world != null) {
        getWorldFriend().addToTags(this, tag);
      }
    }
  }

  inline public function getTags():Iterator<String> {
    return _tags.keys();
  }

  inline public function hasTag(tag:String):Bool {
    return _tags.exists(tag);
  }

  inline public function removeTag(tag:String) {
    if (world != null) {
      if (_tags.exists(tag)) {
        getWorldFriend().removeFromTags(this, tag);
      }
    }
    _tags.remove(tag);
  }

  inline public function removeAllTags() {
    if (world != null) {
      for (tag in getTags()) {
        getWorldFriend().removeFromTags(this, tag);
        _tags.remove(tag);
      }
    } else {
      for (tag in getTags()) {
        _tags.remove(tag);
      }
    }
  }

  inline public function addFlags(mask:Int) {
    flags |= mask;
  }

  inline public function removeFlags(mask:Int) {
    flags &= ~mask;
  }

  inline public function hasFlags(mask:Int):Bool {
    return flags & mask == mask;
  }

  inline public function hasAnyFlags(mask:Int):Bool {
    return flags & mask != 0;
  }

  inline function getCells():ValueList<SpaceCell> {
    return _cells;
  }

  inline function getGraphics():ValueList<Graphic> {
    return _graphics;
  }

  inline function getBounds():Bounds {
    return _bounds;
  }

  inline function setBounds(value:Bounds):Bounds {
    if (value == null) {
      // FIXME: set to AABB(0, 0) instead?
      throw "entity bounds cannot be set to null";
    }
    if (_bounds != value) {
      _bounds = value;
      _bounds.entity = this;
    }
    return value;
  }

  inline function getName():String {
    return _name;
  }

  inline function setName(value:String):String {
    if (world != null) {
      if (_name != null) {
        getWorldFriend().removeFromNames(this);
      }
      _name = value;
      if (_name != null) {
        getWorldFriend().addToNames(this);
      }
    } else {
      _name = value;
    }
    return value;
  }

  inline function getX():Float {
    return _x;
  }

  inline function setX(value:Float):Float {
    return _x = value;
  }

  inline function getY():Float {
    return _y;
  }

  inline function setY(value:Float):Float {
    return _y = value;
  }

  inline function getOriginX():Float {
    return _x + _bounds.x;
  }

  inline function getOriginY():Float {
    return _y + _bounds.y;
  }

  inline function getMinX():Float {
    return _x + _bounds.minX;
  }

  inline function getMinY():Float {
    return _y + _bounds.minY;
  }

  inline function getMaxX():Float {
    return _x + _bounds.maxX;
  }

  inline function getMaxY():Float {
    return _y + _bounds.maxY;
  }

  inline function getHalfWidth():Float {
    return _bounds.halfWidth;
  }

  inline function getHalfHeight():Float {
    return _bounds.halfHeight;
  }

  inline function getWidth():Float {
    return _bounds.width;
  }

  inline function getHeight():Float {
    return _bounds.height;
  }

  inline function getWorldFriend():WorldFriend {
    return untyped world;
  }

  static public var listPool:ValueListPool<Entity>;
  static public var nodePool:ValueNodePool<Entity>;

  static public function __init__() {
    nodePool = new ValueNodePool<Entity>();
    listPool = new ValueListPool<Entity>(nodePool);
  }
}
