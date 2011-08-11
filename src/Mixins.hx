package;

private typedef CompareFunction = Dynamic -> Dynamic -> Int;

private typedef SortableArray = {
   public function sort(compareFunction:CompareFunction, sortOptions:Int):Void;
   public function sortOn(fieldName:String, options:Dynamic):Void;
}

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
   
   static inline public function sortable(a:Array<Dynamic>):SortableArray {
      return untyped a;
   }
}
