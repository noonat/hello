package hello;

class Asset {
   public var id:String;
   public var path:String;
   public var type:String;
   public var cls:Class<Dynamic>;
   public var content:Dynamic;
   public var contentLoaded:Bool;
   public var data:Dynamic;

   public function new() {
      cls = null;
      content = null;
      contentLoaded = false;
      data = {};
   }
}
