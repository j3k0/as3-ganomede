package fovea.ganomede
{
    import fovea.async.*;
    import flash.events.Event;

    public class GanomedeInvitations
    {
        private var _initialized:Boolean = false;
        public function get initialized():Boolean { return _initialized; }

        private var _client:GanomedeClient;
        private var _invitationsClient:GanomedeInvitationsClient;

        public function GanomedeInvitations(client:GanomedeClient) {
            _client = client;
            _invitationsClient = new GanomedeInvitationsClient(client.url, null);
        }

        public function initialize():Promise {
            var deferred:Deferred = new Deferred();

           _client.addEventListener(GanomedeEvents.LOGIN, onLoginLogout);
           _client.addEventListener(GanomedeEvents.LOGOUT, onLoginLogout);

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

            if (newAuthToken != oldAuthToken)
                _invitationsClient = new GanomedeInvitationsClient(_client.url, newAuthToken);
        }

        private var _array:Array = [];

        public function error(code:String, status:int = 0, data:Object = null):Promise {
            var p:Deferred = new Deferred();
            var e:ApiError = new ApiError(code, status, data);
            p.reject(e);
            return p;
        }

        public function add(invitation:GanomedeInvitation):Promise {
            if (!_client.me.authenticated)
                return error(ApiError.CLIENT_ERROR);
            if (invitation.from != _client.me.username)
                return error(ApiError.CLIENT_ERROR);

            return _invitationsClient.addInvitation(invitation)
                .then(function():void {
                    _array.unshift(invitation);
                });
        }

        public function asArray():Array {
            return _array;
        }


    }
}
// vim: sw=4:ts=4:et:

