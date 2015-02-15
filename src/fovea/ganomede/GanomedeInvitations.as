package fovea.ganomede
{
    import fovea.async.*;
    import flash.events.Event;

    public class GanomedeInvitations extends ApiClient
    {
        private var _initialized:Boolean = false;
        public function get initialized():Boolean { return _initialized; }

        private var _client:GanomedeClient;
        private var _invitationsClient:GanomedeInvitationsClient;

        private var _array:Array = [];
        public function get array():Array { return _array; }

        public function GanomedeInvitations(client:GanomedeClient) {
            super(client.url + "/" + GanomedeInvitationsClient.TYPE);
            _client = client;
            _invitationsClient = new GanomedeInvitationsClient(client.url, null);
        }

        public function initialize():Promise {
            var deferred:Deferred = new Deferred();

           _client.users.addEventListener(GanomedeEvents.LOGIN, onLoginLogout);
           _client.users.addEventListener(GanomedeEvents.LOGOUT, onLoginLogout);

            deferred.resolve();
            return deferred
                .then(function():void {
                    _initialized = true;
                });
        }

        public function onLoginLogout(event:Event):void {

            var oldAuthToken:String = null;
            if (_invitationsClient) oldAuthToken = _invitationsClient.token;

            var newAuthToken:String = null;
            if (_client.me) newAuthToken = _client.me.token;

            if (newAuthToken != oldAuthToken) {
                _invitationsClient = new GanomedeInvitationsClient(_client.url, newAuthToken);
                _array = [];
            }
        }

        public function add(invitation:GanomedeInvitation):Promise {
            if (!_client.me.authenticated) {
                trace("cant add invitation: not authenticated");
                return error(ApiError.CLIENT_ERROR);
            }
            invitation.from = _client.me.username;

            return _invitationsClient.addInvitation(invitation)
                .then(function():void {
                    _array.unshift(invitation);
                    dispatchEvent(new Event(GanomedeEvents.CHANGE));
                });
        }

        private function refreshArray():void {
            if (_invitationsClient.token) {
                _invitationsClient.listInvitations()
                    .then(function(result:Object):void {
                        if (result.data as Array)
                            _array = result.data;
                    });
            }
        }
    }
}
// vim: sw=4:ts=4:et:

