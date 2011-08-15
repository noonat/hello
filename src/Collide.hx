class Collide {
  static var _tmpEntity:Entity;
  static var _tmpAABB:AABB;

  static function __init__() {
    _tmpEntity = new Entity();
    _tmpAABB = new AABB(0, 0);
    _tmpAABB.entity = _tmpEntity;
  }

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
  * Intersect aabb `a` into aabb `b`. Returns a CollisionHit object, where
  * `hit.deltaX` and `hit.deltaY` describe a vector to move `a` out of
  * collision. Returns null if no intersection occurs.
  *
  * This uses a separating axis test, and gives the axis of least overlap as
  * the contact point. This can cause weird behavior for moving boxes, so you
  * should use `sweepAABBAABB` for a moving box.
  */
  static inline public function intersectAABBAABB(a:AABB, b:AABB):CollisionHit {
    var hit:CollisionHit = null;
    // Find the overlap for the X axis.
    var dx = (a.entity.x + a.x) - (b.entity.x + b.x);
    var px = (a.halfWidth + b.halfWidth) - Lo.abs(dx);
    if (px > 0) {
      // Find the overlap for the Y axis
      var dy = (a.entity.y + a.y) - (b.entity.y + b.y);
      var py = (a.halfHeight + b.halfHeight) - Lo.abs(dy);
      if (py > 0) {
        // Use the axis with the smallest overlap
        hit = CollisionHit.create();
        if (px < py) {
          var sign = Lo.sign(dx);
          hit.deltaX = px * sign;
          hit.normalX = sign;
          hit.x = b.entity.x + b.x + (b.halfWidth * sign);
          hit.y = a.entity.y + a.y;
        } else {
          var sign = Lo.sign(dy);
          hit.deltaY = py * sign;
          hit.normalY = sign;
          hit.x = a.entity.x + a.x;
          hit.y = b.entity.y + b.y + (b.halfHeight * sign);
        }
      }
    }
    return hit;
  }

  /**
  * Intersect the point `x`, `y` into `aabb`. Returns a CollisionHit object
  * if they intersect, with `hit.x` and `hit.y` set to the nearest edge of
  * the box. Returns null if no intersection occurs.
  */
  static inline public function intersectPointAABB(x:Float, y:Float, aabb:AABB):CollisionHit {
    _tmpEntity.x = x;
    _tmpEntity.y = y;
    _tmpAABB.entity = _tmpEntity;
    _tmpAABB.set(0, 0, 0, 0);
    return intersectAABBAABB(_tmpAABB, aabb);
  }

  /**
  * Intersect the segment described by `sweep` into `aabb`. Returns true if
  * an intersection occurs, and updates `sweep` with the details.
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
          hit.bounds = aabb;
          hit.entity = aabb.entity;
          hit.deltaX = time * segment.deltaX;
          hit.deltaY = time * segment.deltaY;
          sweep.time = time;
          sweep.x = hit.x = segment.x1 + hit.deltaX;
          sweep.y = hit.y = segment.y1 + hit.deltaY;
        }
      }
    }
    return hit != null;
  }

  /**
  * Intersect circle `a` into circle `b`. Returns a CollisionHit if they
  * intersect, where `hit.deltaX` and `hit.deltaY` describe a the vector to
  * move `a` out of collision. Returns null if they do not intersect.
  */
  static inline public function intersectCircleCircle(a:Circle, b:Circle):CollisionHit {
    var hit:CollisionHit = null;
    var dx = (a.entity.x + a.x) - (b.entity.x + b.x);
    var dy = (a.entity.y + a.y) - (b.entity.y + b.y);
    var distanceSquared = dx * dx + dy * dy;
    var radiusSum = a.radius + b.radius;
    if (distanceSquared <= radiusSum * radiusSum) {
      hit = CollisionHit.create();
      var distance:Float;
      if (distanceSquared > 0) {
        distance = Math.sqrt(distanceSquared);
        hit.normalX = dx / distance;
        hit.normalY = dy / distance;
      } else {
        // It's right in the middle, just push it out to the right
        distance = 0;
        hit.normalX = 1;
        hit.normalY = 0;
      }
      hit.deltaX = (radiusSum - distance) * hit.normalX;
      hit.deltaY = (radiusSum - distance) * hit.normalY;
      hit.x = (b.entity.x + b.x + b.radius) * hit.normalX;
      hit.y = (b.entity.y + b.y + b.radius) * hit.normalY;
    }
    return hit;
  }

  /**
  * Intersect the segment described by `sweep` into `circle`. Returns true if
  * an intersection occurs, and updates `sweep` with the details.
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
          hit = sweep.hit;
          if (hit == null) {
            hit = sweep.hit = CollisionHit.create();
          }
          hit.bounds = circle;
          hit.entity = circle.entity;
          hit.normalX = mx + time * rx;
          hit.normalY = my + time * ry;
          hit.normalize();
          sweep.time = time;
          sweep.x = hit.x = segment.x1 + time * segment.deltaX;
          sweep.y = hit.y = segment.y1 + time * segment.deltaY;
        }
      }
    }
    return hit != null;
  }

  /**
  * Intersect `movingAABB` into `staticAABB` along the movement path described
  * by `sweep`. Returns true if an intersection occurs, and updates `sweep`.
  *
  * This test is done by inflating this box to include the size of the moving
  * box, then colliding the movement as a segment against the inflated box.
  */
  static inline public function sweepAABBAABB(sweep:CollisionSweep, movingAABB:AABB, staticAABB:AABB):Bool {
    var intersected:Bool = false;
    if (sweep.segment.deltaX == 0 && sweep.segment.deltaY == 0) {
      // If the sweep isn't actually moving anywhere, just do a static test
      var hit:CollisionHit = intersectAABBAABB(movingAABB, staticAABB);
      intersected = hit != null;
      if (intersected) {
        sweep.time = 0;
        if (sweep.hit == null) {
          sweep.hit = hit;
          sweep.x = sweep.segment.x1;
          sweep.y = sweep.segment.y1;
        } else {
          sweep.hit.copy(hit);
          hit.free();
        }
      }
    } else {
      intersected = intersectSegmentAABB(
        sweep, staticAABB, movingAABB.halfWidth, movingAABB.halfHeight);
      if (intersected) {
        // FIXME: Is this right? Or should be along delta vector at time - half?
        sweep.x -= sweep.hit.normalX * movingAABB.halfWidth;
        sweep.y -= sweep.hit.normalY * movingAABB.halfHeight;
      }
    }
    return intersected;
  }
}
