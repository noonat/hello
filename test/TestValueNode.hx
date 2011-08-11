package;

class TestValueNode extends haxe.unit.TestCase {
   public function testNew() {
      var dummy = new Dummy();
      var pool = new ValueNodePool<Dummy>();

      var node = new ValueNode<Dummy>(dummy);
      assertEquals(node.list, null);
      assertEquals(node.next, null);
      assertEquals(node.prev, null);
      assertEquals(node.value, dummy);
      assertEquals(node._pool, null);

      var node = new ValueNode<Dummy>(dummy, pool);
      assertEquals(node.list, null);
      assertEquals(node.next, null);
      assertEquals(node.prev, null);
      assertEquals(node.value, dummy);
      assertEquals(node._pool, pool);
   }

   public function testFree() {
      var dummy = new Dummy();
      var list = new ValueList<Dummy>();
      var pool = new ValueNodePool<Dummy>();

      var node = new ValueNode<Dummy>(dummy);
      node.free();
      assertEquals(node.list, null);
      assertEquals(node.next, null);
      assertEquals(node.prev, null);
      assertEquals(node.value, null);
      assertEquals(node._pool, null);

      var node = new ValueNode<Dummy>(dummy, pool);
      list.first = node;
      node.list = list;
      node.free();
      assertEquals(node.list, null);
      assertEquals(node.next, null);
      assertEquals(node.prev, null);
      assertEquals(node.value, null);
      assertEquals(node._pool, pool);
      assertEquals(list.first, null);
      assertEquals(pool._first, node);
   }
}
