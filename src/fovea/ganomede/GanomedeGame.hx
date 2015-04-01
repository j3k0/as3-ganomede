package fovea.ganomede;

import openfl.utils.Object;
import haxe.Json;
import fovea.utils.Model;

@:expose
class GanomedeGame extends Model {
    public var id:String;
    public var type:String;
    public var players:Array<String>;
    public var waiting:Array<String>;
    public var status:String;
    public var url:String;

    public function new(obj:Object = null) {
        super(obj);
    }

    public override function fromJSON(obj:Object):Void {
        if (obj.id) id = obj.id;
        if (obj.type) type = obj.type;
        if (obj.players) players = obj.players;
        if (obj.waiting) waiting = obj.waiting;
        if (obj.status) status = obj.status;
        if (obj.url) url = obj.url;
    }

    public override function toJSON():Object {
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
