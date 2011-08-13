package;

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
  public var loop:Bool;
  public var flip:Bool;

  public function new(name:String, frames:Array<Int>, frameRate:Float=0, loop:Bool=true, flip:Bool=false) {
    this.name = name;
    this.frames = frames;
    this.frameRate = frameRate;
    this.loop = loop;
    this.flip = flip;
    frameCount = frames.length;
    namePrefix = name.split('_')[0];
  }

  inline public function play(reset:Bool=false) {
    parent.play(name, reset);
  }
}
