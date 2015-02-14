package fovea.ganomede
{
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.events.Event;
    import flash.events.SecurityErrorEvent;
    import flash.events.IOErrorEvent;
    import flash.events.HTTPStatusEvent;
    import flash.events.IEventDispatcher;
    import fovea.async.Deferred;
    import fovea.async.Promise;

    public class ApiClient
    {
        public var url:String;

        public function ApiClient(url:String) {
            this.url = url;
        }

        public function service(type:String):ApiClient {
            return new ApiClient(this.url + "/" + type);
        }

        public function ajax(method:String, path:String):Promise {

            var deferred:Deferred = new Deferred();

            // Prepare the request
            var urlRequest:URLRequest= new URLRequest(this.url + path);
            urlRequest.method = method.toUpperCase();

            var urlLoader:URLLoader = new URLLoader();
            configureListeners(urlLoader, deferred);
            urlLoader.load(urlRequest);

            return deferred;
        }

        private function configureListeners(dispatcher:IEventDispatcher, deferred:Deferred):void {

            var status:int = 0;
            var dataLoaded:Boolean = false;
            var data:Object = null;

            var removeListeners:Function;

            function done():void {
                if (status && dataLoaded) {
                    removeListeners(dispatcher);
                    if (status >= 200 && status <= 299) {
                        deferred.resolve({
                            status: status,
                            data: data
                        });
                        return;
                    }
                    deferred.reject(new ApiError(ApiError.HTTP_ERROR, status, data));
                }
            }

            function complete(event:Event):void {
                var loader:URLLoader = URLLoader(event.target);
                data = jsonData(loader);
                dataLoaded = true;
                done();
            }

            function httpStatus(event:HTTPStatusEvent):void {
                // trace("httpStatusHandler: " + event);
                status = event.status;
                done();
            }

            /* dispatcher.addEventListener(Event.OPEN, function(event:Event):void {
                trace("openHandler: " + event); });
            dispatcher.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void {
                trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal); }); */

            function securityError(event:SecurityErrorEvent):void {
                trace("securityErrorHandler: " + event);
                deferred.reject(new ApiError(ApiError.SECURITY_ERROR));
                removeListeners(dispatcher);
            }

            function ioError(event:IOErrorEvent):void {
                trace("ioErrorHandler: " + event);
                deferred.reject(new ApiError(ApiError.IO_ERROR));
                removeListeners(dispatcher);
            }

            dispatcher.addEventListener(Event.COMPLETE, complete);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioError);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);

            removeListeners = function(dispatcher:IEventDispatcher):void {
                dispatcher.removeEventListener(Event.COMPLETE, complete);
                dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
                dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
                dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
            }
        }

        // The JSON data.
        private static function jsonData(urlLoader:URLLoader):Object {
            var json:Object = null;
            try {
                json = JSON.parse(String(urlLoader.data));
            }
            catch (e:Error) {
                trace("JSON parsing Error.");
            }
            return json;
        }
    }
}
