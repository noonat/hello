package hello;

class Image extends Graphic {
  public var isFlipped:Bool;
  public var texture:Texture;

  public function new(texture:Texture) {
    super();
    this.isFlipped = false;
    this.texture = texture;
  }

  override public function render() {
    var px = x - Lo.cameraX * scrollX;
    var py = y - Lo.cameraY * scrollY;
    if (entity != null && relative) {
      px += entity.x;
      py += entity.y;
    }
    Render.drawTexture(texture, px, py, isFlipped);
  }
}
