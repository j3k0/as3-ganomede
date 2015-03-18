package fovea.ganomede;

import openfl.utils.Object;

@:expose
class GanomedeNotification {
    public var id:Int;
    public var type:String;
    public var from:String;
    public var to:String;
    public var data:Object;

    public function new(obj:Object = null) {
        if (obj) {
            fromJSON(obj);
        }
    }

    public function equals(obj:Object):Bool {
        if (obj.id != id) return false;
        if (obj.type != type) return false;
        if (obj.to != to) return false;
        if (obj.from != from) return false;
        return true;
    }

    public function fromJSON(obj:Object):Void {
        if (obj.id) id = obj.id;
        if (obj.type) type = obj.type;
        if (obj.to) to = obj.to;
        if (obj.from) from = obj.from;
        if (obj.data) data = obj.data;
    }

    public function toJSON():Object {
        return {
            id:id,
            type:type,
            to:to,
            from:from,
            data:data
        };
    }
}

// vim: sw=4:ts=4:et:

