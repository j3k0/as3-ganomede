package fovea.ganomede
{
    import fovea.ganomede.ApiClient;

    public class GanomedeClient extends ApiClient
    {
        private var _registry:GanomedeRegistry;

        public function GanomedeClient(url:String) {
            super(url);
            _registry = new GanomedeRegistry(url + "/registry/v1");
        }

        public function get registry():GanomedeRegistry { return _registry; }
    }
}
// vim: sw=4:ts=4:et:
