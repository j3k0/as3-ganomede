package fovea.utils;

#if flash

@:native("JSON")
class JSON {
    public static function stringify(d:Dynamic):String { return null; }
    public static function parse(s:String):Dynamic { return null; }
}

typedef NativeJSON = JSON;

#else

import haxe.Json;
typedef NativeJSON = Json;

#end
