package;

import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flash.Vector;

class Lo {
  static public inline var DEG:Float = 180.0 / Math.PI;
  static public inline var RAD:Float = Math.PI / 180.0;

  static public var cameraX:Float = 0;
  static public var cameraY:Float = 0;
  static public var elapsed(getElapsed, never):Float;
  static public var engine:Engine;
  static public var time(getTime, never):Float;
  static public var mouseDown(getMouseDown, never):Bool;
  static public var mouseUp(getMouseUp, never):Bool;
  static public var mousePressed(getMousePressed, never):Bool;
  static public var mouseReleased(getMouseReleased, never):Bool;
  static public var mouseX(getMouseX, never):Int;
  static public var mouseY(getMouseY, never):Int;
  static public var point:Point = new Point();
  static public var rect:Rectangle = new Rectangle();
  static public var stage:Stage;
  static public var width(getWidth, never):Int;
  static public var height(getHeight, never):Int;
  static var _keyDown:IntHash<Bool> = new IntHash<Bool>();
  static var _keyPressed:IntHash<Bool> = new IntHash<Bool>();
  static var _keyReleased:IntHash<Bool> = new IntHash<Bool>();
  static var _keyReset:Array<Int> = new Array<Int>();
  static var _keyResetIndex:Int = 0;
  static var _mouseDown:Bool = false;
  static var _mousePressed:Bool = false;
  static var _mouseReleased:Bool = false;
  static var _mouseX:Int = 0;
  static var _mouseY:Int = 0;
  static var _width:Int;
  static var _height:Int;

  static public function main(width:Int, height:Int, frameRate:Int, cls:Class<Engine>, args:Array<Dynamic>=null) {
    var current = Lib.current;
    var onAddedToStage:Event -> Void = null;
    var onResourcesLoaded:Void -> Void = null;
    var tryLoad:Void -> Void = null;
    tryLoad = function() {
      if (onAddedToStage == null && onResourcesLoaded == null) {
        if (args == null) {
          args = [];
        }
        Lo.init(width, height, frameRate, Type.createInstance(cls, args));
      }
    };
    onResourcesLoaded = function() {
      onResourcesLoaded = null;
      tryLoad();
    };
    if (current.stage == null) {
      onAddedToStage = function(event:Event) {
        current.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        onAddedToStage = null;
        tryLoad();
      };
      current.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    Resources.onLoaded.add(onResourcesLoaded);
    Resources.init();
  }

  static inline public function keyDown(index:Int):Bool {
    return _keyDown.get(index);
  }

  static inline public function keyPressed(index:Int):Bool {
    return _keyPressed.get(index);
  }

  static inline public function keyReleased(index:Int):Bool {
    return _keyReleased.get(index);
  }

  static inline public function abs(value:Dynamic):Dynamic {
    return value < 0 ? -value : value;
  }

  static inline public function angle(x:Float, y:Float):Float {
    var a = Math.atan2(y, x) * DEG;
    return a < 0 ? a + 360 : a;
  }

  static inline public function angleXY(out:Dynamic, angle:Float, length:Float=1, x:Float=0, y:Float=0) {
    out.x = Math.cos(angle * RAD) * length + x;
    out.y = Math.sin(angle * RAD) * length + y;
  }

  static inline public function ceil(value:Float):Float {
    var intValue = Std.int(value);
    if (value == intValue) {
      return value;
    } else if (value >= 0) {
      return Std.int(value + 1);
    } else {
      return intValue;
    }
  }

  static inline public function clamp(value:Dynamic, min:Dynamic, max:Dynamic):Dynamic {
    if (value < min) {
      return min;
    } else if (value > max) {
      return max;
    } else {
      return value;
    }
  }

  static inline public function min(a:Dynamic, b:Dynamic):Dynamic {
    return a < b ? a : b;
  }

  static inline public function max(a:Dynamic, b:Dynamic):Dynamic {
    return a > b ? a : b;
  }

  static inline public function sign(value:Dynamic):Dynamic {
    return value > 0 ? 1 : -1;
  }

  static inline public function signZero(value:Dynamic):Dynamic {
    return value == 0 ? 0 : (value > 0 ? 1 : -1);
  }

  static inline public function choose(values:Array<Dynamic>):Dynamic {
    return values[Std.int(Math.random() * values.length)];
  }

  static inline public function randomRange(min:Float, max:Float):Float {
    return min + Math.random() * (max - min);
  }

  static function init(width:Int, height:Int, frameRate:Int, engine:Engine) {
    Lo.engine = engine;
    stage = Lib.current.stage;
    stage.align = StageAlign.TOP_LEFT;
    stage.frameRate = frameRate;
    stage.quality = StageQuality.LOW;
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseUp);
    stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    _width = width;
    _height = height;
    Render.init();
    Lo.engine.init();
  }

  static function onEnterFrame(event:Event) {
    _mouseX = Std.int(stage.mouseX);
    _mouseY = Std.int(stage.mouseY);
    if (engine != null) {
      engine.tick();
    }
    Render.flip();
    while (_keyResetIndex > 0) {
      var index = _keyReset[--_keyResetIndex];
      _keyPressed.set(index, false);
      _keyReleased.set(index, false);
    }
  }

  static function onKeyDown(event:KeyboardEvent) {
    var index:Int = event.keyCode;
    if (index >= 0 && index < 256) {
      _keyDown.set(index, true);
      _keyPressed.set(index, true);
      _keyReset[_keyResetIndex++] = index;
    }
  }

  static function onKeyUp(event:KeyboardEvent) {
    var index:Int = event.keyCode;
    if (index >= 0 && index < 256) {
      _keyDown.set(index, false);
      _keyReleased.set(index, true);
      _keyReset[_keyResetIndex++] = index;
    }
  }

  static function onMouseDown(event:MouseEvent) {
    _mouseDown = true;
    _mousePressed = true;
  }

  static function onMouseUp(event:MouseEvent) {
    _mouseDown = false;
    _mouseReleased = true;
  }

  static inline function getTime():Float {
    return engine.time;
  }

  static inline function getElapsed():Float {
    return engine.elapsed;
  }

  static inline function getMouseDown():Bool {
    return _mouseDown;
  }

  static inline function getMouseUp():Bool {
    return !_mouseDown;
  }

  static inline function getMousePressed():Bool {
    return _mousePressed;
  }

  static inline function getMouseReleased():Bool {
    return _mouseReleased;
  }

  static inline function getMouseX():Int {
    return _mouseX;
  }

  static inline function getMouseY():Int {
    return _mouseY;
  }

  static inline function getWidth():Int {
    return _width;
  }

  static inline function getHeight():Int {
    return _height;
  }
}
