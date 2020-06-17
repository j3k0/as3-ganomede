package fovea.ganomede.models;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeInvitation extends Model {
    public var gameId:String;
    public var type:String;
    public var to:String;
    public var from:String;
    public var index:Int = 0;

    public function new(obj:Object = null) {
        super(obj);
    }

    /* public function equals(obj:Object):Bool {
        if (obj.id != id) return false;
        if (obj.gameId != gameId) return false;
        if (obj.type != type) return false;
        if (obj.to != to) return false;
        if (obj.from != from) return false;
        if (obj.index != index) return false;
        return true;
    } */

    public override function fromJSON(obj:Object):Void {
        if (obj == null) return;
        if (obj.id) id = obj.id;
        if (obj.gameId) gameId = obj.gameId;
        if (obj.type) type = obj.type;
        if (obj.to) to = obj.to;
        if (obj.from) from = obj.from;
        if (obj.index) index = obj.index;
    }

    public override function toJSON():Object {
        return {
            id:id,
            gameId:gameId,
            type:type,
            to:to,
            from:from,
            index:index
        };
    }
}

// vim: sw=4:ts=4:et:
