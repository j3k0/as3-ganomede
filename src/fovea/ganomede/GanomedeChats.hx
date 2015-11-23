package fovea.ganomede;

import fovea.async.*;
import fovea.utils.Collection;
import fovea.utils.Model;
import openfl.utils.Object;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.events.Event;
import fovea.events.Events;

@:expose
class GanomedeChats extends UserClient
{
    public var collection(default,never) = new Collection();
    public function asArray():Array<GanomedeChatRoom> {
        var array = collection.asArray();
        // order chatrooms by id
        array.sort(function arrayComparator(a:Model, b:Model):Int {
            var as = cast(a, GanomedeChatRoom).id;
            var bs = cast(b, GanomedeChatRoom).id;
            if (as < bs) return -1;
            if (as > bs) return 1;
            return 0;
        });
        return cast array;
    }
    public function toJSON():Object {
        return collection.toJSON();
    }

    public function new(client:GanomedeClient) {
        super(client, chatClientFactory, GanomedeChatClient.TYPE);
        collection.modelFactory = function modelFactory(json:Object):GanomedeChatRoom {
            return new GanomedeChatRoom(json);
        };
        addEventListener("reset", onReset);
        collection.addEventListener(Events.CHANGE, dispatchEvent);
        if (client.notifications != null) {
            client.notifications.listenTo("chat/v1", onChat);
        }
    }

    private function onChat(event:Event):Void {
        var e:GanomedeNotificationEvent = cast event;
        var data = e.notification.data;
        if (data != null && data.roomId != null) {
            var room:GanomedeChatRoom = cast collection.get(data.roomId);
            if (room != null) {
                var msg:Object = {
                    timestamp: data.timestamp,
                    from: data.from,
                    type: data.type,
                    message: data.message
                };
                room.messages.unshift(new GanomedeChatMessage(msg));
                dispatchEvent(new GanomedeChatEvent(room));
            }
            /* else {
                room = new GanomedeChatRoom({
                    id: data.roomId,
                    type: 
                    messages: [ msg ]
                });
            } */
        }
    }

    public function chatClientFactory(url:String, token:String):AuthenticatedClient {
        return new GanomedeChatClient(url, token);
    }

    private function onReset(event:Event):Void {
        collection.flushall();
        // refreshArray();
    }

    public function join(room:GanomedeChatRoom):Promise {
        if (!client.users.me.isAuthenticated()) {
            if (Ajax.verbose) trace("cant join chat room: not authenticated");
            return error(AjaxError.CLIENT_ERROR);
        }
        if (room.type == null) {
            if (Ajax.verbose) trace("cant join chat room: missing type");
            return error(AjaxError.CLIENT_ERROR);
        }
        if (room.users == null || room.users.length == 0) {
            if (Ajax.verbose) trace("cant join chat room: no users");
            return error(AjaxError.CLIENT_ERROR);
        }

        return executeAuth(function joinRoomFn():Promise {
            var chatClient:GanomedeChatClient= cast authClient;
            return chatClient.joinRoom(room);
        })
        .then(function roomJoined(outcome:Dynamic):Void {
            collection.merge(room.toJSON());
        });
    }

    public function postMessage(room:GanomedeChatRoom, message:GanomedeChatMessage):Promise {
        return executeAuth(function postMessageFn():Promise {
            var chatClient:GanomedeChatClient= cast authClient;
            return chatClient.postMessage(room, message);
        })
        .then(function messagePosted(outcome:Dynamic):Void {
            room.messages.unshift(message);
        });
    }

    //public function refreshArray():Promise {
    //    return refreshCollection(collection, function arrayRefreshed():Promise {
    //        return cast(authClient, GanomedeInvitationsClient).listInvitations();
    //    });
    //}
}

// vim: sw=4:ts=4:et:

