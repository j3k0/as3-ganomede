package fovea.ganomede
{
    import fovea.async.*;
    import flash.events.Event;
    import fovea.utils.Collection;

    public class GanomedeInvitations extends ApiClient
    {
        private var _initialized:Boolean = false;
        public function get initialized():Boolean { return _initialized; }

        private var _client:GanomedeClient;
        private var _invitationsClient:GanomedeInvitationsClient;

        private var _collection:Collection = new Collection();
        public function get array():Array {
            return _collection.asArray().sortOn("index", Array.NUMERIC);
        }

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
                _collection.flushall();
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
                    mergeInvitation(invitation.toJSON());
                    dispatchEvent(new Event(GanomedeEvents.CHANGE));
                });
        }

        private var _isRefreshing:Boolean = false;
        private function refreshArray():void {
            if (_isRefreshing) return;
            if (_invitationsClient.token) {
                _isRefreshing = true;
                _invitationsClient.listInvitations()
                    .then(function(result:Object):void {
                        var newArray:Array = result.data as Array;
                        if (newArray) {
                            for (var i:int = 0; i < newArray.length; ++i) {
                                newArray[i].index = i;
                                mergeInvitation(newArray[i]);
                            }
                            dispatchEvent(new Event(GanomedeEvents.CHANGE));
                        }
                    })
                    .always(function():void {
                        _isRefreshing = false;
                    });
            }
        }

        private function mergeInvitation(json:Object):void {
            var id:String = json.id;
            if (_collection.exists(id)) {
                var item:GanomedeInvitation = _collection.get(id);
                item.fromJSON(json);
            }
            else {
                _collection.set(id, json);
            }
        }
    }
}
// vim: sw=4:ts=4:et:

