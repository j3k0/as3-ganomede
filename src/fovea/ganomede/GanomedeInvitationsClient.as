package fovea.ganomede
{
    import fovea.async.*;

    public class GanomedeInvitationsClient extends ApiClient
    {
        public static const TYPE:String = "invitations/v1";

        private var _token:String = null;
        public function get token():String { return _token; }

        public function GanomedeInvitationsClient(baseUrl:String, token:String) {
            super(baseUrl + "/" + TYPE + "/auth/" + token);
            _token = token;
        }

        public function addInvitation(invitation:GanomedeInvitation):Promise {
            return ajax("POST", "/invitations", {
                data: {
                    gameId: invitation.gameId,
                    type: invitation.type,
                    to: invitation.to
                }
            }).then(function(result:Object):void {
                if (result.data.id) {
                    invitation.id = result.data.id;
                }
            });
        }

        public function listInvitations():Promise {
            return ajax("GET", "/invitations");
        }

        private function parseArray(obj:Object):Object {
            var array:Array = obj as Array;
            if (array == null) {
                return obj;
            }
            for (var i:int = 0; i < array.length; ++i) {
                array[i] = new GanomedeInvitation(array[i]);
            }
            return array;
        }

        public function deleteInvitation(invite:GanomedeInvitation, reason:String):Promise {
            var deferred:Deferred = new Deferred();
            ajax("DELETE", "/invitations/" + invite.id, {
                data: {
                    reason: reason
                }
            })
            .then(function(result:Object):void {
                if (!result.data || result.data.ok == true)
                    deferred.resolve();
                else
                    deferred.reject(new ApiError(ApiError.HTTP_ERROR, result.status, result.data));
            })
            .error(deferred.reject);
            return deferred;
        }
    }
}
// vim: sw=4:ts=4:et:
