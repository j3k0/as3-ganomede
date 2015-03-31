package fovea.ganomede;

import openfl.utils.Object;

@:expose
class GanomedeGame {
    public var id:String;
    public var type:String;
    public var players:Array<String>;
    public var waiting:Array<String>;
    public var status:String;
    public var url:String;

    public function new(obj:Object = null) {
        if (obj) {
            fromJSON(obj);
        }
    }

    public function fromJSON(obj:Object):Void {
        if (obj.id) id = obj.id;
        if (obj.type) type = obj.type;
        if (obj.players) type = obj.players;
        if (obj.waiting) waiting = obj.waiting;
        if (obj.status) status = obj.status;
        if (obj.url) url = obj.url;
    }

    public function toJSON():Object {
        return {
            id:id,
            type:type,
            players:players,
            waiting:waiting,
            status:status,
            url:url
        };
    }
}

// vim: sw=4:ts=4:et:
