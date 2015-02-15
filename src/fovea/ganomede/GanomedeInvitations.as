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
                refreshArray();
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

        public function refreshArray():Promise {
            var deferred:Deferred = new Deferred();
            if (_invitationsClient.token) {
                _invitationsClient.listInvitations()
                .then(function(result:Object):void {
                    var newArray:Array = result.data as Array;
                    if (newArray) {
                        var changed:Boolean = false;
                        var i:int;
                        var keys:Array = [];
                        for (i = 0; i < newArray.length; ++i)
                            keys.push(newArray[i].id);
                        _collection.keep(keys);
                        for (i = 0; i < newArray.length; ++i) {
                            newArray[i].index = i;
                            if (mergeInvitation(newArray[i]))
                                changed = true;
                        }
                        if (changed)
                            dispatchEvent(new Event(GanomedeEvents.CHANGE));
                        deferred.resolve();
                    }
                    else {
                        deferred.reject(new ApiError(ApiError.IO_ERROR));
                    }
                })
                .error(deferred.reject);
            }
            else {
                trace("Can't load invitations if not authenticated");
                deferred.reject(new ApiError(ApiError.CLIENT_ERROR));
            }
            return deferred;
        }

        private function mergeInvitation(json:Object):Boolean {
            var id:String = json.id;
            if (_collection.exists(id)) {
                var item:GanomedeInvitation = _collection.get(id);
                if (!item.equals(json)) {
                    item.fromJSON(json);
                    return true;
                }
                else {
                    return false;
                }
            }
            else {
                _collection.set(id, new GanomedeInvitation(json));
                return true;
            }
        }
    }
}
// vim: sw=4:ts=4:et:

