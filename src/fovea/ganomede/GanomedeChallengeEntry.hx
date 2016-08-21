package fovea.ganomede;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeChallengeEntry extends Model {
    public var username:String;
    public var timestamp:Float;
    public var score:Float;
    public var time:Float;

    public function new(obj:Object = null) {
        super(obj);
    }

    public override function fromJSON(obj:Object):Void {
        if (obj == null) return;
        if (obj.id) id = obj.id;
        if (obj.username) username = obj.username;
        if (obj.timestamp) timestamp = obj.timestamp;
        if (obj.score) score = obj.score;
        if (obj.time) time = obj.time;
    }

    public override function toJSON():Object {
        return {
            id:id,
            username:username,
            timestamp:timestamp,
            score:score,
            time:time
        };
    }
}

// vim: sw=4:ts=4:et:
