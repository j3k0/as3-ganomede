package fovea.ganomede
{
    import fovea.async.*;
    import fovea.async.Promise;
    import fovea.async.when;

    public class GanomedeInvitations extends ApiClient
    {
        private var _initialized:Boolean = false;
        public function get initialized():Boolean { return _initialized; }

        public var _client:GanomedeClient = null;

        public function GanomedeInvitations(client:GanomedeClient, url:String) {
            super(url);
            _client = client;
        }

        public function initialize():Promise {
            var deferred:Deferred = new Deferred();
            deferred.resolve();
            return deferred
                .then(function():void {
                    _initialized = true;
                });
        }

        public function createInvitation():Promise {
            var deferred:Deferred = new Deferred();
            deferred.reject(new ApiError("Not implemented")); // TODO
            return deferred;
        }

        public function listInvitations():Promise {
            var deferred:Deferred = new Deferred();
            deferred.reject(new ApiError("Not implemented")); // TODO
            return deferred;
        }
    }
}
// vim: sw=4:ts=4:et:

