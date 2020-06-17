package fovea.ganomede.models;

import openfl.utils.Object;

// Message format:
// {
//     "timestamp": 1429084002258,
//     "from": "alice",
//     "type": "text",
//     "message": "Hey bob! How are you today?"
// }
@:expose
class GanomedeChatMessage {
    public var timestamp:String;
    public var from:String;
    public var type:String;
    public var message:String;

    public function new(obj:Object = null) {
        if (obj) {
            fromJSON(obj);
        }
    }

    public function fromJSON(obj:Object):Void {
        if (obj.timestamp) timestamp = obj.timestamp;
        if (obj.from) from = obj.from;
        if (obj.type) type = obj.type;
        if (obj.message) message = obj.message;
    }

    public function toJSON():Object {
        return {
            timestamp:timestamp,
            from:from,
            type:type,
            message:message
        };
    }
}

// vim: sw=4:ts=4:et:
