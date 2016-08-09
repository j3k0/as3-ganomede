package fovea.ganomede;

import fovea.async.*;

// Entry point to a Ganomede server

@:expose
class GanomedeClient extends ApiClient
{
    public var initialized(default,null):Bool = false;
    public var registry(default,null):GanomedeRegistry;
    public var users(default,null):GanomedeUsers;
    public var invitations(default,null):GanomedeInvitations;
    public var notifications(default,null):GanomedeNotifications;
    public var games(default,null):GanomedeGames;
    public var turngames(default,null):GanomedeTurnGames;
    public var avatars(default,null):GanomedeAvatars;
    public var chats(default,null):GanomedeChats;
    public var virtualcurrency(default,null):GanomedeVirtualCurrency;
    public var statistics(default,null):GanomedeStatistics;
    public var challenges(default,null):GanomedeChallenges;

    public var options(default,null):Dynamic = {}

    // Constructor
    // 
    // params:
    //  - url: root URL to the server
    //  - options.registry.enabled: enable the registry module
    //  - options.games.enabled: enable the games module
    //  - options.games.type: type of games handled by the games module
    //  - options.users.enabled: enable the users module
    //  - options.notifications.enabled: enable the notifications module
    //  - options.invitations.enabled: enable the invitations module
    //  - options.turngames.enabled: enable the turngame module
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
        if (!options.turngames) options.turngames = {};
        if (!options.avatars) options.avatars = {};
        if (!options.chats) options.chats = {};
        if (!options.virtualcurrency) options.virtualcurrency = {};
        if (!options.statistics) options.statistics = {};
        if (!options.challenges) options.challenges = {};

        if (options.registry.enabled)
            registry = new GanomedeRegistry(this, url + "/registry/v1");
        if (options.users.enabled)
            users = new GanomedeUsers(this);
        if (options.notifications.enabled)
            notifications = new GanomedeNotifications(this);
        if (options.invitations.enabled)
            invitations = new GanomedeInvitations(this);
        if (options.games.enabled)
            games = new GanomedeGames(this, options.games.type);
        if (options.turngames.enabled)
            turngames = new GanomedeTurnGames(this);
        if (options.avatars.enabled)
            avatars = new GanomedeAvatars(this);
        if (options.chats.enabled)
            chats = new GanomedeChats(this);
        if (options.virtualcurrency.enabled)
            virtualcurrency = new GanomedeVirtualCurrency(this);
        if (options.statistics.enabled)
            statistics = new GanomedeStatistics(this, options.games.type);
        if (options.challenges.enabled)
            challenges = new GanomedeChallenges(this);
    }

    public function initialize():Promise {
        var a = [];
        if (registry != null) a.push(registry.initialize);
        if (users != null) a.push(users.initialize);
        if (invitations != null) a.push(invitations.initialize);
        if (notifications != null) a.push(notifications.initialize);
        if (games != null) a.push(games.initialize);
        if (turngames != null) a.push(turngames.initialize);
        if (avatars != null) a.push(avatars.initialize);
        if (chats != null) a.push(chats.initialize);
        if (virtualcurrency != null) a.push(virtualcurrency.initialize);
        if (statistics != null) a.push(statistics.initialize);
        if (challenges != null) a.push(challenges.initialize);
        return Parallel.run(a)
        .then(function(outcome:Dynamic):Void {
            initialized = true;
        });
    }
}

// vim: sw=4:ts=4:et:
