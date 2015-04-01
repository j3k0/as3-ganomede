package fovea.ganomede;

import openfl.utils.Object;
import fovea.async.*;
import fovea.net.AjaxError;

@:expose
class GanomedeInvitationsClient extends AuthenticatedClient
{
    public static inline var TYPE:String = "invitations/v1";

    public function new(baseUrl:String, token:String) {
        super(baseUrl, TYPE, token);
    }

    public function addInvitation(invitation:GanomedeInvitation):Promise {
        return ajax("POST", "/invitations", {
            data: {
                gameId: invitation.gameId,
                type: invitation.type,
                to: invitation.to
            }
        }).then(function(result:Object):Void {
            if (result.data.id) {
                invitation.id = result.data.id;
            }
        });
    }

    public function listInvitations():Promise {
        return ajax("GET", "/invitations");
    }

    /* private function parseArray(obj:Object):Object {
        var array:Array<Object> = cast(obj, Array<Object>);
        if (array == null) {
            return obj;
        }
        var i:Int;
        for (i in 0...array.length) {
            array[i] = new GanomedeInvitation(array[i]);
        }
        return array;
    } */

    public function deleteInvitation(invite:GanomedeInvitation, reason:String):Promise {
        var deferred:Deferred = new Deferred();
        ajax("DELETE", "/invitations/" + invite.id, {
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
    }
}

// vim: sw=4:ts=4:et:
