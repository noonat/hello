package hello;

class Key {
  static public inline var ANY:Int = -1;

  static public inline var LEFT:Int = 37;
  static public inline var UP:Int = 38;
  static public inline var RIGHT:Int = 39;
  static public inline var DOWN:Int = 40;

  static public inline var ENTER:Int = 13;
  static public inline var CONTROL:Int = 17;
  static public inline var SPACE:Int = 32;
  static public inline var SHIFT:Int = 16;
  static public inline var BACKSPACE:Int = 8;
  static public inline var CAPS_LOCK:Int = 20;
  static public inline var DELETE:Int = 46;
  static public inline var END:Int = 35;
  static public inline var ESCAPE:Int = 27;
  static public inline var HOME:Int = 36;
  static public inline var INSERT:Int = 45;
  static public inline var TAB:Int = 9;
  static public inline var PAGE_DOWN:Int = 34;
  static public inline var PAGE_UP:Int = 33;
  static public inline var LEFT_SQUARE_BRACKET:Int = 219;
  static public inline var RIGHT_SQUARE_BRACKET:Int = 221;
  static public inline var TILDE:Int = 192;

  static public inline var A:Int = 65;
  static public inline var B:Int = 66;
  static public inline var C:Int = 67;
  static public inline var D:Int = 68;
  static public inline var E:Int = 69;
  static public inline var F:Int = 70;
  static public inline var G:Int = 71;
  static public inline var H:Int = 72;
  static public inline var I:Int = 73;
  static public inline var J:Int = 74;
  static public inline var K:Int = 75;
  static public inline var L:Int = 76;
  static public inline var M:Int = 77;
  static public inline var N:Int = 78;
  static public inline var O:Int = 79;
  static public inline var P:Int = 80;
  static public inline var Q:Int = 81;
  static public inline var R:Int = 82;
  static public inline var S:Int = 83;
  static public inline var T:Int = 84;
  static public inline var U:Int = 85;
  static public inline var V:Int = 86;
  static public inline var W:Int = 87;
  static public inline var X:Int = 88;
  static public inline var Y:Int = 89;
  static public inline var Z:Int = 90;

  static public inline var F1:Int = 112;
  static public inline var F2:Int = 113;
  static public inline var F3:Int = 114;
  static public inline var F4:Int = 115;
  static public inline var F5:Int = 116;
  static public inline var F6:Int = 117;
  static public inline var F7:Int = 118;
  static public inline var F8:Int = 119;
  static public inline var F9:Int = 120;
  static public inline var F10:Int = 121;
  static public inline var F11:Int = 122;
  static public inline var F12:Int = 123;
  static public inline var F13:Int = 124;
  static public inline var F14:Int = 125;
  static public inline var F15:Int = 126;

  static public inline var DIGIT_0:Int = 48;
  static public inline var DIGIT_1:Int = 49;
  static public inline var DIGIT_2:Int = 50;
  static public inline var DIGIT_3:Int = 51;
  static public inline var DIGIT_4:Int = 52;
  static public inline var DIGIT_5:Int = 53;
  static public inline var DIGIT_6:Int = 54;
  static public inline var DIGIT_7:Int = 55;
  static public inline var DIGIT_8:Int = 56;
  static public inline var DIGIT_9:Int = 57;

  static public inline var NUMPAD_0:Int = 96;
  static public inline var NUMPAD_1:Int = 97;
  static public inline var NUMPAD_2:Int = 98;
  static public inline var NUMPAD_3:Int = 99;
  static public inline var NUMPAD_4:Int = 100;
  static public inline var NUMPAD_5:Int = 101;
  static public inline var NUMPAD_6:Int = 102;
  static public inline var NUMPAD_7:Int = 103;
  static public inline var NUMPAD_8:Int = 104;
  static public inline var NUMPAD_9:Int = 105;
  static public inline var NUMPAD_ADD:Int = 107;
  static public inline var NUMPAD_DECIMAL:Int = 110;
  static public inline var NUMPAD_DIVIDE:Int = 111;
  static public inline var NUMPAD_ENTER:Int = 108;
  static public inline var NUMPAD_MULTIPLY:Int = 106;
  static public inline var NUMPAD_SUBTRACT:Int = 109;

  /**
   * Returns the name of the key.
   * @param   char      The key to name.
   * @return   The name.
   */
  static public function name(char:Int):String {
    if (char >= A && char <= Z) {
      return String.fromCharCode(char);
    }
    if (char >= F1 && char <= F15) {
      return "F" + Std.string(char - 111);
    }
    if (char >= 96 && char <= 105) {
      return "NUMPAD " + Std.string(char - 96);
    }
    switch (char) {
      case LEFT:
        return "LEFT";

      case UP:
        return "UP";

      case RIGHT:
        return "RIGHT";

      case DOWN:
        return "DOWN";

      case ENTER:
        return "ENTER";

      case CONTROL:
        return "CONTROL";

      case SPACE:
        return "SPACE";

      case SHIFT:
        return "SHIFT";

      case BACKSPACE:
        return "BACKSPACE";

      case CAPS_LOCK:
        return "CAPS LOCK";

      case DELETE:
        return "DELETE";

      case END:
        return "END";

      case ESCAPE:
        return "ESCAPE";

      case HOME:
        return "HOME";

      case INSERT:
        return "INSERT";

      case TAB:
        return "TAB";

      case PAGE_DOWN:
        return "PAGE DOWN";

      case PAGE_UP:
        return "PAGE UP";

      case NUMPAD_ADD:
        return "NUMPAD ADD";

      case NUMPAD_DECIMAL:
        return "NUMPAD DECIMAL";

      case NUMPAD_DIVIDE:
        return "NUMPAD DIVIDE";

      case NUMPAD_ENTER:
        return "NUMPAD ENTER";

      case NUMPAD_MULTIPLY:
        return "NUMPAD MULTIPLY";

      case NUMPAD_SUBTRACT:
        return "NUMPAD SUBTRACT";

      default:
        return String.fromCharCode(char);
    }
    return String.fromCharCode(char);
  }
}
