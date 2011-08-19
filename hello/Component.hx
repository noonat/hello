package hello;

class Component {
  public var entity:Entity;
  public var isActive:Bool;
  public var isVisible:Bool;
  public var world(getWorld, never):World;

  public function new() {
    entity = null;
    isActive = false;
    isVisible = false;
  }

  public function added() {

  }

  public function addedToWorld() {

  }

  public function removed() {

  }

  public function removedFromWorld() {

  }

  public function render() {

  }

  public function reset() {

  }

  public function update() {

  }

  inline function getWorld():World {
    return entity != null ? entity.world : null;
  }
}
