package;

import flash.geom.Rectangle;

private typedef CompleteFunction = Spritemap -> Void;

class Spritemap extends Graphic {
  public var anim(getAnim, never):Anim;
  public var animName(getAnimName, never):String;
  public var isFlipped(getIsFlipped, never):Bool;
  public var isPlaying:Bool;
  public var completeFunction:CompleteFunction;
  public var rate:Float;
  var _anim:Anim;
  var _animFrame:Int;
  var _animTimer:Float;
  var _anims:Hash<Anim>;
  var _animCount:Int;
  var _frame:Int;
  var _frameCount:Int;
  var _frameRect:Rectangle;
  var _frameWidth:Int;
  var _frameHeight:Int;
  var _texture:Texture;
  var _cols:Int;
  var _rows:Int;

  public function new(texture:Texture, frameWidth:Int, frameHeight:Int, completeFunction:CompleteFunction=null) {
    super();
    
    if (texture == null) {
      throw 'Invalid Spritemap: texture cannot be null';
    }
    _texture = texture;
    _cols = Std.int(texture.rect.width / frameWidth);
    _rows = Std.int(texture.rect.height / frameHeight);
    _frame = 0;
    _frameCount = _cols * _rows;
    _frameWidth = frameWidth;
    _frameHeight = frameHeight;
    _frameRect = new Rectangle(0, 0, frameWidth, frameHeight);

    _anim = null;
    _anims = new Hash<Anim>();
    _animCount = 0;
    _animFrame = 0;
    _animTimer = 0;
    this.completeFunction = completeFunction;
    isPlaying = false;
    rate = 1;
  }

  override public function render():Void {
    // Update the current frame
    if (_anim != null && isPlaying) {
      _animTimer += (_anim.frameRate * Lo.elapsed) * rate;
      while (_animTimer >= 1) {
        // Increment the frame
        --_animTimer;
        ++_animFrame;
        if (_animFrame == _anim.frameCount) {
          // End of the animation
          if (_anim.loop) {
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
    }

    _point.x = x - Lo.cameraX * scrollX;
    _point.y = y - Lo.cameraY * scrollY;
    if (entity != null && relative) {
      _point.x += entity.x;
      _point.y += entity.y;
    }
    
    // Update the frame rect
    var clipRect = _texture.clipRect;
    _frameRect.x = clipRect.x - _texture.clipOffset.x;
    _frameRect.y = clipRect.y - _texture.clipOffset.y;
    _frameRect.x += (_frame % _cols) * _frameWidth;
    _frameRect.y += Std.int(_frame / _cols) * _frameHeight;
    _frameRect.width = _frameWidth;
    _frameRect.height = _frameHeight;
    if (_frameRect.x < clipRect.x) {
      if (!isFlipped) {
        _point.x += clipRect.x - _frameRect.x;
      }
      _frameRect.left = clipRect.x;
    }
    if (_frameRect.y < clipRect.y) {
      _point.y += clipRect.y - _frameRect.y;
      _frameRect.top = clipRect.y;
    }
    if (_frameRect.right > clipRect.right) {
      _frameRect.right = clipRect.right;
    }
    if (_frameRect.bottom > clipRect.bottom) {
      _frameRect.bottom = clipRect.bottom;
    }
    if (isFlipped) {
      _frameRect.x = _texture.sourceRect.width - _frameRect.x - _frameRect.width;
    }

    // Render the frame
    if (isFlipped) {
      Render.buffer.copyPixels(_texture.sourceFlipped, _frameRect, _point);
    } else {
      Render.buffer.copyPixels(_texture.source, _frameRect, _point);
    }
  }

  public function add(name:String, frames:Array<Int>, frameRate:Float=0, loop:Bool=true, flip:Bool=false):Anim {
    if (_anims.exists(name)) {
      throw 'Cannot have multiple animations with the same name';
    }
    var anim:Anim = new Anim(name, frames, frameRate, loop, flip);
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

  inline function getIsFlipped():Bool {
    return _anim != null ? _anim.flip : false;
  }
}
