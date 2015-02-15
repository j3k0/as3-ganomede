package fovea.ganomede
{
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLRequestHeader;
    import flash.events.Event;
    import flash.events.SecurityErrorEvent;
    import flash.events.IOErrorEvent;
    import flash.events.HTTPStatusEvent;
    import flash.events.IEventDispatcher;
    import flash.events.EventDispatcher;
    import fovea.async.Deferred;
    import fovea.async.Promise;

    public class ApiClient extends EventDispatcher
    {
        public var url:String;
        private var _cache:Object = {}; // cache requests result

        public function ApiClient(url:String) {
            this.url = url;
        }

        public function service(type:String):ApiClient {
            return new ApiClient(this.url + "/" + type);
        }

        public function ajax(method:String, path:String, options:Object = undefined):Promise {

            if (!options)
                options = {};

            var deferred:Deferred = new Deferred();

            if (options.cache)
                options.cacheID = method + ":" + path;

            // Prepare the request
            var urlRequest:URLRequest= new URLRequest(this.url + path);
            urlRequest.method = method.toUpperCase();

            if (options.data)
                urlRequest.data = JSON.stringify(options.data);

            var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
            urlRequest.requestHeaders.push(hdr);

            var urlLoader:URLLoader = new URLLoader();
            configureListeners(urlLoader, deferred, options);
            urlLoader.load(urlRequest);

            return deferred;
        }

        private function configureListeners(dispatcher:IEventDispatcher, deferred:Deferred, options:Object):void {

            var status:int = 0;
            var data:Object = null;

            var removeListeners:Function;

            function done():void {
                removeListeners(dispatcher);
                if (status >= 200 && status <= 299) {
                    var obj:Object = {
                        status: status,
                        data: data
                    };
                    if (options.parse)
                        obj.data = options.parse(data);
                    if (options.cacheID)
                        _cache[options.cacheID] = obj;
                    deferred.resolve(obj);
                    return;
                }
                deferred.reject(new ApiError(ApiError.HTTP_ERROR, status, data));
            }

            function complete(event:Event):void {
                // trace("complete: " + event);
                var loader:URLLoader = URLLoader(event.target);
                data = jsonData(loader);
                done();
            }

            function httpStatus(event:HTTPStatusEvent):void {
                // trace("httpStatus: " + event);
                status = event.status;
            }

            /* dispatcher.addEventListener(Event.OPEN, function(event:Event):void {
                trace("openHandler: " + event); });
            dispatcher.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void {
                trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal); }); */

            function securityError(event:SecurityErrorEvent):void {
                //trace("securityErrorHandler: " + event);
                removeListeners(dispatcher);
                deferred.reject(new ApiError(ApiError.SECURITY_ERROR));
            }

            function ioError(event:IOErrorEvent):void {
                // trace("ioErrorHandler: " + event);
                var loader:URLLoader = URLLoader(event.target);
                data = jsonData(loader);
                if (data) {
                    done();
                }
                else {
                    removeListeners(dispatcher);
                    deferred.reject(new ApiError(ApiError.IO_ERROR, status, data));
                }
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

        public function cached(method:String, path:String):Object {
            return _cache[method + ":" + path];
        }

        public function cachedAjax(method:String, path:String, options:Object = undefined):Promise {
            if (!options)
                options = {};
            var obj:Object = cached(method, path);
            if (obj) {
                var deferred:Deferred = new Deferred();
                deferred.resolve(obj);
                ajax(method, path, { cache: true, parse: options.parse });
                return deferred;
            }
            else {
                return ajax(method, path, { cache: true, parse: options.parse });
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
// vim: sw=4:ts=4:et:
