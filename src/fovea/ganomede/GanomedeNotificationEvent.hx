package fovea.ganomede;

import fovea.events.Event;

@:expose
class GanomedeNotificationEvent extends Event
{
    public var notification:GanomedeNotification;

    public function new(n:GanomedeNotification) {
        super(n.from);
        this.notification = n;
    }
}
// vim: sw=4:ts=4:et:
