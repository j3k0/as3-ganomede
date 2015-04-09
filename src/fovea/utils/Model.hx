package fovea.utils;

import fovea.utils.NativeJSON;
import openfl.utils.Object;

@:expose
class Model
{
    public var id:String;

    public function new(json:Object = null) {
        if (json) {
            fromJSON(json);
        }
    }

    public function fromJSON(json:Object):Void {
        id = json.id;
    }
    public function toJSON():Object {
        return {
            id:id
        };
    }
    public function equals(obj:Object):Bool {
        return NativeJSON.stringify(toJSON()) == NativeJSON.stringify(obj);
    }
}
// vim: sw=4:ts=4:et:
