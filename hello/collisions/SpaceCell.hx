package hello.collisions;

class SpaceCell {
  public var key:Int;
  public var col:Int;
  public var row:Int;
  public var stamp:Int;
  public var entities:ValueList<Entity>;

  public function new(key, col, row) {
    this.key = key;
    this.col = col;
    this.row = row;
    entities = Entity.listPool.create();
  }

  inline public function add(entity:Entity):ValueNode<Entity> {
    return !entities.has(entity) ? entities.add(entity) : null;
  }

  inline public function clear() {
    entities.clear();
  }

  inline public function free() {
    clear();
    entities.free();
  }

  inline public function has(entity:Entity):Bool {
    return entities.has(entity);
  }

  inline public function remove(entity:Entity) {
    entities.remove(entity);
  }

  static public var listPool:ValueListPool<SpaceCell>;
  static public var nodePool:ValueNodePool<SpaceCell>;

  static public function __init__() {
    nodePool = new ValueNodePool<SpaceCell>();
    listPool = new ValueListPool<SpaceCell>(nodePool);
  }
}
