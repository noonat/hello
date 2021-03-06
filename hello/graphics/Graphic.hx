package hello.graphics;

import flash.geom.Point;

private typedef WorldFriend = {
   function addToLayers(graphic:Graphic):Void;
   function removeFromLayers(graphic:Graphic):Void;
};

class Graphic {
   public var entity:Entity;
   public var isActive:Bool;
   public var isRelative:Bool;
   public var isVisible:Bool;
   public var layer(getLayer, setLayer):Int;
   public var world(getWorld, never):World;
   public var x:Float;
   public var y:Float;
   var _layer:Int;
   var _point:Point;

   public function new() {
      entity = null;
      isActive = false;
      isRelative = true;
      isVisible = true;
      x = 0;
      y = 0;
      _layer = 0;
      _point = new Point();
   }

   public function added() {

   }

   public function removed() {

   }

   public function render(renderer:Render) {

   }

   public function update() {

   }

   inline function getLayer():Int {
      return _layer;
   }

   inline function setLayer(value:Int):Int {
      if (_layer != value) {
         if (world != null) {
            getWorldFriend().removeFromLayers(this);
            _layer = value;
            getWorldFriend().addToLayers(this);
         } else {
            _layer = value;
         }
      }
      return value;
   }

   inline function getWorld():World {
      return entity != null ? entity.world : null;
   }

   inline function getWorldFriend():WorldFriend {
      return untyped world;
   }

   static public var listPool:ValueListPool<Graphic>;
   static public var nodePool:ValueNodePool<Graphic>;

   static public function __init__() {
      nodePool = new ValueNodePool<Graphic>();
      listPool = new ValueListPool<Graphic>(nodePool);
   }
}
