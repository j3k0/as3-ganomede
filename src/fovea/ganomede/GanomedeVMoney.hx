package fovea.ganomede;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeVMoney extends Model {
    public var count:Int;

    public function new(obj:Object = null) {
        super(obj);
    }

    public override function fromJSON(obj:Object):Void {
        if (obj == null) return;
        if (obj.id && id != obj.id) { id = obj.id; dispatchUpdate(); }
        if (!obj.count) obj.count = 0;
        if (count != obj.count) { count = obj.count; dispatchUpdate(); }
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
            count:count,
        };
    }
}
// vim: sw=4:ts=4:et:

