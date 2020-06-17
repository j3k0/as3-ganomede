package fovea.ganomede.models;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeTurnMove extends Model {
    public var moveData:Object;
    public var moveResult:Object;
    public var chatEvent:String;

    public function new(obj:Object = null) {
        super(obj);
    }

    public override function fromJSON(obj:Object):Void {
        if (obj.id) id = obj.id;
        if (obj.moveData) moveData = obj.moveData;
        if (obj.moveResult) moveResult = obj.moveResult;
        if (obj.chatEvent) chatEvent = obj.chatEvent;
    }

    public override function toJSON():Object {
        return {
            id:id,
            moveData:moveData,
            moveResult:moveResult,
            chatEvent:chatEvent
        };
    }
}
// vim: sw=4:ts=4:et:
