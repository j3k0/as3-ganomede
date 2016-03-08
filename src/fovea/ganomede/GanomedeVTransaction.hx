package fovea.ganomede;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeVTransaction extends Model {

    public var type:String;
    public var currency:String;
    public var amount:Float;
    public var timestamp:Float;
    public var username:String;
    public var reason:String;
    public var data:Object;

    public function new(obj:Object = null) {
        super(obj);
    }

    public override function fromJSON(obj:Object):Void {
        if (obj == null) return;
        if (obj.id && id != obj.id) { id = obj.id; dispatchUpdate(); }
        if (obj.type && type != obj.type) { type = obj.type; dispatchUpdate(); }
        if (obj.currency && currency != obj.currency) { currency = obj.currency; dispatchUpdate(); }
        if (obj.amount && amount != obj.amount) { amount = obj.amount; dispatchUpdate(); }
        if (obj.timestamp && timestamp != obj.timestamp) { timestamp = obj.timestamp; dispatchUpdate(); }
        if (obj.username && username != obj.username) { username = obj.username; dispatchUpdate(); }
        if (obj.reason && reason != obj.reason) { reason = obj.reason; dispatchUpdate(); }
        if (obj.data) { data = obj.data; dispatchUpdate(); }
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
            type:type,
            currency:currency,
            amount:amount,
            timestamp:timestamp,
            username:username,
            reason:reason,
            data:data
        };
    }
}
// vim: sw=4:ts=4:et:
