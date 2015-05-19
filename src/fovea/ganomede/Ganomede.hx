package fovea.ganomede;

import fovea.async.*;
import fovea.ganomede.helpers.*;

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
    public var turngames(default,null):GanomedeTurnGamesComposite;

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
    //  - options.turngames.enabled: enable the turngames module
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
            this.turngames = new GanomedeTurnGamesComposite(client, pool);
            this.initialized = true;
            callReady();
        });
    }

    private var readyArray = new Array<Deferred>();
    public function ready():Promise {
        var deferred:Deferred = new Deferred();
        if (this.initialized) {
            deferred.resolve(null);
        }
        else {
            readyArray.push(deferred);
        }
        return deferred;
    }
    private function callReady():Void {
        var a = readyArray;
        readyArray = new Array<Deferred>();
        for (i in 0...a.length) {
            a[i].resolve(null);
        }
    }

    // Just make sure all classes are exported
    public function _fake():Void {
        var pr:PromiseRunner = null;
        var wf:Waterfall = null;
        var tgi:GanomedeTurnGameInvitation = null;
        var tgim:GanomedeTurnGameMover = null;
    }
}
