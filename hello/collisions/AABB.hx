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
      this.x = x == null ? halfWidth : x;
      this.y = y == null ? halfHeight : y;
   }

   inline public function setMinMax(minX:Float, minY:Float, maxX:Float, maxY:Float) {
      _width = maxX - minX;
      _height = maxY - minY;
      _halfWidth = _width * 0.5;
      _halfHeight = _height * 0.5;
      this.x = minX + _halfWidth;
      this.y = minY + _halfHeight;
   }
}
