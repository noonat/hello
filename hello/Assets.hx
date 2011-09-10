package hello;

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
using hello.Mixins;

private typedef LoadedListener = Void -> Void;
private typedef LoadedAssetListener = Asset -> Void;

class Assets {
   static public var basePath:String;
   static public var loadedPercent(getLoadedPercent, never):Float;
   static public var loadedPercentString(getLoadedPercentString, never):String;
   static public var onLoaded:Signal<LoadedListener> = new Signal<LoadedListener>();
   static var _assets:Hash<Asset> = new Hash<Asset>();
   static var _loadedAssets:Array<String> = new Array<String>();
   static var _pendingAssets:Array<String> = new Array<String>();

   static public function init() {
   #if debug
      getBasePath(Resource.getString('assets.xml'));
      var urlRequest = new URLRequest(basePath + '/assets.xml');
      var urlLoader = new URLLoader();
      urlLoader.addEventListener(Event.COMPLETE, function(event:Event) {
         Assets.load(urlLoader.data);
      });
      urlLoader.load(urlRequest);
   #else
      load(Resource.getString('assets.xml'));
   #end
   }

   static inline public function getBytes(id:String):ByteArray {
      var asset = get(id);
      return asset != null ? asset.content : null;
   }

   static inline public function getBitmap(id:String):BitmapData {
      var asset = get(id);
      return asset != null ? asset.content : null;
   }

   static inline public function getSound(id:String):Sound {
      var asset = get(id);
      return asset != null ? asset.content : null;
   }

   static inline public function getString(id:String):String {
      var bytes = getBytes(id);
      return if (bytes != null) {
         bytes.position = 0;
         bytes.readUTFBytes(bytes.length);
      } else {
         null;
      }
   }

   static public function get(id:String):Asset {
      var asset = _assets.get(id);
      if (asset == null) {
         Lib.trace('Assets.get("' + id + '"): Invalid asset');
      }
      return asset;
   }

   static function getBasePath(xml:Dynamic):String {
      if (Std.is(xml, String)) {
         xml = Xml.parse(xml).firstElement();
      }
      basePath = xml.get('path');
      if (basePath == null) {
         basePath = '/assets';
      }
      basePath = ~/\/+$/g.replace(basePath, '');
      return basePath;
   }

   static function getLoadedPercent():Float {
      var loadedLength = _loadedAssets.length;
      return loadedLength / (loadedLength + _pendingAssets.length);
   }

   static function getLoadedPercentString():String {
      return Std.string(Std.int(loadedPercent * 100));
   }

   static function load(text:String) {
      var reExtension = ~/\.([a-z0-9]*)$/;
      var xmlAssets = Xml.parse(text).firstElement();
      getBasePath(xmlAssets);
      for (xmlAsset in xmlAssets.elementsNamed('asset')) {
         var asset:Asset = new Asset();
         asset.id = xmlAsset.get('id');
         asset.path = xmlAsset.get('src');
         asset.type = 'bytes';

         // Grab all the subelements as data
         for (element in xmlAsset.elements()) {
            var name = element.nodeName;
            var item = {};
            for (attr in element.attributes()) {
               Reflect.setField(item, attr, element.get(attr));
            }
            var items = Reflect.field(asset.data, name);
            if (items == null) {
               items = [item];
            } else {
               items.push(item);
            }
            Reflect.setField(asset.data, name, items);
         }

         #if release
         // Verify that the class exists
         var className = 'assets._' + (~/[\/.]/g).replace(asset.path, '_');
         asset.cls = Type.resolveClass(className);
         if (asset.cls == null) {
            Lib.trace('error: asset class ' + className + ' not found');
            continue;
         }
         #end

         // Figure out the file type
         if (reExtension.match(asset.path)) {
            switch (reExtension.matched(1).toLowerCase()) {
               case 'ttf':
                  continue;  // don't load fonts

               case 'gif':
                  asset.type = 'bitmap';

               case 'jpg':
                  asset.type = 'bitmap';

               case 'png':
                  asset.type = 'bitmap';

               case 'mp3':
                  asset.type = 'sound';
            }
         }

         _assets.set(asset.id, asset);
         _pendingAssets.push(asset.id);
      }
      if (_pendingAssets.length == 0) {
         onLoaded.dispatch();
      } else {
         for (asset in _assets) {
            loadAsset(asset);
         }
      }
   }

   static public function loadAsset(asset:Asset, listener:LoadedAssetListener=null) {
      var urlRequest = new URLRequest(basePath + '/' + asset.path);
      switch (asset.type) {
         case 'bitmap':
            var loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event) {
               var bitmap = cast(loader.contentLoaderInfo.content, Bitmap);
               asset.content = bitmap.bitmapData;
               asset.contentLoaded = true;
               loadedAsset(asset);
               if (listener != null) {
                  listener(asset);
               }
            });
            loader.load(urlRequest);

         case 'sound':
            var sound = new Sound();
            asset.content = sound;
            sound.addEventListener(Event.COMPLETE, function(event:Event) {
               asset.contentLoaded = true;
               loadedAsset(asset);
               if (listener != null) {
                  listener(asset);
               }
            });
            sound.load(urlRequest);

         default:
            var urlLoader = new URLLoader();
            urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
            urlLoader.addEventListener(Event.COMPLETE, function(event:Event) {
               asset.content = urlLoader.data;
               asset.contentLoaded = true;
               loadedAsset(asset);
               if (listener != null) {
                  listener(asset);
               }
            });
            urlLoader.load(urlRequest);
      }
   }

   static function loadedAsset(asset:Asset) {
      var index = _pendingAssets.indexOf(asset.id);
      if (index != -1) {
         _loadedAssets.push(asset.id);
         _pendingAssets.splice(index, 1);
         #if debug
         var paddedPercent = StringTools.lpad(loadedPercentString, ' ', 3);
         Lib.trace('[' + paddedPercent + '%] Loaded ' + asset.path);
         #end
         if (_pendingAssets.length == 0) {
            onLoaded.dispatch();
         }
      }
   }
}
