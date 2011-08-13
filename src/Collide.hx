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
    delta = (aabb.entity.y + aabb.minY) - (circle.entity.y + circle.y);
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

  /**
  * Find the intersection of the AABB and the given segment, and update the
  * given sweep object. Returns true if an intersection occurs.
  */
  static inline public function intersectSegmentAABB(sweep:CollisionSweep, aabb:AABB, paddingX:Float=0, paddingY:Float=0):Bool {
    // A segment from point `A` to point `B` can be expressed with the equation
    // `S(t) = A + t * (B - A)`, for `0 <= t <= 1`. In this equation, `t` is
    // the time along the line, or percentage distance from `A` to `B`. This
    // code calculates the collision times along the line for each edge
    // of the box. This is sometimes called a slab test. Scaling is done using
    // multiplication instead of division to deal with floating point issues
    // (see [WilliamsEtAl05](http://www.cs.utah.edu/~awilliam/box/) for more).
    var hit:CollisionHit = null;
    var segment = sweep.segment;
    var nearTimeX = ((aabb.entity.x + aabb.x) - segment.signX * (aabb.halfWidth + paddingX) - segment.x1) * segment.scaleX;
    var nearTimeY = ((aabb.entity.y + aabb.y) - segment.signY * (aabb.halfHeight + paddingY) - segment.y1) * segment.scaleY;
    var farTimeX = ((aabb.entity.x + aabb.x) + segment.signX * (aabb.halfWidth + paddingX) - segment.x1) * segment.scaleX;
    var farTimeY = ((aabb.entity.y + aabb.y) + segment.signY * (aabb.halfHeight + paddingY) - segment.y1) * segment.scaleY;
    if (nearTimeX <= farTimeY && nearTimeY <= farTimeX) {
      // Find the farthest near value, and the nearest far value.
      var nearTime = Lo.max(nearTimeX, nearTimeY);
      var farTime = Lo.min(farTimeX, farTimeY);

      // If the nearest time is greater than one, then the nearest intersection
      // did not happen until after the end of the segment.  If both the times
      // are less than zero, then the box is behind the start of the segment.
      if (nearTime < 1 && (nearTime >= 0 || farTime >= 0)) {
        var time = if (nearTime >= 0) {
          // The segment starts outside and is entering the box.
          nearTime;
        } else {
          // The segment starts inside and is exiting the box.
          0;
        }

        // Only record the hit if it is nearer for the sweep.
        if (time < sweep.time) {
          sweep.time = time;
          hit = sweep.hit;
          if (hit == null) {
            hit = sweep.hit = CollisionHit.create();
          }
          if (nearTimeX > nearTimeY) {
            hit.normalX = -segment.signX;
            hit.normalY = 0;
          } else {
            hit.normalX = 0;
            hit.normalY = -segment.signY;
          }
          hit.deltaX = time * segment.deltaX;
          hit.deltaY = time * segment.deltaY;
          hit.x = segment.x1 + hit.deltaX;
          hit.y = segment.y1 + hit.deltaY;
          hit.bounds = aabb;
          hit.entity = aabb.entity;
        }
      }
    }
    return hit != null;
  }

  /**
  * Find the intersection of the Circle and the given segment, and update the
  * given sweep object. Returns true if an intersection occurs.
  *
  * This comes from Box2D's circle ray intersection code. It's very similar
  * to the test described in Real-Time Collision Detection (5.5.5), but does
  * not require delta to be unit length.
  */
  static inline public function intersectSegmentCircle(sweep:CollisionSweep, circle:Circle, padding:Float):Bool {
    var hit:CollisionHit = null;
    var segment = sweep.segment;
    var mx = segment.x1 - (circle.entity.x + circle.x);
    var my = segment.y1 - (circle.entity.y + circle.y);
    var r = circle.radius + padding;
    var b = (mx * mx + my * my) - (r * r);
    var rx = segment.deltaX;
    var ry = segment.deltaY;
    var c = mx * rx + my * ry;
    var rr = rx * rx + ry * ry;
    var sigma = c * c - rr * b;
    if (sigma >= 0 && rr >= Lo.EPSILON) {
      var time = -(c + Math.sqrt(sigma));
      if (time <= rr) {
        time = Lo.clamp(time / rr, 0, 1);
        if (time < sweep.time) {
          sweep.time = time;
          hit = sweep.hit;
          if (hit == null) {
            hit = sweep.hit = CollisionHit.create();
          }
          hit.normalX = mx + time * rx;
          hit.normalY = my + time * ry;
          hit.normalize();
          hit.x = segment.x1 + time * segment.deltaX;
          hit.y = segment.y1 + time * segment.deltaY;
          hit.bounds = circle;
          hit.entity = circle.entity;
        }
      }
    }
    return hit != null;
  }
}
