package fovea.net;

import openfl.utils.Object;

@:expose
class UrlFormatter
{
    public function new() {}

    public static function format(url:String, params:Object):String {
        var array:Array<String> = [];
        for (k in Reflect.fields(params)) {
            var v = Reflect.field(params, k);
            if (v != null) {
                array.push(k + "=" + v);
            }
        }
        if (array.length > 0) {
            return url + "?" + array.join("&");
        }
        else {
            return url;
        }
    }
}


