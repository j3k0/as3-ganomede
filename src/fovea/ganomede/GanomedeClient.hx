package fovea.ganomede;

import fovea.async.*;

@:expose
class GanomedeClient extends ApiClient
{
    public var initialized(default,null):Bool = false;
    public var registry(default,null):GanomedeRegistry;
    public var users(default,null):GanomedeUsers;
    public var invitations(default,null):GanomedeInvitations;
    public var notifications(default,null):GanomedeNotifications;

    public function new(url:String) {
        super(url);
        registry = new GanomedeRegistry(this, url + "/registry/v1");
        users = new GanomedeUsers(this);
        invitations = new GanomedeInvitations(this);
        notifications = new GanomedeNotifications(this);
    }

    public function initialize():Promise {
        return Parallel.run([
            registry.initialize,
            users.initialize,
            invitations.initialize,
            notifications.initialize
        ])
        .then(function(outcome:Dynamic):Void {
            initialized = true;
        });
    }
}

// vim: sw=4:ts=4:et:
