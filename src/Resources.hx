package;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.Lib;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import haxe.Resource;
using Mixins;

private class ResourceData implements Dynamic {
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

private typedef LoadedListener = Void -> Void;
private typedef LoadedResourceListener = ResourceData -> Void;

class Resources {
  static public var loadedPercent(getLoadedPercent, never):Float;
  static public var loadedPercentString(getLoadedPercentString, never):String;
  static public var onLoaded:Signal<LoadedListener> = new Signal<LoadedListener>();
  static var _resources:Hash<ResourceData> = new Hash<ResourceData>();
  static var _loadedResources:Array<String> = new Array<String>();
  static var _pendingResources:Array<String> = new Array<String>();

  static public function init() {
  #if debug
    var urlRequest = new URLRequest('/res/resources.xml');
    var urlLoader = new URLLoader();
    urlLoader.addEventListener(Event.COMPLETE, function(event:Event):Void {
      Resources.load(urlLoader.data);
    });
    urlLoader.load(urlRequest);
  #else
    Resources.load(Resource.getString('resources.xml'));
  #end
  }

  static inline public function getBytes(id:String):ByteArray {
    var resource = getResource(id);
    return resource != null ? resource.content : null;
  }

  static inline public function getBitmap(id:String):BitmapData {
    var resource = getResource(id);
    return resource != null ? resource.content : null;
  }

  static inline public function getSound(id:String):Sound {
    var resource = getResource(id);
    return resource != null ? resource.content : null;
  }

  static inline public function getString(id:String):String {
    var bytes = getBytes(id);
    bytes.position = 0;
    return bytes.readUTFBytes(bytes.length);
  }

  static public function getResource(id:String):ResourceData {
    var resource = _resources.get(id);
    if (resource == null) {
      Lib.trace('Resources.getResource("' + id + '"): Invalid resource');
    }
    return resource;
  }

  static function getLoadedPercent():Float {
    var loadedLength = _loadedResources.length;
    return loadedLength / (loadedLength + _pendingResources.length);
  }

  static function getLoadedPercentString():String {
    return Std.string(Std.int(loadedPercent * 100));
  }

  static function load(text:String) {
    var reExtension = ~/\.([a-z0-9]*)$/;
    var xmlResources = Xml.parse(text).firstElement();
    for (xmlResource in xmlResources.elementsNamed('resource')) {
      var resource:ResourceData = new ResourceData();
      resource.id = xmlResource.get('id');
      resource.path = xmlResource.get('src');
      resource.type = 'bytes';

      // Grab all the subelements as data
      for (element in xmlResource.elements()) {
        var name = element.nodeName;
        var item = {};
        for (attr in element.attributes()) {
          Reflect.setField(item, attr, element.get(attr));
        }
        var items = Reflect.field(resource.data, name);
        if (items == null) {
          items = [item];
        } else {
          items.push(item);
        }
        Reflect.setField(resource.data, name, items);
      }

      #if release
      // Verify that the class exists
      var className = 'res._' + (~/[\/.]/g).replace(resource.path, '_');
      resource.cls = Type.resolveClass(className);
      if (resource.cls == null) {
        Lib.trace('error: resource class ' + className + ' not found');
        continue;
      }
      #end

      // Figure out the file type
      if (reExtension.match(resource.path)) {
        switch (reExtension.matched(1).toLowerCase()) {
          case 'ttf':
            continue;  // don't load fonts

          case 'gif':
            resource.type = 'bitmap';

          case 'jpg':
            resource.type = 'bitmap';

          case 'png':
            resource.type = 'bitmap';

          case 'mp3':
            resource.type = 'sound';
        }
      }

      _resources.set(resource.id, resource);
      _pendingResources.push(resource.id);
    }
    if (_pendingResources.length == 0) {
      onLoaded.dispatch();
    } else {
      for (resource in _resources) {
        loadResource(resource);
      }
    }
  }

  static function loadResource(resource:ResourceData, listener:LoadedResourceListener=null) {
    var urlRequest = new URLRequest('../res/' + resource.path);
    switch (resource.type) {
      case 'bitmap':
        var loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):Void {
          var bitmap = cast(loader.contentLoaderInfo.content, Bitmap);
          resource.content = bitmap.bitmapData;
          resource.contentLoaded = true;
          loadedResource(resource);
          if (listener != null) {
            listener(resource);
          }
        });
        loader.load(urlRequest);

      case 'sound':
        var sound = new Sound();
        resource.content = sound;
        sound.addEventListener(Event.COMPLETE, function(event:Event):Void {
          resource.contentLoaded = true;
          loadedResource(resource);
          if (listener != null) {
            listener(resource);
          }
        });
        sound.load(urlRequest);

      default:
        var urlLoader = new URLLoader();
        urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
        urlLoader.addEventListener(Event.COMPLETE, function(event:Event):Void {
          resource.content = urlLoader.data;
          resource.contentLoaded = true;
          loadedResource(resource);
          if (listener != null) {
            listener(resource);
          }
        });
        urlLoader.load(urlRequest);
    }
  }

  static function loadedResource(resource:ResourceData) {
    var index = _pendingResources.indexOf(resource.id);
    if (index != -1) {
      _loadedResources.push(resource.id);
      _pendingResources.splice(index, 1);
      #if debug
      var paddedPercent = StringTools.lpad(loadedPercentString, ' ', 3);
      Lib.trace('[' + paddedPercent + '%] Loaded ' + resource.path);
      #end
      if (_pendingResources.length == 0) {
        onLoaded.dispatch();
      }
    }
  }
}
