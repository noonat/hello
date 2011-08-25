package hello;

import hello.collisions.AABB;
import hello.collisions.Bounds;
import hello.collisions.CollisionSweep;
import hello.collisions.Segment;
import hello.collisions.SpaceCell;
import hello.graphics.Graphic;

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
  public var isSynchronized(getIsSynchronized, never):Bool;
  public var name(getName, setName):String;
  public var stamp:Int;
  public var sweep:CollisionSweep;
  public var world:World;
  public var x(getX, setX):Float;
  public var y(getY, setY):Float;
  public var previousX:Float;
  public var previousY:Float;

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
  var _components:Hash<Component>;
  var _graphics:ValueList<Graphic>;
  var _name:String;
  var _spaceX:Float;
  var _spaceY:Float;
  var _tags:Hash<Bool>;
  var _tmpSegment:Segment;
  var _x:Float;
  var _y:Float;

  public function new(x:Float=0, y:Float=0, bounds:Bounds=null, graphic:Graphic=null) {
    this.x = x;
    this.y = y;
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
    if (bounds != null) {
      this.bounds = bounds;
    } else {
      this.bounds = new AABB(0, 0);
    }
    if (graphic != null) {
      addGraphic(graphic);
    }
  }

  public function added() {

  }

  public function removed() {

  }

  public function update() {

  }

  inline public function moveBy(dx:Float, dy:Float, mask:Int=0, updateCells:Bool=true):CollisionSweep {
    if (sweep != null) {
      sweep.free();
      sweep = null;
    }
    if (world != null) {
      var oldX = _x;
      var oldY = _y;
      if (_tmpSegment == null) {
        _tmpSegment = new Segment();
      }
      _tmpSegment.set(_x, _y, _x + dx, _y + dy);
      sweep = world.sweep(this, _tmpSegment, mask);
      _x = sweep.x;
      _y = sweep.y;
      if (updateCells && (_x != oldX || _y != oldY)) {
        world.updateEntityCells(this);
      }
    } else {
      _x += dx;
      _y += dy;
    }
    return sweep;
  }

  inline public function slideMoveBy(dx:Float, dy:Float, mask:Int=0, updateCells:Bool=true) {
    if (world != null) {
      var oldX = _x;
      var oldY = _y;
      moveBy(dx, 0, mask, false);
      moveBy(0, dy, mask, false);
      if (updateCells && (_x != oldX || _y != oldY)) {
        world.updateEntityCells(this);
      }
    } else {
      _x += dx;
      _y += dy;
    }
  }

  public function segmentTo(entity:Entity, segment:Segment=null):Segment {
    if (segment == null) {
      segment = new Segment(originX, originY, entity.originX, entity.originY);
    } else {
      segment.set(originX, originY, entity.originX, entity.originY);
    }
    var sweep = CollisionSweep.create(segment);
    if (entity.bounds.intersectSegment(sweep)) {
      segment.x2 = segment.x1 + segment.deltaX * sweep.time;
      segment.y2 = segment.y1 + segment.deltaY * sweep.time;
    }
    if (_tmpSegment == null) {
      _tmpSegment = new Segment();
    }
    _tmpSegment.set(entity.originX, entity.originY, originX, originY);
    sweep.segment = _tmpSegment;
    sweep.time = 1;
    if (bounds.intersectSegment(sweep)) {
      segment.x1 = _tmpSegment.x1 + _tmpSegment.deltaX * sweep.time;
      segment.y1 = _tmpSegment.y1 + _tmpSegment.deltaY * sweep.time;
    }
    sweep.free();
    return segment;
  }

  inline public function addComponent(name:String, component:Component):Component {
    if (component == null) {
      throw 'Cannot add null "' + name + '" component';
    }
    if (_components == null) {
      _components = new Hash<Component>();
    }
    removeComponent(name);
    _components.set(name, component);
    component.entity = this;
    component.reset();
    component.added();
    if (world != null) {
      component.addedToWorld();
    }
    return component;
  }

  inline public function getComponent(name:String, type:Class<Component>):Dynamic {
    var component:Component = if (_components != null) {
      _components.get(name);
    } else {
      null;
    }
    return if (Std.is(component, type)) {
      component;
    } else {
      null;
    }
  }

  inline public function hasComponent(name:String):Bool {
    return _components != null ? _components.exists(name) : false;
  }

  inline public function removeComponent(name:String):Component {
    return if (_components != null) {
      var component = _components.get(name);
      if (component != null) {
        _components.remove(name);
        if (world != null) {
          component.removedFromWorld();
        }
        component.removed();
        component.entity = null;
      }
      component;
    }
  }

  inline public function updateComponent(component:Component) {
    if (component != null && component.isActive) {
      component.update();
    }
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

  inline function getIsSynchronized():Bool {
    return (
      Lo.abs(_spaceX - _x) < Lo.EPSILON &&
      Lo.abs(_spaceY - _y) < Lo.EPSILON);
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
