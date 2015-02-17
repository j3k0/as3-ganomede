package fovea.ganomede
{
    import fovea.async.*;
    import fovea.async.Promise;
    import fovea.async.when;
    import flash.events.Event;

    public class GanomedeUsers extends ApiClient
    {
        public static const TYPE:String = "users/v1";

        private var _initialized:Boolean = false;
        public function get initialized():Boolean { return _initialized; }

        private var _client:GanomedeClient = null;

        // current authenticated user
        private var _me:GanomedeUser = new GanomedeUser();
        public function get me():GanomedeUser { return _me; }

        public function GanomedeUsers(client:GanomedeClient) {
            super(client.url + "/" + TYPE);
            this._client = client;
        }

        public function initialize():Promise {
            var deferred:Deferred = new Deferred();
            deferred.resolve();
            return deferred
                .then(function():void {
                    _initialized = true;
                    if (me.authenticated) {
                        dispatchLoginEvent(null);
                    }
                });
        }

        private function dispatchLoginEvent(result:Object):void {
            dispatchEvent(new Event(GanomedeEvents.LOGIN));
        }

        public function signUp(user:GanomedeUser):Promise {
            _me = user;
            return ajax("POST", "/accounts", {
                data: user.toJSON(),
                parse: parseMe
            })
            .then(dispatchLoginEvent);
        }

        public function login(user:GanomedeUser):Promise {
            _me = user;
            return ajax("POST", "/login", {
                data: {
                    username: user.username,
                    password: user.password
                },
                parse: parseMe
            })
            .then(dispatchLoginEvent);
        }

        public function fetch(user:GanomedeUser):Promise {
            var deferred:Deferred = new Deferred();
            if ((user.username == me.username) ||
                (user.email == me.username) ||
                (user.username == me.email)) {
                ajax("GET", "/auth/" + me.token + "/me", {
                    parse: parseMe
                })
                .then(function():void {
                    deferred.resolve(user);
                })
                .error(deferred.reject);
            } 
            else {
                deferred.reject(new ApiError(ApiError.IO_ERROR)); // TODO
            }

            return deferred;
        }

        private function parseMe(obj:Object):Object {
            _me.fromJSON(obj);
            return _me;
        }
    }
}
// vim: sw=4:ts=4:et:
