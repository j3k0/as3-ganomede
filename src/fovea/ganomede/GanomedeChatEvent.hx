package fovea.ganomede;

import fovea.events.Event;

//
// ChatEvents are dispatched on the channel named after their type.
//
// Content of a ChatEvent is the ChatRoom.
//
@:expose
class GanomedeChatEvent extends Event
{
    public var room:GanomedeChatRoom;

    public function new(n:GanomedeChatRoom) {
        super(n.type);
        this.room = n;
    }
}
// vim: sw=4:ts=4:et:

