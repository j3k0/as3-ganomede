package fovea.ganomede;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeTurnMove extends Model {
    public var moveData:Object;
    public var moveResult:Object;

    public function new(obj:Object = null) {
        super(obj);
    }

    public override function fromJSON(obj:Object):Void {
        if (obj.id) id = obj.id;
        if (obj.moveData) moveData = obj.moveData;
        if (obj.moveResult) moveResult = obj.moveResult;
    }

    public override function toJSON():Object {
        return {
            id:id,
            moveData:moveData,
            moveResult:moveResult
        };
    }
}
// vim: sw=4:ts=4:et:
