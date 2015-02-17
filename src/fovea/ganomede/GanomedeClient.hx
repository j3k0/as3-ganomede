package fovea.ganomede;

import fovea.async.*;

class GanomedeClient extends ApiClient
{
    public var initialized(get,null):Bool = false;
    public function get_initialized():Bool { return initialized; }

    public var registry(get,null):GanomedeRegistry;
    public function get_registry():GanomedeRegistry { return registry; }

    private var users(get,null):GanomedeUsers;
    public function get_users():GanomedeUsers { return users; }

    private var invitations(get,null):GanomedeInvitations;
    public function get_invitations():GanomedeInvitations { return invitations; }

    public function GanomedeClient(url:String) {
        super(url);
        registry = new GanomedeRegistry(this, url + "/registry/v1");
        users = new GanomedeUsers(this);
        invitations = new GanomedeInvitations(this);
    }

    public function initialize():Promise {
        return Parallel.run([registry.initialize, users.initialize, invitations.initialize])
            .then(function():Void {
                initialized = true;
            });
    }

    // Shortcut
    public function get_me():GanomedeUser { return users.me; }
}

// vim: sw=4:ts=4:et:
