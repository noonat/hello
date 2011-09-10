package hello;

import hello.graphics.Graphic;

class Component {
   public var entity:Entity;
   public var isActive:Bool;
   public var world(getWorld, never):World;

   public function new() {
      entity = null;
      isActive = false;
   }

   public function added() {

   }

   public function addedToWorld() {

   }

   public function removed() {

   }

   public function removedFromWorld() {

   }

   public function reset() {

   }

   public function update() {

   }

   inline function getWorld():World {
      return entity != null ? entity.world : null;
   }
}
