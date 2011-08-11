package;

class World {
  public var isActive:Bool;
  public var isVisible:Bool;

  public function new() {
    isActive = true;
    isVisible = true;
  }

  public function begin() {

  }

  public function end() {

  }

  /**
  * Process one frame of the world.
  */
  public function tick() {
    if (isActive) {
      update();
    }
    if (isVisible) {
      render();
    }
  }

  /**
  * Render all the visible graphics in the world, layer by layer.
  */
  public function render() {

  }

  /**
  * Update all the active entities in the world.
  */
  public function update() {

  }
}
