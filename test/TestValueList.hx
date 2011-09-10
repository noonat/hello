package;

class TestValueList extends haxe.unit.TestCase {
   public function testNew() {
      var nodePool = new ValueNodePool<Dummy>();
      var pool = new ValueListPool<Dummy>(nodePool);

      var list = new ValueList<Dummy>();
      assertEquals(list.first, null);
      assertEquals(list._next, null);
      assertEquals(list._pool, null);
      assertEquals(list._nodePool, null);

      list = new ValueList<Dummy>(null, pool);
      assertEquals(list.first, null);
      assertEquals(list._next, null);
      assertEquals(list._pool, pool);
      assertEquals(list._nodePool, null);

      list = new ValueList<Dummy>(nodePool, pool);
      assertEquals(list.first, null);
      assertEquals(list._next, null);
      assertEquals(list._pool, pool);
      assertEquals(list._nodePool, nodePool);
   }

   public function testAdd() {
      var dummy1 = new Dummy();
      var dummy2 = new Dummy();

      var list = new ValueList<Dummy>(null, null);

      var node1 = list.add(dummy1);
      assertEquals(list.first, node1);
      assertEquals(node1.list, list);
      assertEquals(node1.next, null);
      assertEquals(node1.prev, null);
      assertEquals(node1.value, dummy1);

      var node2 = list.add(dummy2);
      assertEquals(list.first, node2);
      assertEquals(node2.list, list);
      assertEquals(node2.next, node1);
      assertEquals(node2.prev, null);
      assertEquals(node2.value, dummy2);
      assertEquals(node1.next, null);
      assertEquals(node1.prev, node2);

      node1.free();
      node2.free();
      var nodePool = new ValueNodePool<Dummy>();
      nodePool.put(node2);
      nodePool.put(node1);

      var list = new ValueList<Dummy>(nodePool, null);
      var node3 = list.add(dummy1);
      var node4 = list.add(dummy2);
      assertEquals(node3, node1);
      assertEquals(node4, node2);
   }

   public function testClear() {
      var list = new ValueList<Dummy>();
      var node1 = list.add(new Dummy());
      var node2 = list.add(new Dummy());
      assertEquals(list.first, node2);
      assertEquals(node2.list, list);
      assertEquals(node2.next, node1);
      assertEquals(node2.prev, null);
      assertEquals(node1.list, list);
      assertEquals(node1.next, null);
      assertEquals(node1.prev, node2);

      list.clear();
      assertEquals(list.first, null);
      assertEquals(node2.list, null);
      assertEquals(node2.next, null);
      assertEquals(node2.prev, null);
      assertEquals(node1.list, null);
      assertEquals(node1.next, null);
      assertEquals(node1.prev, null);
   }

   public function testFree() {
      var list = new ValueList<Dummy>();
      list.add(new Dummy());
      list.add(new Dummy());
      list.free();
      assertEquals(list.first, null);
      assertEquals(list._next, null);

      var pool = new ValueListPool<Dummy>(null);
      list = new ValueList<Dummy>(null, pool);
      list.add(new Dummy());
      list.add(new Dummy());
      list.free();
      assertEquals(list.first, null);
      assertEquals(list._next, null);
      assertEquals(pool._first, list);
   }

   public function testHas() {
      var dummy1 = new Dummy();
      var dummy2 = new Dummy();

      // should be false for values not in the list
      var list = new ValueList<Dummy>();
      assertFalse(list.has(dummy1));
      assertFalse(list.has(dummy2));

      // adding one should not affect the other
      list.add(dummy1);
      assertTrue(list.has(dummy1));
      assertFalse(list.has(dummy2));

      // should be true after values are added to the list
      list.add(dummy2);
      assertTrue(list.has(dummy1));
      assertTrue(list.has(dummy2));

      // removing one should not affect the other
      list.remove(dummy1);
      assertFalse(list.has(dummy1));
      assertTrue(list.has(dummy2));

      // should be false after values are removed
      list.remove(dummy2);
      assertFalse(list.has(dummy1));
      assertFalse(list.has(dummy2));

      // should allow a value to be added more than once
      var node1 = list.add(dummy1);
      var node2 = list.add(dummy1);
      var node3 = list.add(dummy2);
      assertTrue(node1 != node2);
      assertEquals(node1.list, list);
      assertEquals(node1.value, dummy1);
      assertEquals(node2.list, list);
      assertEquals(node2.value, dummy1);
      assertEquals(node3.list, list);
      assertEquals(node3.next, node2);
      assertEquals(node3.value, dummy2);
   }

   public function testRemove() {
      var dummy1 = new Dummy();
      var dummy2 = new Dummy();
      var dummy3 = new Dummy();
      var list = new ValueList<Dummy>();
      var node1 = list.add(dummy1);
      var node2 = list.add(dummy1);
      var node3 = list.add(dummy2);

      // should remove all instances of a value from the list
      list.remove(dummy1);
      assertEquals(list.first, node3);
      assertEquals(node1.list, null);
      assertEquals(node2.list, null);
      assertEquals(node3.list, list);
      assertEquals(node3.next, null);

      // should safely ignore a value not in the list
      list.remove(dummy3);
      assertEquals(list.first, node3);
      assertEquals(node3.list, list);

      // should remove the last value in the list
      list.remove(dummy2);
      assertEquals(list.first, null);
      assertEquals(node3.list, null);
   }

   public function testShift() {
      var dummy1 = new Dummy();
      var dummy2 = new Dummy();
      var dummy3 = new Dummy();
      var list = new ValueList<Dummy>();
      var node1 = list.add(dummy1);
      var node2 = list.add(dummy2);
      var node3 = list.add(dummy3);

      // should remove each node from the front of the list
      assertEquals(list.shift(), dummy3);
      assertEquals(list.first, node2);
      assertEquals(node3.list, null);
      assertEquals(node2.list, list);
      assertEquals(node1.list, list);

      assertEquals(list.shift(), dummy2);
      assertEquals(list.first, node1);
      assertEquals(node2.list, null);
      assertEquals(node1.list, list);

      assertEquals(list.shift(), dummy1);
      assertEquals(list.first, null);
      assertEquals(node1.list, null);

      // should return null if the list is empty
      assertEquals(list.shift(), null);
   }

   public function testUnlink() {
      var dummy1 = new Dummy();
      var dummy2 = new Dummy();
      var dummy3 = new Dummy();
      var list = new ValueList<Dummy>();
      var node1 = list.add(dummy1);
      var node2 = list.add(dummy1);
      var node3 = list.add(dummy2);

      // should remove the node but not free it
      assertEquals(node2.list, list);
      assertEquals(node2.next, node1);
      assertEquals(node2.prev, node3);
      list.unlink(node2);
      assertEquals(node2.list, null);
      assertEquals(node2.next, null);
      assertEquals(node2.prev, null);
      assertEquals(node2.value, dummy1);

      // removing node should not unlink other nodes
      assertEquals(node1.list, list);
      assertEquals(node1.next, null);
      assertEquals(node1.prev, node3);
      assertEquals(node3.list, list);
      assertEquals(node3.next, node1);
      assertEquals(node3.prev, null);

      // removing the first node should update list.first
      assertEquals(list.first, node3);
      list.unlink(node3);
      assertEquals(node3.list, null);
      assertEquals(node3.next, null);
      assertEquals(node3.prev, null);
      assertEquals(list.first, node1);
      assertEquals(node1.list, list);
      assertEquals(node1.next, null);
      assertEquals(node1.prev, null);
   }
}
