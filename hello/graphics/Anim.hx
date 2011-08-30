package hello.graphics;

/**
 * Template used by Spritemap to define animations. Don't create
 * these yourself; instead, create them with Spritemap.add().
 */
class Anim {
  public var parent:Spritemap;
  public var name:String;
  public var namePrefix:String;
  public var frames:Array<Int>;
  public var frameRate:Float;
  public var frameCount:Int;
  public var isFlipped:Bool;
  public var isLooping:Bool;

  public function new(name:String, frames:Array<Int>, frameRate:Float=0, isLooping:Bool=true, isFlipped:Bool=false) {
    this.name = name;
    this.frames = frames;
    this.frameRate = frameRate;
    this.isFlipped = isFlipped;
    this.isLooping = isLooping;
    frameCount = frames.length;
    namePrefix = name.split('_')[0];
  }

  inline public function play(reset:Bool=false) {
    parent.play(name, reset);
  }
}
