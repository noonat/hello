package;

class TestValueListPool extends haxe.unit.TestCase {
   public function testNew() {
      var pool = new ValueListPool<Dummy>();
      assertEquals(pool._first, null);
   }

   public function testCreateAndFree() {
      var nodePool = new ValueNodePool<Dummy>();
      var pool = new ValueListPool<Dummy>();

      var list1 = pool.create();
      assertTrue(list1 != null);
      assertEquals(list1.first, null);
      assertEquals(list1._next, null);
      assertEquals(list1._pool, pool);
      assertEquals(list1._nodePool, null);

      var list2 = pool.create();
      assertTrue(list2 != null);
      assertEquals(list2.first, null);
      assertEquals(list2._next, null);
      assertEquals(list2._pool, pool);
      assertEquals(list2._nodePool, null);

      // should put a list back on the pool when freed
      assertEquals(pool._first, null);
      list1.free();
      assertEquals(pool._first, list1);

      // should re-used pooled lists
      var list3 = pool.create();
      assertEquals(list3, list1);
      assertEquals(pool._first, null);

      // should allow more than one list to be pooled
      list3.free();
      assertEquals(pool._first, list3);
      list2.free();
      assertEquals(pool._first, list2);

      // should re-use more than one list from the pool
      assertEquals(pool._first, list2);
      var list4 = pool.create();
      assertEquals(list4, list2);
      assertEquals(list4._next, null);
      assertEquals(list4._pool, pool);
      assertEquals(pool._first, list3);
      var list5 = pool.create();
      assertEquals(list5, list3);
      assertEquals(list5._next, null);
      assertEquals(list5._pool, pool);
      assertEquals(pool._first, null);
   }
}
