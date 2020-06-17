package fovea.ganomede.models;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedePlayerScore {
    public var username:String;
    public var score:Int;

    public function new(obj:Object) {
        username = obj.username;
        score = obj.score;
    }

    public function toJSON():Object {
        return {
            username:username,
            score:score
        };
    }
}

// vim: sw=4:ts=4:et:
