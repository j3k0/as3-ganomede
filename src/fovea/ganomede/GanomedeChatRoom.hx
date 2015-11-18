package fovea.ganomede;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeChatRoom extends Model {
    public var type:String;
    public var users:Array<String>;

    public var messages:Array<GanomedeChatMessage>;

    public function new(obj:Object = null) {
        super(obj);
    }

    public override function fromJSON(obj:Object):Void {
        if (obj.id) id = obj.id;
        if (obj.type) type = obj.type;
        if (obj.users) users = obj.users;
        if (obj.messages) {
            messages = obj.messages.map(function(o:Object):GanomedeChatMessage {
                var m = new GanomedeChatMessage();
                m.fromJSON(o);
                return m;
            });
        }
    }

    public override function toJSON():Object {
        return {
            id:id,
            type:type,
            users:users,
            messages:messages.map(function(o:GanomedeChatMessage):Object {
                return o.toJSON();
            })
        };
    }
}

// vim: sw=4:ts=4:et:

