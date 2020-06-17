package fovea.ganomede;

import openfl.utils.Object;
import fovea.async.*;
import fovea.net.AjaxError;
import fovea.ganomede.models.GanomedeChatRoom;
import fovea.ganomede.models.GanomedeChatMessage;

//
// Multi-rooms chat service.
//
// Chat is organized into "rooms". Each room has a type and a list of players allowed to participate.

//
// All "room" related calls require a valid authToken, either:
//
//  * the token for one of the room participants.
//  * API_SECRET, in which case messages are posted as pseudo-user "$$"
//
@:expose
class GanomedeChatClient extends AuthenticatedClient
{
    public static inline var TYPE:String = "chat/v1";

    public function new(baseUrl:String, token:String) {
        super(baseUrl, TYPE, token);
    }

    // Rooms [/chat/v1/auth/:authToken/rooms]
    //
    // Create a room [POST]
    // Create a room with a given configuration (or return the one that already exists and update its ttl).
    public function joinRoom(room:GanomedeChatRoom):Promise {
        return ajax("POST", "/rooms", {
            data: {
                type: room.type,
                users: room.users
            }
        })
        .then(function(result:Object):Void {
            if (result.data.id) {
                room.fromJSON(result.data);
            }
        });
    }

    public function encodeURIComponent(s:String):String {
        return StringTools.replace(s, "/", "%2F");
    }

    // Room [/chat/v1/auth/:authToken/rooms/:roomId]
    //
    // + authToken (string, required) ... Authentication token
    // + roomId (string, required) ... URL encoded Room ID
    //
    // Retrieve content of a room [GET]
    public function loadRoom(room:GanomedeChatRoom):Promise {
        return ajax("GET", "/rooms/" + encodeURIComponent(room.id))
        .then(function(result:Object):Void {
            if (result.data.id) {
                room.fromJSON(result.data);
            }
        });
    }

    // Messages [/chat/v1/auth/:authToken/rooms/:roomId/messages]
    // + authToken (string, required) ... Authentication token
    // + roomId (string, required) ... URL encoded Room ID
    //
    // Add a message [POST]
    //
    // Append a new message to the room and updates room's TTL. If the number of messages in the room exceeds MAX_MESSAGES, the oldest will be discarded.
    public function postMessage(room:GanomedeChatRoom, message) {
        return ajax("POST", "/rooms/" + encodeURIComponent(room.id) + "/messages", {
            data: messageDataWithPush(message)
        });
    }

    public function messageDataWithPush(message:GanomedeChatMessage) {
        var data = message.toJSON();
        data.push = {
            "app": message.type,
            "title": [ "new_message_title", message.from ],
            "titleArgsTypes": [ "directory:name" ],
            "message": [ "new_message_message", message.message, message.from ],
            "messageArgsTypes": [ "string", "directory:name" ]
        };
        return data;
    }
}

// vim: sw=4:ts=4:et:


