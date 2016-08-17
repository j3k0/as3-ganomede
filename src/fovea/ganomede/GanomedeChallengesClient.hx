package fovea.ganomede;

import openfl.utils.Object;
import fovea.async.*;
import fovea.net.AjaxError;

@:expose
class GanomedeChallengesClient extends AuthenticatedClient
{
    public static inline var TYPE:String = "challenges/v1";

    public function new(baseUrl:String, token:String) {
        super(baseUrl, TYPE, token);
    }

    /* public function addChallenge(challenge:GanomedeChallenge):Promise {
        return ajax("POST", "/challenges", {
            data: {
                gameId: challenge.gameId,
                type: challenge.type,
                to: challenge.to
            }
        }).then(function challengeAdded(result:Object):Void {
            if (result.data.id) {
                challenge.id = result.data.id;
            }
        });
    } */

    public function listChallenges():Promise {
        return ajax("GET", "/challenges");
    }

    public function currentChallenge():Promise {
        return ajax("GET", "/current");
    }

    public function encodeURIComponent(s0:String):String {
        var s1 = StringTools.replace(s0, "/", "%2F");
        var s2 = StringTools.replace(s1, ":", "%3A");
        return s2;
    }

    public function getLeaderboard(challengeId:String):Promise {
        var id = encodeURIComponent(challengeId);
        return ajax("GET", "/challenges/" + id + "/entries");
    }

    public function getUserEntries():Promise {
        return ajax("GET", "/entries");
    }

    public function postUserEntry(challengeId:String, moves:Array<Object>):Promise {
        var id = encodeURIComponent(challengeId);
        return ajax("POST", "/challenges/" + id + "/entries", {
            data: {
                authToken: token,
                moves: moves
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
            array[i] = new GanomedeChallenge(array[i]);
        }
        return array;
    } */

    /* public function deleteChallenge(invite:GanomedeChallenge, reason:String):Promise {
        var deferred:Deferred = new Deferred();
        // ajax("DELETE", "/challenges/" + invite.id, {
        ajax("POST", "/challenges/" + invite.id + "/delete", {
            data: {
                reason: reason
            }
        })
        .then(function challengeDeleted(result:Object):Void {
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
