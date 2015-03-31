package fovea.ganomede;

import openfl.utils.Object;
import openfl.errors.Error;
import fovea.async.*;
import fovea.net.AjaxError;

@:expose
class GanomedeNotificationsClient extends ApiClient
{
    public static inline var TYPE:String = "notifications/v1";

    public var clientId(default,null):String = null;
    public var token(default,null):String = null;

    public function new(baseUrl:String, token:String) {
        super(baseUrl + "/" + TYPE + "/auth/" + token);
        this.token = token;
        this.clientId = "" + Math.random();
    }

    public var polling:Bool = false;

    public function poll(after:Int):Promise {
        polling = true;
        var uri:String = "/messages";
        if (after >= 0) {
            uri += "?after=" + after;
        }

        return ajax("GET", uri, {
            parse: this.parseArray
        })
        .then(function(outcome:Dynamic):Void {
            outcome.token = this.token;
            outcome.clientId = this.clientId;
            polling = false;
        })
        .error(function(error:Error):Void {
            polling = false;
        });
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
