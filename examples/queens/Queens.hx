package examples.queens;

import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.xml.Fast;
import hello.collisions.AABB;
import hello.Assets;
import hello.Engine;
import hello.Entity;
import hello.graphics.Graphic;
import hello.graphics.Image;
import hello.graphics.Spritemap;
import hello.graphics.Texture;
import hello.graphics.TextureAtlas;
import hello.Key;
import hello.Lo;
import hello.Renderer;
import hello.World;
import Type;
using hello.Mixins;

class Queens extends Engine {
   static public var atlas:TextureAtlas;

   static public function main() {
      Lo.main(320, 240, 60, Queens, []);
   }

   public function new() {
      super();
      Lo.renderer.backgroundColor = 0x0f110b;
      Lo.renderer.scale = 2;
      atlas = new TextureAtlas('atlas_queens');
      atlas.setTexturesFromPropertyList('atlas_queens_plist');
      world = new Game();
   }

   static public function computeVelocity(velocity:Float, acceleration:Float=0, drag:Float=0, max:Float=10000):Float {
      if (acceleration != 0) {
         velocity += acceleration * Lo.elapsed;
      } else if (drag != 0) {
         var d = drag * Lo.elapsed;
         if (velocity > d) {
            velocity -= d;
         } else if (velocity < -d) {
            velocity += d;
         } else {
            velocity = 0;
         }
      }
      if (velocity != 0 && max != 10000) {
         velocity = Lo.clamp(velocity, -max, max);
      }
      return velocity;
   }
}

class Game extends World {
   static var _classes:Array<Dynamic> = [
      ArrowShooter,
      Bridge,
      Crusher,
      Gear,
      Platform,
      Rock,
      RoofSpike
   ];
   var _player:Player;

   public function new() {
      super();
      _player = new Player();
      add(_player);

      var xml = new haxe.xml.Fast(
         Xml.parse(Assets.getString('map')).firstElement());
      readBlocks(xml);
      readEntities(xml);
   }

   override public function update() {
      super.update();
      Lo.cameraX = _player.x - (Lo.width / 2);
      Lo.cameraY = _player.y - (Lo.width / 2);
   }

   function readBlocks(xml:Fast) {
      for (xmlBlock in xml.nodes.block) {
         var x = Std.parseFloat(xmlBlock.att.x);
         var y = Std.parseFloat(xmlBlock.att.y);
         var width = Std.parseFloat(xmlBlock.att.width);
         var height = Std.parseFloat(xmlBlock.att.height);
         var texture = if (xmlBlock.has.textureName) {
            Queens.atlas.getTexture(xmlBlock.att.textureName);
         } else {
            null;
         }
         var empty = if (xmlBlock.has.empty) {
            Std.parseInt(xmlBlock.att.empty);
         } else {
            0;
         }
         var block = new Entity();
         block.x = x;
         block.y = y;
         block.addTag('block');
         if (xmlBlock.has.tags) {
            for (tag in xmlBlock.att.tags.split(' ')) {
               if (tag != '') {
                  block.addTag(tag);
               }
            }
         }
         if (xmlBlock.has.isCollidable) {
            block.isCollidable = xmlBlock.att.isCollidable != 'false';
         }
         block.bounds = if (texture != null) {
            var blockGraphic = new BlockGraphic(0, 0, width, height, texture, empty);
            block.addGraphic(blockGraphic);
            new AABB(blockGraphic.width / 2, blockGraphic.height / 2);
         } else {
            new AABB(width / 2, height / 2);
         }
         add(block);
      }
   }

   function readEntities(xml:Fast) {
      // Add all the entities, but just with x, y, name and tags set
      var entities = new Array<Entity>();
      for (xmlEntity in xml.nodes.entity) {
         var className = xmlEntity.att.className;
         var cls:Class<Dynamic> = Type.resolveClass(className);
         if (cls == null) {
            flash.Lib.trace('WARNING: unknown entity class "' + className + '"');
            entities.push(null);
            continue;
         }
         var entity:Entity = Type.createInstance(cls, []);
         entity.x = Std.parseFloat(xmlEntity.att.x);
         entity.y = Std.parseFloat(xmlEntity.att.y);
         if (xmlEntity.has.name) {
            entity.name = xmlEntity.att.name;
         }
         if (xmlEntity.has.tags) {
            for (tag in xmlEntity.att.tags.split(' ')) {
               if (tag != '') {
                  entity.addTag(tag);
               }
            }
         }
         add(entity);
         entities.push(entity);
      }

      // Get all the entities into the world
      resolvePending();

      // Now iterate over the entities and set the rest of their properties.
      // This is done in two phases so entities can find other entities that
      // they might refer to (e.g. if it refers to another entity by name).
      var i = 0;
      for (xmlEntity in xml.nodes.entity) {
         var entity = entities[i++];
         if (entity == null) {
            continue;
         }
         var fields = Type.getInstanceFields(Type.getClass(entity));
         for (key in xmlEntity.x.attributes()) {
            if (key == 'className' || key == 'name' || key == 'tags' || key == 'x' || key == 'y') {
               continue;
            }
            var value:Dynamic = xmlEntity.x.get(key);
            if (fields.indexOf(key) == -1) {
               flash.Lib.trace('WARNING: unknown field "' + key + '" for entity "' + entity + '"');
               continue;
            }
            if (Type.typeof(Reflect.field(entity, key)) == ValueType.TBool) {
               value = value == 'true';
            }
            var setter = 'set' + key.charAt(0).toUpperCase() + key.substr(1);
            if (Reflect.hasField(entity, setter)) {
                Reflect.callMethod(entity, Reflect.field(entity, setter), [value]);
            } else {
                Reflect.setField(entity, key, value);
            }
         }
      }
   }
}

class ArrowShooter extends Entity {
   public var waitDuration:Float;

   public function new() {
      super();
   }
}

class Bridge extends Entity {
   public function new() {
      super();
   }
}

class Crusher extends Platform {
   public function new() {
      super();
      _image.texture = Queens.atlas.getTexture('crusher.png');
      _image.layer = 0;
   }
}

class Gear extends Entity {
   public var textureName(getTextureName, setTextureName):String;
   public var turnSpeed:Float;
   var _image:Image;

   public function new() {
      super();
      _image = new Image(Queens.atlas.getTexture('gear.png'));
      _image.layer = 0;
      addGraphic(_image);
   }

   inline function getTextureName():String {
      return _image.texture != null ? _image.texture.id : null;
   }

   inline function setTextureName(value:String):String {
      _image.texture = Queens.atlas.getTexture(value);
      return value;
   }
}

class Platform extends Entity {
   static inline var AXIS_X:Int = 0;
   static inline var AXIS_Y:Int = 1;
   public var axis:Int;
   public var dir:Float;
   public var min:Float;
   public var max:Float;
   public var speed:Float;
   public var waitDuration:Float;
   var _image:Image;

   public function new() {
      super();
      _image = new Image(Queens.atlas.getTexture('platform.png'));
      addGraphic(_image);
   }
}

class Rock extends Entity {
   var _image:Image;

   public function new() {
      super();
      _image = new Image(Queens.atlas.getTexture('rock.png'));
      addGraphic(_image);
   }
}

class RoofSpike extends Entity {
   public var isFast:Bool;
   public var shakeDuration:Float;
   public var triggerDistance:Float;
   var _image:Image;

   public function new() {
      super();
      _image = new Image(Queens.atlas.getTexture('roof_spike.png'));
      addGraphic(_image);
   }
}

class BlockGraphic extends Graphic {
   public var width(getWidth, never):Float;
   public var height(getHeight, never):Float;
   var _cols:Int;
   var _rows:Int;
   var _rects:Array<Rectangle>;
   var _texture:Texture;
   var _tileSize:Int;
   var _width:Int;
   var _height:Int;

   public function new(x:Float, y:Float, width:Float, height:Float, texture:Texture, empty:Int) {
      super();
      layer = 1;
      this.x = x;
      this.y = y;
      _texture = texture;
      _tileSize = Std.int(texture.rect.height);
      _cols = Lo.ceil(width / _tileSize);
      _rows = Lo.ceil(height / _tileSize);
      _width = _cols * _tileSize;
      _height = _rows * _tileSize;
      _rects = new Array<Rectangle>();
      y = 0;
      var numTiles = Std.int(texture.rect.width / _tileSize);
      while (y < _height) {
         x = 0;
         while (x < _width) {
            _rects.push(new Rectangle(
               _tileSize * Std.int(Math.random() * numTiles), 0, _tileSize, _tileSize));
            x += _tileSize;
         }
         y += _tileSize;
      }
   }

   override public function render(target:Renderer) {
      var px = x;
      var py = y;
      if (entity != null && isRelative) {
         px += entity.x;
         py += entity.y;
      }
      var row = 0;
      while (row < _rows) {
         var yy = py + (row * _tileSize);
         var col = 0;
         while (col < _cols) {
            var xx = px + (col * _tileSize);
            var rect = _rects[row * _cols + col];
            target.drawTextureRect(
               _texture, xx, yy, rect.x, rect.y, rect.width, rect.height);
            col++;
         }
         row++;
      }
   }

   inline function getWidth():Float {
      return _width;
   }

   inline function getHeight():Float {
      return _height;
   }
}

class Player extends Entity {
   static inline var _jumpVelocity:Float = 180;
   static inline var _runVelocity:Float = 70;
   var _acceleration:Point;
   var _anim:String;
   var _dir:String;
   var _drag:Point;
   var _jumped:Bool;
   var _maxVelocity:Point;
   var _spritemap:Spritemap;
   var _texture:Texture;
   var _velocity:Point;

   public function new() {
      super(64, 128, new AABB(3, 7, 8, 9));

      _acceleration = new Point(0, 420);
      _maxVelocity = new Point(_runVelocity, _jumpVelocity * 2);
      _drag = new Point(_maxVelocity.x * 8, 0);
      _velocity = new Point(0, 0);
      _jumped = false;

      _anim = 'idle';
      _dir = 'right';
      _spritemap = new Spritemap(_texture = Queens.atlas.getTexture('queen.png'), 16, 16);
      _spritemap.add('idle_left', [1], 0, false, true);
      _spritemap.add('idle_right', [1]);
      _spritemap.add('run_left', [1, 2, 3, 0], 10, true, true);
      _spritemap.add('run_right', [1, 2, 3, 0], 10);
      _spritemap.add('jump_left', [2], 0, false, true);
      _spritemap.add('jump_right', [2], 0);
      _spritemap.add('stand', [4, 5, 6], 2, false);
      _spritemap.add('dead_left', [4], 1, false, true);
      _spritemap.add('dead_right', [4], 1, false);
      _spritemap.layer = 2;
      addGraphic(_spritemap);
   }

   override public function update() {
      super.update();

      _acceleration.x = 0;
      if (Lo.keyDown(Key.LEFT)) {
         _acceleration.x -= _drag.x;
      }
      if (Lo.keyDown(Key.RIGHT)) {
         _acceleration.x += _drag.x;
      }
      if (Lo.keyPressed(Key.X) && !_jumped && _velocity.y < 30) {
         _jumped = true;
         _velocity.y = -_jumpVelocity;
      }

      _anim = if (_velocity.y != 0) {
         'jump';
      } else if (_velocity.x != 0) {
         'run';
      } else {
         'idle';
      }
      if (_anim != 'idle') {
         _dir = _velocity.x < 0 ? 'left' : 'right';
      }
      _spritemap.play(_anim + '_' + _dir);

      _velocity.x = Queens.computeVelocity(_velocity.x, _acceleration.x, _drag.x, _maxVelocity.x);
      _velocity.y = Queens.computeVelocity(_velocity.y, _acceleration.y, _drag.y, _maxVelocity.y);
      if (_velocity.x != 0) {
         moveBy(_velocity.x * Lo.elapsed, 0);
         if (sweep != null && sweep.hit != null) {
            _velocity.x = 0;
         }
      }
      if (_velocity.y != 0) {
         moveBy(0, _velocity.y * Lo.elapsed);
         if (sweep != null && sweep.hit != null) {
            if (_velocity.y > 0) {
               _jumped = false;
            }
            _velocity.y = 0;
         }
      }
   }
}
