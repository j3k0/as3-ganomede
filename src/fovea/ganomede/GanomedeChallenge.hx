package fovea.ganomede;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeChallenge extends Model {
    public var type:String;
    public var start:Float;
    public var end:Float;
    public var secondsToEnd:Float;
    public var gameData:Object;

    public function new(obj:Object = null) {
        super(obj);
    }

    public override function fromJSON(obj:Object):Void {
        if (obj == null) return;
        if (obj.id) id = obj.id;
        if (obj.type) type = obj.type;
        if (obj.start) start = obj.start;
        if (obj.end) end = obj.end;
        if (obj.secondsToEnd) secondsToEnd = obj.secondsToEnd;
        if (obj.gameData) gameData = obj.gameData;
    }

    public override function toJSON():Object {
        return {
            id:id,
            type:type,
            gameData:gameData,
            start:start,
            end:end,
            secondsToEnd:secondsToEnd
        };
    }
}

// vim: sw=4:ts=4:et:
