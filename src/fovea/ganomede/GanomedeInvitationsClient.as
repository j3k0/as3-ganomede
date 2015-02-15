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
        }

        public function addInvitation(invitation:GanomedeInvitation):Promise {
            return ajax("POST", "/invitations", {
                data: {
                    gameId: invitation.gameId,
                    type: invitation.type,
                    to: invitation.to
                }
            }).then(function(result:Object):void {
                if (result.id) {
                    invitation.id = result.id;
                }
            });
        }

        public function listInvitations():Promise {
            var deferred:Deferred = new Deferred();
            deferred.reject(new ApiError("Not implemented")); // TODO
            return deferred;
        }
    }
}
// vim: sw=4:ts=4:et:
