package;

private typedef WorldFriend = {
  function addToLayers(graphic:Graphic):Void;
  function removeFromLayers(graphic:Graphic):Void;
  function addToNames(entity:Entity):Void;
  function removeFromNames(entity:Entity):Void;
  function addToTags(entity:Entity, tag:String):Void;
  function removeFromTags(entity:Entity, tag:String):Void;
};

class Entity {
  public var graphics(getGraphics, never):ValueList<Graphic>;
  public var flags:Int;
  public var isActive:Bool;
  public var isVisible:Bool;
  public var name(getName, setName):String;
  public var world:World;
  public var x(getX, setX):Float;
  public var y(getY, setY):Float;

  var _graphics:ValueList<Graphic>;
  var _graphicsToAdd:ValueList<Graphic>;
  var _graphicsToRemove:ValueList<Graphic>;
  var _name:String;
  var _tags:Hash<Bool>;
  var _x:Float;
  var _y:Float;

  public function new() {
    flags = 0;
    isActive = true;
    isVisible = true;
    world = null;
    _graphics = Graphic.listPool.create();
    _name = null;
    _tags = new Hash<Bool>();
    _x = 0;
    _y = 0;
  }

  public function added() {
    
  }

  public function removed() {
    
  }

  public function update() {
    
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

  inline function getGraphics():ValueList<Graphic> {
    return _graphics;
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
