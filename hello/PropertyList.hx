package hello;

import haxe.xml.Fast;

/**
* Apple property list parser.
*
* For example, the following property list XML:
*
*     <?xml version="1.0" encoding="UTF-8"?>
*     <plist version="1.0">
*       <dict>
*          <key>foo</key>
*          <integer>1</key>
*          <key>bar</key>
*          <dict>
*            <key>hello</key>
*            <string>world</key>
*            <key>goodbye</key>
*            <string>world</key>
*          </dict>
*       </dict>
*     </plist>
*
* Would be parsed into the following object:
*
*     {
*       "key": 1,
*       "bar": {
*         "hello": "world",
*         "goodbye": "world"
*       }
*     }
*/
class PropertyList {
  static var _dateRegex:EReg = ~/(\d{4}-\d{2}-\d{2})(?:T(\d{2}:\d{2}:\d{2})Z)?/;
  
  /**
  * Parse an Apple property list XML file into a dynamic object. If
  * the property list is empty, an empty object will be returned.
  * @param text Text contents of the property list file.
  */
  static public function read(text:String):Dynamic {
    var fast = new Fast(Xml.parse(text).firstElement());
    return fast.hasNode.dict ? readDict(fast.node.dict) : {};
  }
  
  static function readDate(text:String):Date {
    if (!_dateRegex.match(text)) {
      throw 'Invalid date "' + text + '" (only yyyy-mm-dd and yyyy-mm-ddThh:mm:ssZ supported)';
    }
    text = _dateRegex.matched(1);
    if (_dateRegex.matched(2) != null) {
      text += ' ' + _dateRegex.matched(2);
    }
    return Date.fromString(text);
  }

  static function readDict(node:Fast):Dynamic {
    var key:String = null;
    var result:Dynamic = {};
    for (childNode in node.elements) {
      if (childNode.name == 'key') {
        key = childNode.innerData;
      } else if (key != null) {
        Reflect.setField(result, key, readValue(childNode));
      }
    }
    return result;
  }

  static function readValue(node:Fast):Dynamic {
    var value:Dynamic = null;
    switch (node.name) {
      case 'array':
        value = new Array<Dynamic>();
        for (childNode in node.elements) {
          value.push(readValue(childNode));
        }
      
      case 'dict':
        value = readDict(node);
      
      case 'date':
        value = readDate(node.innerData);
      
      case 'string', 'data':
        value = node.innerData;
      
      case 'true':
        value = true;
      
      case 'false':
        value = false;
      
      case 'real':
        value = Std.parseFloat(node.innerData);
      
      case 'integer':
        value = Std.parseInt(node.innerData);
    }
    return value;
  }
}
