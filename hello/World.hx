package hello;

import hello.collisions.Space;
import hello.graphics.Graphic;
using hello.Mixins;

class World extends Space {
  public var isActive:Bool;
  public var isVisible:Bool;
  var _entities:ValueList<Entity>;
  var _entitiesToAdd:ValueList<Entity>;
  var _entitiesToRemove:ValueList<Entity>;
  var _layers:IntHash<ValueList<Graphic>>;
  var _layersKeys:Array<Int>;
  var _layersNeedSort:Bool;
  var _names:Hash<ValueList<Entity>>;
  var _tags:Hash<ValueList<Entity>>;

  public function new(cellSize:Int=32) {
    super(cellSize);
    isActive = true;
    isVisible = true;
    _entities = Entity.listPool.create();
    _entitiesToAdd = Entity.listPool.create();
    _entitiesToRemove = Entity.listPool.create();
    _layers = new IntHash<ValueList<Graphic>>();
    _layersKeys = new Array<Int>();
    _layersNeedSort = false;
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
  * Return the first entity with the given name, or null.
  */
  inline public function getNamed(name:String):Entity {
    if (_names.exists(name)) {
      var node = _names.get(name).first;
      return node != null ? node.value : null;
    } else {
      return null;
    }
  }

  /**
  * Return a list of entities with the given tag.
  */
  inline public function getTagged(tag:String):ValueList<Entity> {
    var list = Entity.listPool.create();
    if (_tags.exists(tag)) {
      var node = _tags.get(tag).first;
      while (node != null) {
        list.add(node.value);
        node = node.next;
      }
    }
    return list;
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
    var node = _entities.first;
    while (node != null) {
      var entity = node.value;
      node = node.next;
      if (entity.isVisible) {
        entity.preRender();
      }
    }
    var i = _layersKeys.length;
    while (i-- > 0) {
      var layer = _layersKeys[i];
      var graphics = _layers.get(layer);
      if (graphics == null) {
        continue;
      }
      var node = graphics.first;
      while (node != null) {
        var graphic = node.value;
        node = node.next;
        if (graphic.isVisible && graphic.entity.isVisible) {
          graphic.render();
        }
      }
    }
  }

  /**
  * Update all the active entities in the world.
  */
  public function update() {
    var node = _entities.first;
    while (node != null) {
      var entity = node.value;
      node = node.next;
      entity.previousX = entity.x;
      entity.previousY = entity.y;
      if (entity.isActive) {
        entity.update();
        if (!entity.isSynchronized) {
          updateEntityCells(entity);
        }
      }
    }
  }

  function resolvePending() {
    resolvePendingRemoves();
    resolvePendingAdds();
    if (_layersNeedSort) {
      _layersNeedSort = false;
      _layersKeys.sort(sortLayersCallback);
    }
  }

  function sortLayersCallback(a:Int, b:Int):Int {
    return a - b;
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
        var components = getEntityFriend(entity)._components;
        if (components != null) {
          for (component in components) {
            component.addedToWorld();
          }
        }
        var node = entity.graphics.first;
        while (node != null) {
          var graphic = node.value;
          node = node.next;
          if (graphic != null) {
            addToLayers(graphic);
          }
        }
        updateEntityCells(entity);
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
        var cells = entity.cells;
        while (cells.first != null) {
          var cell = cells.shift();
          cell.entities.remove(entity);
        }
        var components = getEntityFriend(entity)._components;
        if (components != null) {
          for (component in components) {
            component.removedFromWorld();
          }
        }
        var node = entity.graphics.first;
        while (node != null) {
          var graphic = node.value;
          node = node.next;
          if (graphic != null) {
            removeFromLayers(graphic);
          }
        }
        for (tag in entity.getTags()) {
          removeFromTags(entity, tag);
        }
        removeFromNames(entity);
        entity.world = null;
        _entities.remove(entity);
      }
    }
  }

  function addToLayers(graphic:Graphic) {
    var graphics = _layers.get(graphic.layer);
    if (graphics == null) {
      graphics = Graphic.listPool.create();
      _layers.set(graphic.layer, graphics);
      _layersKeys.push(graphic.layer);
      _layersNeedSort = true;
    }
    graphics.add(graphic);
  }

  function removeFromLayers(graphic:Graphic) {
    var graphics = _layers.get(graphic.layer);
    if (graphics != null) {
      graphics.remove(graphic);
      if (graphics.first == null) {
        graphics.free();
        _layers.remove(graphic.layer);
        var i = _layersKeys.indexOf(graphic.layer);
        if (i != -1) {
          _layersKeys.splice(i, 1);
        }
        _layersNeedSort = true;
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
