package fovea.ganomede;

import fovea.async.*;

@:expose
class Ganomede
{
    private var pool = new GanomedeClientsPool();
    private var client:GanomedeClient;

    public var initialized(default,null):Bool = false;
    public var registry(default,null):GanomedeRegistry;
    public var users(default,null):GanomedeUsers;
    public var invitations(default,null):GanomedeInvitations;
    public var notifications(default,null):GanomedeNotifications;
    public var games(default,null):GanomedeGames;

    private var url:String;
    private var options:Dynamic;

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
    public function new(url:String, options:Dynamic) {
        this.url = url;
        this.options = options;
    }

    public function initialize():Promise {
        return pool.initializeClient(url, options)
        .then(function(result):Void {
            this.client = result.client;
            this.registry = this.client.registry;
            this.users = this.client.users;
            this.invitations = this.client.invitations;
            this.notifications = this.client.notifications;
            this.games = this.client.games;
            this.initialized = true;
        });
    }

    // Just make sure all classes are exported
    public function _fake():Void {
        var pr:PromiseRunner = null;
        var wf:Waterfall = null;
    }
}
