package fovea.ganomede;

import fovea.async.*;
import fovea.ganomede.helpers.*;
import fovea.utils.ReadyStatus;

@:expose
class Ganomede
{
    private var pool = new GanomedeClientsPool();
    private var client:GanomedeClient;

    public var status(default,null):ReadyStatus = new ReadyStatus();
    // public var registry(default,null):GanomedeRegistry;
    public var users(default,null):GanomedeUsers;
    public var invitations(default,null):GanomedeInvitations;
    public var notifications(default,null):GanomedeNotifications;
    public var games(default,null):GanomedeGames;
    public var turngames(default,null):GanomedeTurnGamesComposite;
    public var avatars(default,null):GanomedeAvatars;
    public var statistics(default,null):GanomedeStatistics;
    public var challenges(default,null):GanomedeChallenges;
    public var chats(default,null):GanomedeChats;
    public var virtualcurrency(default,null):GanomedeVirtualCurrency;

    public var url(default,null):String;
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
            // this.registry = this.client.registry;
            this.users = this.client.users;
            this.invitations = this.client.invitations;
            this.notifications = this.client.notifications;
            this.games = this.client.games;
            this.turngames = new GanomedeTurnGamesComposite(client, pool);
            this.avatars = this.client.avatars;
            this.chats = this.client.chats;
            this.virtualcurrency = this.client.virtualcurrency;
            this.statistics = this.client.statistics;
            this.challenges = this.client.challenges;
            this.status.setReady();
        });
    }

    // Just make sure all classes are exported
    public function _fake():Void {
        var pr:PromiseRunner = null;
        var wf:Waterfall = null;
        var tgi:GanomedeTurnGameInvitation = null;
        var tgim:GanomedeTurnGameMover = null;
    }

    public function ready():Promise {
        return this.status.ready();
    }
}
// vim: ts=4:sw=4:et:
