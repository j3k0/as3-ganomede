package fovea.ganomede;

import fovea.async.*;
import openfl.utils.Object;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.events.Event;
import fovea.events.Events;

@:expose
class GanomedeStatistics extends ApiClient
{
    public static inline var TYPE:String = "statistics/v1";

    public function new(client:GanomedeClient, gameType:String) {
        super(client.url + "/" + TYPE + "/" + gameType);
    }

    public function initialize():Promise {
        return new Deferred().resolve(null);
    }

    public function getRank(username:String):Promise {
        return ajaxGetData(makePath(username, "rank"));
    }

    public function getLevel(username:String):Promise {
        return ajaxGetData(makePath(username, "level"));
    }

    public static function makePath(username:String, endpoint:String):String {
        return "/" + username + "/" + endpoint;
    }

    public function archive(username:String):Promise {
        return ajaxGetData(makePath(username, "archive"));
    }
}

// vim: sw=4:ts=4:et:

