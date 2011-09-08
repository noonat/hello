package hello;

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.utils.TypedDictionary;

private typedef CompleteFunction = Void -> Void;

class Sfx {
  public var completeFunction:CompleteFunction;
  public var duration(getDuration, never):Float;
  public var elapsed(getElapsed, never):Float;
  public var isPlaying(getIsPlaying, never):Bool;
  public var pan(getPan, setPan):Float;
  public var position(getPosition, never):Float;
  public var volume(getVolume, setVolume):Float;
  var _channel:SoundChannel;
  var _filteredPan:Float;
  var _filteredVol:Float;
  var _isLooping:Bool;
  var _pan:Float;
  var _position:Float;
  var _sound:Sound;
  var _transform:SoundTransform;
  var _type:String;
  var _vol:Float;

  static var _sounds:Hash<Sound> = new Hash<Sound>();
  static var _times:Hash<Float> = new Hash<Float>();
  static var _typePlaying:Hash<TypedDictionary<Sfx, Sfx>> = new Hash<TypedDictionary<Sfx, Sfx>>();
  static var _typeTransforms:Hash<SoundTransform> = new Hash<SoundTransform>();

  public function new(source:Dynamic, type:String='sfx', ?completeFunction:CompleteFunction) {
    this.completeFunction = completeFunction;
    _pan = 0;
    _position = 0;
    _transform = new SoundTransform();
    _type = type;
    _vol = 1;

    if (Std.is(source, Class)) {
      var className:String = Type.getClassName(source);
      _sound = _sounds.get(className);
      if (_sound == null) {
        _sound = cast(Type.createInstance(source, []), Sound);
        _sounds.set(className, _sound);
      }
    }
    else if (Std.is(source, Sound)) {
      _sound = source;
    } else {
      throw "Sfx source needs to be of type Class or Sound";
    }
  }

  public function play(vol:Float=1, pan:Float=0, minElapsed:Float=0) {
    if (elapsed < minElapsed) {
      return;
    }
    _times.set(_sound.url, Lo.time);
    if (_channel != null) {
      stop();
    }
    _pan = Lo.clamp(pan, -1, 1);
    _vol = Lo.max(vol, 0);
    _filteredPan = Lo.clamp(_pan + getTypePan(_type), -1, 1);
    _filteredVol = Lo.max(_vol * getTypeVolume(_type), 0);
    _transform.pan = _filteredPan;
    _transform.volume = _filteredVol;
    _channel = _sound.play(0, 0, _transform);
    if (_channel != null) {
      addPlaying();
      _channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
    }
    _isLooping = false;
    _position = 0;
  }

  public function loop(vol:Float=1, pan:Float=0, minElapsed:Float=0) {
    play(vol, pan, minElapsed);
    _isLooping = true;
  }

  public function stop():Bool {
    if (_channel != null) {
      removePlaying();
      _position = _channel.position;
      _channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
      _channel.stop();
      _channel = null;
      return true;
    } else {
      return false;
    }
  }

  public function resume() {
    _channel = _sound.play(_position, 0, _transform);
    if (_channel != null) {
      addPlaying();
      _channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
    }
    _position = 0;
  }

  function onComplete(event:Event=null) {
    if (_isLooping) {
      loop(_vol, _pan);
    } else {
      stop();
    }
    _position = 0;
    if (completeFunction != null) {
      completeFunction();
    }
  }

  function addPlaying() {
    var playing = _typePlaying.get(_type);
    if (playing == null) {
      playing = new TypedDictionary<Sfx, Sfx>();
      _typePlaying.set(_type, playing);
    }
    playing.set(this, this);
  }

  function removePlaying() {
    var playing = _typePlaying.get(_type);
    if (playing != null) {
      playing.delete(this);
    }
  }

  inline function getVolume():Float {
    return _vol;
  }

  inline function setVolume(value:Float):Float {
    if (value < 0) {
      value = 0;
    }
    var filtered = Lo.max(value * getTypeVolume(_type), 0);
    if (_channel != null || _filteredVol != filtered) {
      _vol = value;
      _transform.volume = _filteredVol = filtered;
      _channel.soundTransform = _transform;
    }
    return _vol;
  }

  inline function getPan():Float {
    return _pan;
  }

  inline function setPan(value:Float):Float {
    value = Lo.clamp(value, -1, 1);
    var filtered = Lo.clamp(value * getTypePan(_type), -1, 1);
    if (_channel != null && _filteredPan != filtered) {
      _pan = value;
      _transform.pan = _filteredPan = filtered;
      _channel.soundTransform = _transform;
    }
    return _pan;
  }

  inline function getDuration():Float {
    return _sound.length / 1000;
  }

  inline function getElapsed():Float {
    return Lo.time - (_times.exists(_sound.url) ? _times.get(_sound.url) : 0);
  }

  inline function getIsPlaying():Bool {
    return _channel != null;
  }

  inline function getPosition():Float {
    return (_channel != null ? _channel.position : _position) / 1000;
  }

  static public function getTypePan(type:String):Float {
    var transform = _typeTransforms.get(type);
    return transform != null ? transform.pan : 0;
  }

  static public function getTypeVolume(type:String):Float {
    var transform = _typeTransforms.get(type);
    return transform != null ? transform.volume : 1;
  }

  static public function setTypePan(type:String, pan:Float) {
    var transform = _typeTransforms.get(type);
    if (transform == null) {
      transform = new SoundTransform();
      _typeTransforms.set(type, transform);
    }
    transform.pan = Lo.clamp(pan, -1, 1);
    var playing = _typePlaying.get(type);
    if (playing != null) {
      for (sfx in playing) {
        sfx.pan = sfx.pan;
      }
    }
  }

  static public function setTypeVolume(type:String, volume:Float) {
    var transform = _typeTransforms.get(type);
    if (transform == null) {
      transform = new SoundTransform();
      _typeTransforms.set(type, transform);
    }
    transform.volume = Lo.max(volume, 0);
    var playing = _typePlaying.get(type);
    if (playing != null) {
      for (sfx in playing) {
        sfx.volume = sfx.volume;
      }
    }
  }
}
