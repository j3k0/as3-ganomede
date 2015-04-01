package fovea.ganomede;

import fovea.async.*;
import fovea.events.Event;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.utils.Collection;
import openfl.errors.Error;
import openfl.utils.Object;

@:expose
class GanomedeNotifications extends UserClient
{
    public function new(client:GanomedeClient) {
        super(client, notificationsClientFactory, GanomedeNotificationsClient.TYPE);
        addEventListener("change:initialize", onInitialize);
        addEventListener("reset", onReset);
    }

    public function notificationsClientFactory(url:String, token:String):AuthenticatedClient {
        return new GanomedeNotificationsClient(url, token);
    }

    public function listenTo(emiter:String, callback:Event->Void):Void {
        this.on(emiter, callback);
    }
       
    private var lastId:Int = -1;
    private function onPollSuccess(result:Object):Void {
        try {
            // result.state;
            var notifClient:GanomedeNotificationsClient = cast authClient;
            var notifications:Array<Object> = cast(result.data, Array<Object>);
            if (Ajax.verbose) trace("[GanomedeNotifications] results for " + result.token);
            if (notifications == null || result.token != notifClient.token || result.clientId != notifClient.clientId) {
                if (Ajax.verbose && notifications != null )
                    trace("skip");
                haxe.Timer.delay(poll, 100);
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
        haxe.Timer.delay(poll, 100);
    }
    private function onPollError(error:Error):Void {
        haxe.Timer.delay(poll, 1000);
    }
    public function poll():Void {
        if (Ajax.verbose) trace("[GanomedeNotifications] poll?");
        var notifClient:GanomedeNotificationsClient = cast authClient;
        if (!notifClient.polling) {
            if (Ajax.verbose) trace("[GanomedeNotifications] poll!");
            executeAuth(function():Promise {
                return notifClient.poll(lastId);
            })
            .then(onPollSuccess)
            .error(onPollError);
        }
    }
    public function silentPoll():Void {
        var notifClient:GanomedeNotificationsClient = cast authClient;
        if (Ajax.verbose) trace("[GanomedeNotifications] silentPoll?");
        if (isAuthOK()) {
            if (Ajax.verbose) trace("[GanomedeNotifications] silentPoll!");
            executeAuth(function():Promise {
                return notifClient.poll(lastId);
            })
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

    private function onInitialize(event:Event):Void {
        silentPoll();
        // in case polling stops working...
        var timer = new haxe.Timer(60000);
        timer.run = poll;
    }

    private function onReset(event:Event):Void {
        lastId = -1;
        silentPoll();
    }

    private function dispatchNotification(n:GanomedeNotification):Void {
        dispatchEvent(new GanomedeNotificationEvent(n));
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
