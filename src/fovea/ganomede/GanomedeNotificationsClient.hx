package fovea.ganomede;

import openfl.utils.Object;
import openfl.errors.Error;

import fovea.async.*;
import fovea.net.*;

@:expose
class GanomedeNotificationsClient extends AuthenticatedClient
{
    public static inline var TYPE:String = "notifications/v1";

    public function new(baseUrl:String, token:String) {
        super(baseUrl, TYPE, token);
    }

    public var polling:Bool = false;

    public function poll(after:Int):Promise {
        polling = true;
        var uri:String = UrlFormatter.format("/messages", {
            after: (after >= 0 ? after : null)
        });

        return ajax("GET", uri, { parse: this.parseArray })
        .then(pollSuccess)
        .error(pollError);
    }

    public function pollSuccess(outcome:Dynamic):Void {
        outcome.token = this.token;
        outcome.clientId = this.clientId;
        polling = false;
    }

    public function pollError(error:Error):Void {
        polling = false;
    }

    private function parseArray(obj:Object):Object {
        var array:Array<Object> = cast(obj, Array<Object>);
        if (array == null) {
            return obj;
        }
        var i:Int;
        for (i in 0...array.length) {
            array[i] = new GanomedeNotification(array[i]);
        }
        return array;
    }
}

// vim: sw=4:ts=4:et:
