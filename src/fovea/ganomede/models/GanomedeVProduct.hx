/*
    "id": "sharp_blade",
    "costs": {
        "riot_points": 400,
        "influence_points": 13
    }
*/
package fovea.ganomede.models;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeVProduct extends Model {
    public var costs:Object;

    public function new(obj:Object = null) {
        super(obj);
    }

    public override function fromJSON(obj:Object):Void {
        if (obj == null) return;
        if (obj.id && id != obj.id) { id = obj.id; dispatchUpdate(); }
        if (obj.costs && costs != obj.costs) { costs = obj.costs; dispatchUpdate(); }
    }

    private var listeners = new Array<Void->Void>();
    public function addListener(fn:Void->Void):Void {
        listeners.push(fn);
    }
    public function removeListener(fn:Void->Void):Void {
        listeners.remove(fn);
    }
    function dispatchUpdate():Void {
        for (i in 0 ... listeners.length) {
            listeners[i]();
        }
    }

    public override function toJSON():Object {
        return {
            id:id,
            costs:costs
        };
    }
}
// vim: sw=4:ts=4:et:
