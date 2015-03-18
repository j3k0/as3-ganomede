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
            var notifications:Array<Object> = cast(result.data, Array<Object>);
            if (notifications == null) {
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
            trace("[GanomedeNotifications] ERROR " + error);
        }
        poll();
    }
    private function onPollError(error:Error):Void {
        poll();
    }
    public function poll():Void {
        if (notificationsClient.token != null && notificationsClient.token == client.users.me.token) {
            if (!notificationsClient.polling) {
                notificationsClient.poll(lastId)
                    .then(onPollSuccess)
                    .error(onPollError);
            }
        }
    }
    public function silentPoll():Void {
        notificationsClient.poll(lastId)
            .then(function(result:Object) {
                result.silent = true;
                onPollError(result);
            })
            .error(onPollError);
    }

    private function dispatchNotification(n:GanomedeNotification):Void {
        dispatchEvent(new GanomedeNotificationEvent(n));
    }

    public function initialize():Promise {
        var deferred:Deferred = new Deferred();

        client.users.addEventListener(GanomedeEvents.LOGIN, onLoginLogout);
        client.users.addEventListener(GanomedeEvents.LOGOUT, onLoginLogout);

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
            notificationsClient = new GanomedeNotificationsClient(client.url, newAuthToken);
            poll();
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
