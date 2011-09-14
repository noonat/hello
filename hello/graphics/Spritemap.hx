package hello.graphics;

import flash.geom.Rectangle;

private typedef CompleteFunction = Spritemap -> Void;

class Spritemap extends Image {
   public var anim(getAnim, never):Anim;
   public var animName(getAnimName, never):String;
   public var completeFunction:CompleteFunction;
   public var frame(getFrame, setFrame):Int;
   public var frameCount(getFrameCount, never):Int;
   public var isPlaying:Bool;
   public var rate:Float;
   var _anim:Anim;
   var _animFrame:Int;
   var _animTimer:Float;
   var _anims:Hash<Anim>;
   var _animCount:Int;
   var _frame:Int;
   var _frameCount:Int;
   var _frameWidth:Int;
   var _frameHeight:Int;
   var _cols:Int;
   var _rows:Int;

   public function new(texture:Texture, frameWidth:Int, frameHeight:Int, completeFunction:CompleteFunction=null) {
      if (texture == null) {
         throw 'Invalid Spritemap: texture cannot be null';
      }
      _cols = Std.int(texture.rect.width / frameWidth);
      _rows = Std.int(texture.rect.height / frameHeight);
      _frame = 0;
      _frameCount = _cols * _rows;
      _frameWidth = frameWidth;
      _frameHeight = frameHeight;

      _anim = null;
      _anims = new Hash<Anim>();
      _animCount = 0;
      _animFrame = 0;
      _animTimer = 0;
      this.completeFunction = completeFunction;
      isPlaying = false;
      rate = 1;

      super(texture, new Rectangle(0, 0, frameWidth, frameHeight));
   }

   override public function render(target:Renderer) {
      // Update the current frame
      if (_anim != null && isPlaying) {
         var oldFrame = _frame;
         _animTimer += (_anim.frameRate * Lo.elapsed) * rate;
         while (_animTimer >= 1) {
            // Increment the frame
            --_animTimer;
            ++_animFrame;
            if (_animFrame == _anim.frameCount) {
               // End of the animation
               if (_anim.isLooping) {
                  // Looping, go back to the first farme
                  _animFrame = 0;
                  if (completeFunction != null) {
                     completeFunction(this);
                  }
               } else {
                  // Not looping, stop the animation on the last frame
                  _animFrame = _anim.frameCount - 1;
                  isPlaying = false;
                  if (completeFunction != null) {
                     completeFunction(this);
                  }
                  break;
               }
            }
         }
         if (_anim != null) {
            _frame = _anim.frames[_animFrame];
         }
         if (_angle != 0 && _frame != oldFrame) {
            _angleChanged = true;
         }
      }

      // Render the frame
      clipRect.x = (_frame % _cols) * _frameWidth;
      clipRect.y = Std.int(_frame / _cols) * _frameHeight;
      super.render(target);
   }

   public function add(name:String, frames:Array<Int>, frameRate:Float=0, isLooping:Bool=true, isFlipped:Bool=false):Anim {
      if (_anims.exists(name)) {
         throw 'Cannot have multiple animations with the same name';
      }
      var anim = new Anim(name, frames, frameRate, isLooping, isFlipped);
      anim.parent = this;
      _anims.set(name, anim);
      ++_animCount;
      return anim;
   }

   public function play(name:String='', reset:Bool=false, frame:Int=0):Anim {
      if (!reset && _anim != null && _anim.name == name) {
         return _anim;
      }
      _anim = _anims.get(name);
      if (_anim == null) {
         _animFrame = _frame = 0;
         _animTimer = 0;
         isPlaying = false;
         return null;
      }
      if (frame != _animFrame) {
         _animTimer = 0;
         _animFrame = frame;
      }
      _frame = _anim.frames[_animFrame];
      isPlaying = true;
      return _anim;
   }

   inline function getAnim():Anim {
      return _anim;
   }

   inline function getAnimName():String {
      return _anim != null ? _anim.name : null;
   }

   inline function getFrame():Int {
      return _frame;
   }

   inline function setFrame(value:Int):Int {
      if (_anim != null) {
         _anim = null;
      }
      value %= _frameCount;
      if (value < 0) {
         value += _frameCount;
      }
      if (_frame != value) {
         _frame = value;
         if (_angle != 0) {
            _angleChanged = true;
         }
      }
      return value;
   }

   inline function getFrameCount():Int {
      return _frameCount;
   }

   override function getIsFlipped():Bool {
      return _anim != null ? _anim.isFlipped : _isFlipped;
   }
}
