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
    public var games(default,null):GanomedeGames;

    public var options(default,null):Dynamic = {}

    public function new(url:String, options:Dynamic) {
        super(url);

        this.options = options;

        // Cleanup options
        if (!options) this.options = options = {};
        if (!options.registry) options.registry = {};
        if (!options.games) options.games = {};
        if (!options.notifications) options.notifications = {};
        if (!options.invitations) options.invitations = {};
        if (!options.users) options.users = {};

        if (options.registry.enabled)
            registry = new GanomedeRegistry(this, url + "/registry/v1");
        if (options.users.enabled)
            users = new GanomedeUsers(this);
        if (options.invitations.enabled)
            invitations = new GanomedeInvitations(this);
        if (options.notifications.enabled)
            notifications = new GanomedeNotifications(this);
        if (options.games.enabled)
            games = new GanomedeGames(this, options.games.type);
    }

    public function initialize():Promise {
        var a = [];
        if (registry != null) a.push(registry.initialize);
        if (users != null) a.push(users.initialize);
        if (invitations != null) a.push(invitations.initialize);
        if (notifications != null) a.push(notifications.initialize);
        if (games != null) a.push(games.initialize);
        return Parallel.run(a)
        .then(function(outcome:Dynamic):Void {
            initialized = true;
        });
    }
}

// vim: sw=4:ts=4:et:
