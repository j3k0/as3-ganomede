package fovea.ganomede;

import openfl.utils.Object;
import fovea.async.*;
import fovea.net.AjaxError;

@:expose
class GanomedeTurnGameClient extends AuthenticatedClient
{
    public static inline var TYPE:String = "turngame/v1";

    public function new(baseUrl:String, token:String) {
        super(baseUrl, TYPE, token);
    }

    public function getGame(game:GanomedeTurnGame):Promise {
        if (game.id == null) {
            var deferred:Deferred = new Deferred();
            deferred.reject(new ApiError(AjaxError.HTTP_ERROR, 400));
            return deferred;
        }
        return ajax("GET", "/games/" + game.id, {})
        .then(function(result:Object):Void {
            game.fromJSON(result.data);
        });
    }

    public function addGame(game:GanomedeTurnGame):Promise {
        if (game.id == null) {
            var deferred:Deferred = new Deferred();
            deferred.reject(new ApiError(AjaxError.HTTP_ERROR, 400));
            return deferred;
        }
        return ajax("POST", "/games/" + game.id, {
            data: game.toJSON()
        }).then(function(result:Object):Void {
            game.fromJSON(result.data);
        });
    }

    public function addMove(game:GanomedeTurnGame, move:GanomedeTurnMove):Promise {
        if (game.id == null) {
            var deferred:Deferred = new Deferred();
            deferred.reject(new ApiError(AjaxError.HTTP_ERROR, 400));
            return deferred;
        }
        return ajax("POST", "/games/" + game.id + "/moves", {
            data: move.toJSON()
        }).then(function(result:Object):Void {
            game.fromJSON(result.data);
            move.fromJSON(result.data);
        });
    }
}
// vim: sw=4:ts=4:et:
