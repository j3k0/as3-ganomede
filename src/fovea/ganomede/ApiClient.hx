package fovea.ganomede;

import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLRequestHeader;
import openfl.events.Event;
import openfl.events.SecurityErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.HTTPStatusEvent;
import openfl.events.IEventDispatcher;
import openfl.events.EventDispatcher;
import openfl.errors.Error;
import haxe.Json;
import fovea.async.Deferred;
import fovea.async.Promise;
import openfl.utils.Object;

class ApiClient extends EventDispatcher
{
    public static var verbose:Bool = false;

    public var url:String;
    private var _cache:Object = {}; // cache requests result

    public function new(url:String) {
        super();
        this.url = url;
    }

    public function service(type:String):ApiClient {
        return new ApiClient(this.url + "/" + type);
    }

    public function ajax(method:String, path:String, options:Object = null):Promise {

        if (options == null)
            options = {};

        var deferred:Deferred = new Deferred();

        var requestID:String = StringTools.hex(Math.floor(Math.random() * 0xffff));
        options.requestID = requestID;
        if (verbose) trace("AJAX[" + requestID + "] " + method + " " + this.url + path);

        if (options.cache) {
            options.cacheID = method + ":" + path;
            if (verbose) trace("AJAX[" + requestID + "]: will cache");
        }

        // Prepare the request
        var urlRequest:URLRequest= new URLRequest(this.url + path);
        urlRequest.method = method.toUpperCase();

        if (options.data) {
            urlRequest.data = Json.stringify(options.data);
            if (verbose) trace("AJAX[" + requestID + "] data=" + urlRequest.data);
        }

        var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
        urlRequest.requestHeaders.push(hdr);

        var urlLoader:URLLoader = new URLLoader();
        configureListeners(urlLoader, deferred, options);
        urlLoader.load(urlRequest);

        return deferred;
    }

    private function configureListeners(dispatcher:IEventDispatcher, deferred:Deferred, options:Object):Void {

        var status:Int = 0;
        var data:Object = null;

        var removeListeners:IEventDispatcher->Void = null;

        function done():Void {
            removeListeners(dispatcher);
            if (verbose) trace("AJAX[" + options.requestID + "] done[" + status + "]: " + Json.stringify(data));

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

        function complete(event:Event):Void {
            // trace("complete: " + event);
            var loader:URLLoader = cast(event.target, URLLoader);
            data = jsonData(loader);
            done();
        }

        function httpStatus(event:HTTPStatusEvent):Void {
            // trace("httpStatus: " + event);
            status = event.status;
        }

        /* dispatcher.addEventListener(Event.OPEN, function(event:Event):Void {
            trace("openHandler: " + event); });
        dispatcher.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):Void {
            trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal); }); */

        function securityError(event:SecurityErrorEvent):Void {
            //trace("securityErrorHandler: " + event);
            removeListeners(dispatcher);
            deferred.reject(new ApiError(ApiError.SECURITY_ERROR));
        }

        function ioError(event:IOErrorEvent):Void {
            // trace("ioErrorHandler: " + event);
            var loader:URLLoader = cast(event.target, URLLoader);
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

        removeListeners = function(dispatcher:IEventDispatcher):Void {
            dispatcher.removeEventListener(Event.COMPLETE, complete);
            dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
            dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
            dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
        }
    }

    public function cached(method:String, path:String):Object {
        return _cache.get(method + ":" + path);
    }

    public function cachedAjax(method:String, path:String, options:Object = null):Promise {
        if (options == null)
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

    // Return a rejected promise with an ApiError
    public function error(code:String, status:Int = 0, data:Object = null):Promise {
        var p:Deferred = new Deferred();
        var e:ApiError = new ApiError(code, status, data);
        p.reject(e);
        return p;
    }

    // The JSON data.
    private static function jsonData(urlLoader:URLLoader):Object {
        var json:Object = null;
        try {
            if (urlLoader.data)
                json = Json.parse(urlLoader.data.toString());
        }
        catch (e:Error) {
            trace("[AJAX] JSON parsing Error.");
        }
        return json;
    }
}

// vim: sw=4:ts=4:et:
