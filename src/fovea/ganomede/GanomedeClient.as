package fovea.ganomede
{
    import fovea.async.*;

    public class GanomedeClient extends ApiClient
    {
        private var _initialized:Boolean = false;
        public function get initialized():Boolean { return _initialized; }

        private var _registry:GanomedeRegistry;
        public function get registry():GanomedeRegistry { return _registry; }

        private var _users:GanomedeUsers;
        public function get users():GanomedeUsers { return _users; }

        private var _invitations:GanomedeInvitations;
        public function get invitations():GanomedeInvitations { return _invitations; }

        public function GanomedeClient(url:String) {
            super(url);
            _registry = new GanomedeRegistry(this, url + "/registry/v1");
            _users = new GanomedeUsers(this);
            _invitations = new GanomedeInvitations(this);
        }

        public function initialize():Promise {
            return when(registry.initialize(), users.initialize(), invitations.initialize())
                .then(function():void {
                    _initialized = true;
                });
        }

        // Shortcut
        public function get me():GanomedeUser { return _users.me; }
    }
}
// vim: sw=4:ts=4:et:
