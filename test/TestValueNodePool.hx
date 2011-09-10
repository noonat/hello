package;

class TestValueNodePool extends haxe.unit.TestCase {
   public function testNew() {
      var pool = new ValueNodePool<Dummy>();
      assertEquals(pool._first, null);
   }

   public function testCreateAndFree() {
      var dummy1 = new Dummy();
      var dummy2 = new Dummy();
      var pool = new ValueNodePool<Dummy>();

      var node1 = pool.create(dummy1);
      assertTrue(node1 != null);
      assertEquals(node1.list, null);
      assertEquals(node1.next, null);
      assertEquals(node1.prev, null);
      assertEquals(node1.value, dummy1);
      assertEquals(node1._pool, pool);

      var node2 = pool.create(dummy2);
      assertTrue(node2 != null);
      assertTrue(node1 != node2);
      assertEquals(node2.list, null);
      assertEquals(node2.next, null);
      assertEquals(node2.prev, null);
      assertEquals(node2.value, dummy2);
      assertEquals(node2._pool, pool);

      assertEquals(pool._first, null);
      node1.free();
      assertEquals(pool._first, node1);
      var node3 = pool.create(dummy1);
      assertTrue(node3 == node1);
      assertEquals(pool._first, null);

      node3.free();
      assertEquals(pool._first, node3);
      node2.free();
      assertEquals(pool._first, node2);

      var node4 = pool.create(dummy1);
      assertEquals(node4, node2);
      assertEquals(node4.next, null);
      assertEquals(node4.value, dummy1);
      assertEquals(node4._pool, pool);
      assertEquals(pool._first, node3);

      var node5 = pool.create(dummy2);
      assertEquals(node5, node3);
      assertEquals(node5.next, null);
      assertEquals(node5.value, dummy2);
      assertEquals(node5._pool, pool);
      assertEquals(pool._first, null);
   }
}
