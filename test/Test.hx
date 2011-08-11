package;

class Test {
  static public function main() {
    var runner = new haxe.unit.TestRunner();
    runner.add(new TestValueNode());
    runner.add(new TestValueNodePool());
    runner.add(new TestValueList());
    runner.add(new TestValueListPool());
    runner.run();
  }
}
