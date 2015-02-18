package fovea.ganomede;

import fovea.async.*;

class GanomedeClient extends ApiClient
{
    public var initialized(default,null):Bool = false;
    public var registry(default,null):GanomedeRegistry;
    public var users(default,null):GanomedeUsers;

    private var invitations(get,null):GanomedeInvitations;
    public function get_invitations():GanomedeInvitations { return invitations; }

    public function new(url:String) {
        super(url);
        registry = new GanomedeRegistry(this, url + "/registry/v1");
        users = new GanomedeUsers(this);
        invitations = new GanomedeInvitations(this);
    }

    public function initialize():Promise {
        return Parallel.run([registry.initialize, users.initialize, invitations.initialize])
            .then(function(outcome:Dynamic):Void {
                initialized = true;
            });
    }

    // Shortcut
    public var me(get,never):GanomedeUser;
    public function get_me():GanomedeUser { return users.me; }
}

// vim: sw=4:ts=4:et:
