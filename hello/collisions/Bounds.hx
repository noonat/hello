package hello.collisions;

/**
* Base class for all bounding volumes. This class cannot be instantiated
* directly. Instead, use the appropriate subclass, such as AABB or Circle.
*
* entity, x, and y are the only properties that can be set directly
* the Bounds class. All others must be modified through the subclass.
*
* Classes that inherit from `Bounds` are responsible for setting _width,
* _height, _halfWidth, and _halfHeight so that the common Bounds accessors
* work correctly.
*/
class Bounds {
   public var type(getType, never):BoundsType;
   var _type:BoundsType;

   // Subclass properties. These provide a way to get access to the typed
   // volume (so HaXe can properly inline things). If the subclass doesn't
   // inherit from the type, the property will be null.
   public var aabb(getAABB, never):AABB;
   public var circle(getCircle, never):Circle;
   public var grid(getGrid, never):Grid;
   var _aabb:AABB;
   var _circle:Circle;
   var _grid:Grid;

   // Common bounding volume properties
   public var entity(getEntity, setEntity):Entity;
   public var halfWidth(getHalfWidth, never):Float;
   public var halfHeight(getHalfHeight, never):Float;
   public var width(getWidth, never):Float;
   public var height(getHeight, never):Float;
   public var minX(getMinX, never):Float;
   public var minY(getMinY, never):Float;
   public var maxX(getMaxX, never):Float;
   public var maxY(getMaxY, never):Float;
   public var x(getX, setX):Float;
   public var y(getY, setY):Float;
   var _class:String;
   var _entity:Entity;
   var _halfWidth:Float;
   var _halfHeight:Float;
   var _width:Float;
   var _height:Float;
   var _x:Float;
   var _y:Float;

   function new(type:BoundsType) {
      _type = type;
      _halfWidth = 0;
      _halfHeight =0 ;
      _width = 0;
      _height = 0;
      _x = 0;
      _y = 0;
      _class = Type.getClassName(Type.getClass(this));
   }

   inline public function collide(other:Bounds):Bool {
      return switch (_type) {
         case BoundsType.AABB:
            switch (other.type) {
               case BoundsType.AABB:
                  Collision.testAABBAABB(_aabb, other._aabb);
               case BoundsType.CIRCLE:
                  Collision.testAABBCircle(_aabb, other._circle);
               case BoundsType.GRID:
                  Collision.testAABBGrid(_aabb, other._grid);
               default:
                  false;
            }

         case BoundsType.CIRCLE:
            switch (other.type) {
               case BoundsType.AABB:
                  Collision.testAABBCircle(other._aabb, _circle);
               case BoundsType.CIRCLE:
                  Collision.testCircleCircle(_circle, other._circle);
               default:
                  false;
            }

         default:
            false;
      }
   }

   inline public function intersectSegment(sweep:CollisionSweep):Bool {
      return switch (_type) {
         case BoundsType.AABB:
            Collision.intersectSegmentAABB(sweep, _aabb, 0, 0);
         case BoundsType.CIRCLE:
            Collision.intersectSegmentCircle(sweep, _circle, 0);
         case BoundsType.GRID:
            Collision.intersectSegmentGrid(sweep, _grid);
         default:
            false;
      }
   }

   inline public function sweep(sweep:CollisionSweep, into:Bounds):Bool {
      return switch (_type) {
         case BoundsType.AABB:
            switch (into._type) {
               case BoundsType.AABB:
                  Collision.sweepAABBAABB(sweep, _aabb, into._aabb);
               case BoundsType.CIRCLE:
                  Collision.sweepAABBCircle(sweep, _aabb, into._circle);
               case BoundsType.GRID:
                  Collision.sweepAABBGrid(sweep, _aabb, into._grid);
               default:
                  false;
            }

         case BoundsType.CIRCLE:
            switch (into._type) {
               case BoundsType.AABB:
                  Collision.sweepCircleAABB(sweep, _circle, into._aabb);
               case BoundsType.CIRCLE:
                  Collision.sweepCircleCircle(sweep, _circle, into._circle);
               case BoundsType.GRID:
                  Collision.sweepCircleGrid(sweep, _circle, into._grid);
               default:
                  false;
            }

         default:
            false;
      }
   }

   inline function synchronize() {
      if (_entity != null) {
         _entity.synchronize();
      }
   }

   inline function getType():BoundsType {
      return _type;
   }

   inline function getAABB():AABB {
      return _aabb;
   }

   inline function getCircle():Circle {
      return _circle;
   }

   inline function getGrid():Grid {
      return _grid;
   }

   inline function getEntity():Entity {
      return _entity;
   }

   inline function setEntity(value:Entity):Entity {
      if (_entity != value) {
         _entity = value;
         synchronize();
      }
      return value;
   }

   inline function getHalfWidth():Float {
      return _halfWidth;
   }

   inline function getHalfHeight():Float {
      return _halfHeight;
   }

   inline function getWidth():Float {
      return _width;
   }

   inline function getHeight():Float {
      return _height;
   }

   inline function getMinX():Float {
      return _x - _halfWidth;
   }

   inline function getMinY():Float {
      return _y - _halfHeight;
   }

   inline function getMaxX():Float {
      return _x + _halfWidth;
   }

   inline function getMaxY():Float {
      return _y + _halfHeight;
   }

   inline function getX():Float {
      return _x;
   }

   inline function setX(value:Float):Float {
      if (_x != value) {
         _x = value;
         synchronize();
      }
      return value;
   }

   inline function getY():Float {
      return _y;
   }

   inline function setY(value:Float):Float {
      if (_y != value) {
         _y = value;
         synchronize();
      }
      return value;
   }
}
