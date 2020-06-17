package fovea.ganomede.models;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedePushToken extends Model {
    public var app:String;
    public var type:String;
    public var value:String;

    public static inline var TYPE_APN:String = "apn";
    public static inline var TYPE_GCM:String = "gcm";

    public function new(obj:Object = null) {
        super(obj);
    }

    public override function fromJSON(obj:Object):Void {
        if (obj == null) return;
        if (obj.type) type = obj.type;
        if (obj.app) app = obj.app;
        if (obj.value) value = obj.value;
    }

    public override function toJSON():Object {
        return {
            type:type,
            value:value,
            app:app
        };
    }
}

// vim: sw=4:ts=4:et:
