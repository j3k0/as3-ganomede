package fovea.utils;

import haxe.Json;
import openfl.utils.Object;

@:expose
class Model
{
    public function new(json:Object = null) {
        if (json) {
            fromJSON(json);
        }
    }

    public function fromJSON(json:Object):Void {
    }
    public function toJSON():Object {
        return {};
    }
    public function equals(obj:Object):Bool {
        return haxe.Json.stringify(toJSON()) == haxe.Json.stringify(obj);
    }
}
// vim: sw=4:ts=4:et:
