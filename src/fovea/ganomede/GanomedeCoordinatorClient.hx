package fovea.ganomede;

import openfl.utils.Object;
import fovea.async.*;
import fovea.net.AjaxError;

@:expose
class GanomedeCoordinatorClient extends ApiClient
{
    public static inline var TYPE:String = "coordinator/v1";

    public var token(default,null):String = null;

    public function new(baseUrl:String, token:String) {
        super(baseUrl + "/" + TYPE + "/auth/" + token);
        this.token = token;
    }

    public function addGame(game:GanomedeGame):Promise {
        return ajax("POST", game.type + "/games", {
            data: {
                players: game.players
            }
        }).then(function(result:Object):Void {
            if (result.data.id) {
                // game.id = result.data.id;
                game.fromJSON(result.data);
            }
        });
    }

    public function getGame():Promise {
        return ajax("GET", "/game");
    }

    public function activeGames(type:String):Promise {
        return ajax("GET", type + "/active-games");
    }

    public function leaveGame(game:GanomedeGame):Promise {
        return ajax("POST", "/games/" + game.id + "/leave")
        .then(function(result:Object):Void {
            if (result.data.id) {
                game.fromJSON(result.data);
            }
        });
    }

    public function joinGame(game:GanomedeGame):Promise {
        return ajax("POST", "/games/" + game.id + "/join")
        .then(function(result:Object):Void {
            if (result.data.id) {
                game.fromJSON(result.data);
            }
        });
    }

    /* private function parseArray(obj:Object):Object {
        var array:Array<Object> = cast(obj, Array<Object>);
        if (array == null) {
            return obj;
        }
        var i:Int;
        for (i in 0...array.length) {
            array[i] = new GanomedeGame(array[i]);
        }
        return array;
    } */

    /* public function deleteGame(invite:GanomedeGame, reason:String):Promise {
        var deferred:Deferred = new Deferred();
        ajax("DELETE", "/games/" + invite.id, {
            data: {
                reason: reason
            }
        })
        .then(function(result:Object):Void {
            if (!result.data || result.data.ok == true)
                deferred.resolve();
            else
                deferred.reject(new ApiError(AjaxError.HTTP_ERROR, result.status, result.data));
        })
        .error(deferred.reject);
        return deferred;
    } */
}

// vim: sw=4:ts=4:et:

