package;

class World {
  public var isActive:Bool;
  public var isVisible:Bool;
  var _entities:ValueList<Entity>;
  var _entitiesToAdd:ValueList<Entity>;
  var _entitiesToRemove:ValueList<Entity>;
  var _names:Hash<ValueList<Entity>>;
  var _tags:Hash<ValueList<Entity>>;

  public function new() {
    isActive = true;
    isVisible = true;
    _entities = Entity.listPool.create();
    _entitiesToAdd = Entity.listPool.create();
    _entitiesToRemove = Entity.listPool.create();
    _names = new Hash<ValueList<Entity>>();
    _tags = new Hash<ValueList<Entity>>();
  }

  public function begin() {
    
  }

  public function end() {
    removeAll();
    resolvePending();
  }

  /**
  * Add an entity to the world. The entity will not be added until the end of
  * the current frame.
  */
  public function add(entity:Entity) {
    _entitiesToAdd.add(entity);
  }

  /**
  * Remove an entity from the world. The entity will not be removed until the
  * end of the current frame.
  */
  public function remove(entity:Entity) {
    _entitiesToRemove.add(entity);
  }

  /**
  * Remove all entities from the world at the end of the frame.
  */
  public function removeAll() {
    _entitiesToRemove.clear();
    var node = _entities.first;
    while (node != null) {
      _entitiesToRemove.add(node.value);
      node = node.next;
    }
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
    resolvePending();
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
    var node = _entities.first;
    while (node != null) {
      var entity = node.value;
      node = node.next;
      if (entity.isActive) {
        entity.update();
      }
    }
  }

  function resolvePending() {
    resolvePendingRemoves();
    resolvePendingAdds();
  }

  function resolvePendingAdds() {
    while (_entitiesToAdd.first != null) {
      var entity = _entitiesToAdd.shift();
      if (entity == null) {
        continue;
      } else if (entity.world == null) {
        _entities.add(entity);
        entity.world = this;
        addToNames(entity);
        for (tag in entity.getTags()) {
          addToTags(entity, tag);
        }
        entity.added();
      }
    }
  }

  function resolvePendingRemoves() {
    while (_entitiesToRemove.first != null) {
      var entity = _entitiesToRemove.shift();
      if (entity == null) {
        continue;
      } else if (entity.world == null) {
        _entitiesToAdd.remove(entity);
      } else if (entity.world == this) {
        entity.removed();
        for (tag in entity.getTags()) {
          removeFromTags(entity, tag);
        }
        removeFromNames(entity);
        entity.world = null;
        _entities.remove(entity);
      }
    }
  }

  function addToNames(entity:Entity) {
    var entities = _names.get(entity.name);
    if (entities == null) {
      entities = Entity.listPool.create();
      _names.set(entity.name, entities);
    }
    entities.add(entity);
  }

  function removeFromNames(entity:Entity) {
    var entities = _names.get(entity.name);
    if (entities != null) {
      entities.remove(entity);
      if (entities.first == null) {
        entities.free();
        _names.remove(entity.name);
      }
    }
  }

  function addToTags(entity:Entity, tag:String) {
    var entities = _tags.get(tag);
    if (entities == null) {
      entities = Entity.listPool.create();
      _tags.set(tag, entities);
    }
    entities.add(entity);
  }

  function removeFromTags(entity:Entity, tag:String) {
    var entities = _tags.get(tag);
    if (entities != null) {
      entities.remove(entity);
      if (entities.first == null) {
        entities.free();
        _tags.remove(tag);
      }
    }
  }
}
