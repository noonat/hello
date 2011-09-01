package hello;

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
import hello.graphics.TextureAtlas;

#if monster
  import com.demonsters.debugger.MonsterDebugger;
#end

class Lo {
  static public inline var EPSILON:Float = 1e-8;
  static public inline var DEG:Float = 180.0 / Math.PI;  // radians to degrees
  static public inline var RAD:Float = Math.PI / 180.0;  // degrees to radians

  static public var atlas:TextureAtlas;
  static public var cameraX:Float = 0;
  static public var cameraY:Float = 0;
  static public var cameraMouseX(getCameraMouseX, never):Float;
  static public var cameraMouseY(getCameraMouseY, never):Float;
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
  static public var zero:Point = new Point();
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
    #if monster
      MonsterDebugger.initialize(Lib.current);
      MonsterDebugger.inspect({Lo: Lo, Render: Render});
    #end
    var current = Lib.current;
    var onAddedToStage:Event -> Void = null;
    var onAssetsLoaded:Void -> Void = null;
    var tryLoad:Void -> Void = null;
    tryLoad = function() {
      if (onAddedToStage == null && onAssetsLoaded == null) {
        if (args == null) {
          args = [];
        }
        Lo.init(width, height, frameRate, cls, args);
      }
    };
    onAssetsLoaded = function() {
      onAssetsLoaded = null;
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
    Assets.onLoaded.add(onAssetsLoaded);
    Assets.init();
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

  static inline public function approx(a:Float, b:Float):Bool {
    return abs(a - b) < EPSILON;
  }

  static inline public function ceil(value:Float):Int {
    var intValue = Std.int(value);
    return if (value != intValue && value >= 0) {
      Std.int(value + 1);
    } else {
      intValue;
    }
  }

  static inline public function clamp(value:Float, min:Float, max:Float):Float {
    return value < min ? min : (value > max ? max : value);
  }

  static inline public function clampInt(value:Int, min:Int, max:Int):Int {
    return value < min ? min : (value > max ? max : value);
  }

  static inline public function lerp(value:Float, min:Float, max:Float):Float {
    return min + value * (max - min);
  }

  static inline public function min(a:Float, b:Float):Float {
    return a < b ? a : b;
  }

  static inline public function minInt(a:Int, b:Int):Int {
    return a < b ? a : b;
  }

  static inline public function max(a:Float, b:Float):Float {
    return a > b ? a : b;
  }

  static inline public function maxInt(a:Int, b:Int):Int {
    return a > b ? a : b;
  }

  static inline public function scaleClamp(value:Float, min1:Float, max1:Float, min2:Float, max2:Float):Float {
    var value = min2 + ((value - min1) / (max1 - min1)) * (max2 - min2);
    return Lo.clamp(value, min2, max2);
  }

  static inline public function sign(value:Float):Float {
    return value > 0 ? 1 : -1;
  }

  static inline public function signInt(value:Int):Int {
    return value > 0 ? 1 : -1;
  }

  static inline public function signZero(value:Float):Float {
    return value == 0 ? 0 : (value > 0 ? 1 : -1);
  }

  static inline public function signZeroInt(value:Int):Int {
    return value == 0 ? 0 : (value > 0 ? 1 : -1);
  }

  static inline public function choose(values:Array<Dynamic>):Dynamic {
    return values[Std.int(Math.random() * values.length)];
  }

  static inline public function randomRange(min:Float, max:Float):Float {
    return min + Math.random() * (max - min);
  }

  static inline public function inspect(args:Dynamic) {
    #if monster
      MonsterDebugger.inspect(args);
    #end
  }

  static inline public function trace(args:Dynamic) {
    #if monster
      MonsterDebugger.trace(null, args);
    #elseif debug
      #if flash
        flash.Lib.trace(args);
      #else
        trace(args);
      #end
    #end
  }

  static inline public function breakpoint(caller:Dynamic=null) {
    #if monster
      if (caller != null) {
        inspect(caller);
      }
      MonsterDebugger.breakpoint(caller);
    #elseif (debug && flash)
      untyped __global__["flash.debugger.enterDebugger"]();
    #end
  }

  static function init(width:Int, height:Int, frameRate:Int, cls:Class<Engine>, args:Array<Dynamic>) {
    stage = Lib.current.stage;
    stage.align = StageAlign.TOP_LEFT;
    stage.frameRate = frameRate;
    stage.quality = StageQuality.LOW;
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    _width = width;
    _height = height;
    Render.init();
    Lo.engine = Type.createInstance(cls, args);
  }

  static function onEnterFrame(event:Event) {
    _mouseX = Std.int(stage.mouseX);
    _mouseY = Std.int(stage.mouseY);
    if (engine != null) {
      engine.tick();
    }
    Render.flip();
    _mousePressed = false;
    _mouseReleased = false;
    while (_keyResetIndex > 0) {
      var index = _keyReset[--_keyResetIndex];
      _keyPressed.set(index, false);
      _keyReleased.set(index, false);
    }
  }

  static function onKeyDown(event:KeyboardEvent) {
    var index:Int = event.keyCode;
    if (index >= 0 && index < 256) {
      if (!_keyDown.get(index)) {
        _keyDown.set(index, true);
        _keyPressed.set(index, true);
        _keyReset[_keyResetIndex++] = index;
      }
    }
  }

  static function onKeyUp(event:KeyboardEvent) {
    var index:Int = event.keyCode;
    if (index >= 0 && index < 256) {
      if (_keyDown.get(index)) {
        _keyDown.set(index, false);
        _keyReleased.set(index, true);
        _keyReset[_keyResetIndex++] = index;
      }
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

  static inline function getCameraMouseX():Float {
    return _mouseX + cameraX;
  }

  static inline function getCameraMouseY():Float {
    return _mouseY + cameraY;
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
