package fovea.ganomede
{
    import fovea.ganomede.ApiClient;
    import fovea.async.Promise;
    import fovea.async.when;

    public class GanomedeRegistry extends ApiClient
    {
        public function GanomedeRegistry(url:String) {
            super(url);
        }

        public function initialize():Promise {
            return when(getServices());
        }

        public function getServices():Promise {
            return cachedAjax("GET", "/services");
        }
    }
}
// vim: sw=4:ts=4:et:
