package fovea.ganomede
{
    import fovea.ganomede.ApiClient;
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
            return when(getServices().then(function(result:Object):void {
                _initialized = true;
                _services = result.data as Array;
            }));
        }

        // Load and cache the list of services from server
        public function getServices():Promise {
            return cachedAjax("GET", "/services", { parse: parseServices });
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
