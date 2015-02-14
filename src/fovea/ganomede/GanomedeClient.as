package fovea.ganomede
{
    import fovea.ganomede.ApiClient;
    import fovea.async.*;

    public class GanomedeClient extends ApiClient
    {
        private var _initialized:Boolean = false;
        public function get initialized():Boolean { return _initialized; }

        private var _registry:GanomedeRegistry;
        public function get registry():GanomedeRegistry { return _registry; }

        private var _users:GanomedeUsers;
        public function get users():GanomedeUsers { return _users; }

        public function GanomedeClient(url:String) {
            super(url);
            _registry = new GanomedeRegistry(url + "/registry/v1");
            _users = new GanomedeUsers(url + "/users/v1");
        }

        public function initialize():Promise {
            return when(registry.initialize())
                .then(function():void {
                    _initialized = true;
                });
        }
    }
}
// vim: sw=4:ts=4:et:
