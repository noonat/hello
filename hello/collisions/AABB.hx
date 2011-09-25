package hello.collisions;

class AABB extends Bounds {
   public function new(halfWidth:Float, halfHeight:Float, ?x:Float, ?y:Float) {
      super(BoundsType.AABB);
      _aabb = this;
      set(halfWidth, halfHeight, x, y);
   }

   inline public function set(halfWidth:Float, halfHeight:Float, ?x:Float, ?y:Float) {
      _halfWidth = halfWidth;
      _halfHeight = halfHeight;
      _width = _halfWidth * 2;
      _height = _halfHeight * 2;
      _x = x == null ? halfWidth : x;
      _y = y == null ? halfHeight : y;
      synchronize();
   }

   inline public function setMinMax(minX:Float, minY:Float, maxX:Float, maxY:Float) {
      _width = maxX - minX;
      _height = maxY - minY;
      _halfWidth = _width * 0.5;
      _halfHeight = _height * 0.5;
      _x = minX + _halfWidth;
      _y = minY + _halfHeight;
      synchronize();
   }

   inline public function setWidth(value:Float) {
      _width = value;
      _halfWidth = value * 0.5;
      synchronize();
   }

   inline public function setHeight(value:Float) {
      _height = value;
      _halfHeight = value * 0.5;
      synchronize();
   }
}
