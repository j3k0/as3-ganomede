package fovea.ganomede;

import fovea.async.*;
import fovea.utils.Collection;
import openfl.utils.Object;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.events.Event;
import openfl.errors.Error;

@:expose
class GanomedeNotifications extends ApiClient
{
    public var initialized(default,null):Bool = false;

    private var client:GanomedeClient;
    private var notificationsClient:GanomedeNotificationsClient = null;

    public function new(client:GanomedeClient) {
        super(client.url + "/" + GanomedeNotificationsClient.TYPE);
        this.client = client;
        notificationsClient = new GanomedeNotificationsClient(client.url, null);
    }

    public function listenTo(emiter:String, callback:Event->Void):Void {
        this.on(emiter, callback);
    }
       
    private var lastId:Int = -1;

    private function onPollSuccess(result:Object):Void {
        try {
            // result.state;
            if (Ajax.verbose) trace("[GanomedeNotifications] results for " + result.token);
            var notifications:Array<Object> = cast(result.data, Array<Object>);
            if (notifications == null || result.token != notificationsClient.token) {
                if (Ajax.verbose && result.token != notificationsClient.token)
                    trace("skip");
                poll();
                return;
            }
            for (i in 0...notifications.length) {
                var n:GanomedeNotification = notifications[notifications.length - i - 1];
                if (n.id > lastId)
                    lastId = n.id;
                if (!result.silent)
                    dispatchNotification(n);
            }
        }
        catch (error:String) {
            if (Ajax.verbose) trace("[GanomedeNotifications] ERROR " + error);
        }
        poll();
    }
    private function onPollError(error:Error):Void {
        haxe.Timer.delay(poll, 1000);
    }
    public function poll():Void {
        if (Ajax.verbose) trace("[GanomedeNotifications] poll?");
        if (notificationsClient.token != null && notificationsClient.token == client.users.me.token) {
            if (!notificationsClient.polling) {
                if (Ajax.verbose) trace("[GanomedeNotifications] poll!");
                notificationsClient.poll(lastId)
                    .then(onPollSuccess)
                    .error(onPollError);
            }
        }
    }
    public function silentPoll():Void {
        if (Ajax.verbose) trace("[GanomedeNotifications] silentPoll?");
        if (notificationsClient.token != null && notificationsClient.token == client.users.me.token) {
            if (Ajax.verbose) trace("[GanomedeNotifications] silentPoll!");
            notificationsClient.poll(lastId)
                .then(function(result:Object) {
                    result.silent = true;
                    onPollSuccess(result);
                })
                .error(function(err:Error):Void {
                    haxe.Timer.delay(silentPoll, 1000);
                });
        }
        else {
            haxe.Timer.delay(silentPoll, 1000);
        }
    }

    private function dispatchNotification(n:GanomedeNotification):Void {
        dispatchEvent(new GanomedeNotificationEvent(n));
    }

    public function initialize():Promise {
        var deferred:Deferred = new Deferred();

        client.users.addEventListener(GanomedeEvents.LOGIN, onLoginLogout);
        client.users.addEventListener(GanomedeEvents.LOGOUT, onLoginLogout);
        client.users.addEventListener(GanomedeEvents.AUTH, onLoginLogout);

        deferred.resolve();
        return deferred
            .then(function(outcome:Object):Void {
                initialized = true;

                silentPoll();
                // in case polling stops working...
                var timer = new haxe.Timer(60000);
                timer.run = poll;
            });
    }

    public function onLoginLogout(event:Event):Void {

        var oldAuthToken:String = null;
        if (notificationsClient != null) {
            oldAuthToken = notificationsClient.token;
        }

        var newAuthToken:String = null;
        if (client.users.me != null) {
            newAuthToken = client.users.me.token;
        }

        if (newAuthToken != oldAuthToken) {
            if (Ajax.verbose) trace("[GanomedeNotifications] reset");
            notificationsClient = new GanomedeNotificationsClient(client.url, newAuthToken);
            lastId = -1;
            silentPoll();
        }
    }

    public var apiSecret:String = "";
    public function send(n:GanomedeNotification):Promise {
        var data:Object = n.toJSON();
        data.secret = apiSecret;
        return ajax("POST", "/messages", {
            data: data
        });
    }
}

// vim: sw=4:ts=4:et:
