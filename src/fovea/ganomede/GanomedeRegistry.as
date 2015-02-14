package fovea.ganomede
{
    import fovea.ganomede.ApiClient;
    import fovea.async.Deferred;
    import fovea.async.Promise;
    import fovea.async.when;

    public class GanomedeRegistry extends ApiClient
    {
        private var _initialized:Boolean = false;
        public function get initialized():Boolean { return _initialized; }

        private var _services:Array = [];
        public function get services():Array { return _services; }

        public function GanomedeRegistry(url:String) {
            super(url);
        }

        // Load the list of services
        //
        // Beware, initialization may fail if the device isn't online.
        //
        // Call initialize again if you want to try time again.
        public function initialize():Promise {
            return when(
                getServices()
                    .then(storeServices)
                    .then(function():void {
                        _initialized = true;
                    })
            );
        }

        // Load and cache the list of services from server
        public function getServices():Promise {
            return cachedAjax("GET", "/services", { parse: parseServices })
                .then(storeServices);
        }

        // Update the stored list of services
        private function storeServices(result:Object):void {
            if (result.data && result.data.length) {
                _services = result.data as Array;
            }
        }

        // Load and cache the list of services from server
        public function getServicesAsync():Promise {
            var deferred:Deferred = new Deferred();
            ajax("GET", "/services", { parse: parseServices, cache: true })
                .then(storeServices)
                .then(function():void {
                    deferred.resolve(services);
                })
                .error(deferred.reject);
            return deferred;
        }

        // Allocate GanomedeService instance from request data
        private function parseServices(obj:Object):Object {
            var array:Array = obj as Array;
            for (var i:int = 0; i < obj.length; ++i)
                array[i] = new GanomedeService(array[i]);
            return array;
        }
    }
}
// vim: sw=4:ts=4:et:
