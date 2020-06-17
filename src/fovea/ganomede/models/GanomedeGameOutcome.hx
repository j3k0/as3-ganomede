package fovea.ganomede.models;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeGameOutcome {
    public var newLevel:Float;
    public var newRank:Int;

    public function new(obj:Object) {
        newLevel = obj.newLevel;
        newRank = obj.newRank;
    }

    public function toJSON():Object {
        return {
            newLevel: newLevel,
            newRank: newRank
        };
    }
}

// vim: sw=4:ts=4:et:
