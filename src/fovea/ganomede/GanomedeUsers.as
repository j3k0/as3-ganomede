package fovea.ganomede
{
    import fovea.async.*;
    import fovea.async.Promise;
    import fovea.async.when;

    public class GanomedeUsers extends ApiClient
    {
        private var _initialized:Boolean = false;
        public function get initialized():Boolean { return _initialized; }

        // current authenticated user
        private var _me:GanomedeUser = new GanomedeUser();
        public function get me():GanomedeUser { return _me; }

        public function GanomedeUsers(url:String) {
            super(url);
        }

        public function initialize():Promise {
            var deferred:Deferred = new Deferred();
            deferred.resolve();
            return deferred
                .then(function():void {
                    _initialized = true;
                });
        }

        public function signUp(user:GanomedeUser):Promise {
            _me = user;
            return ajax("POST", "/accounts", {
                data: user.toJSON(),
                parse: parseMe
            });
        }

        public function login(user:GanomedeUser):Promise {
            _me = user;
            return ajax("POST", "/login", {
                data: {
                    username: user.username,
                    password: user.password
                },
                parse: parseMe
            });
        }

        private function parseMe(obj:Object):Object {
            _me.fromJSON(obj);
            return _me;
        }
    }
}
// vim: sw=4:ts=4:et:
