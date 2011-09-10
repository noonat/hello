package hello;

class MixinArray {
   static inline public function indexOf(a:Array<Dynamic>, v:Dynamic):Int {
      var index:Int = -1;
      var i:Int = -1, il:Int = a.length;
      while (++i < il) {
         if (a[i] == v) {
            index = i;
            break;
         }
      }
      return index;
   }
}
