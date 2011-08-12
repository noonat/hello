class Collide {
  static inline public function testAABBAABB(aabb1:AABB, aabb2:AABB):Bool {
    return (
      aabb1.entity.x + aabb1.maxX > aabb2.entity.x + aabb2.minX &&
      aabb1.entity.y + aabb1.maxY > aabb2.entity.y + aabb2.minY &&
      aabb1.entity.x + aabb1.minX < aabb2.entity.x + aabb2.maxX &&
      aabb1.entity.y + aabb1.minY < aabb2.entity.y + aabb2.maxY);
  }

  static inline public function testAABBCircle(aabb:AABB, circle:Circle):Bool {
    var deltaSquared = 0.0;
    var delta = (aabb.entity.x + aabb.minX) - (circle.entity.x + circle.x);
    if (delta > 0) {
      deltaSquared += delta * delta;
    }
    delta = (circle.entity.x + circle.x) - (aabb.entity.x + aabb.maxX);
    if (delta > 0) {
      deltaSquared += delta * delta;
    }
    delta = (aabb.entity.x + aabb.minY) - (circle.entity.x + circle.y);
    if (delta > 0) {
      deltaSquared += delta * delta;
    }
    delta = (circle.entity.y + circle.y) - (aabb.entity.y + aabb.maxY);
    if (delta > 0) {
      deltaSquared += delta * delta;
    }
    return deltaSquared <= circle.radiusSquared;
  }

  static inline public function testCircleCircle(circle1:Circle, circle2:Circle):Bool {
    var dx = (circle2.entity.x + circle2.x) - (circle1.entity.x + circle1.x);
    var dy = (circle2.entity.y + circle2.y) - (circle1.entity.y + circle1.y);
    var radius = circle1.radius + circle2.radius;
    return dx * dx + dy * dy < radius * radius;
  }
}
