package fovea.net;

import fovea.async.Deferred;
import fovea.async.Promise;

#if flash

import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestHeader;
import openfl.net.URLRequestMethod;
import openfl.events.HTTPStatusEvent;
import openfl.events.IEventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import haxe.Json;
import openfl.errors.Error;
import openfl.utils.Object;

class Ajax extends EventDispatcher
{
    public static var verbose:Bool = false;
    public var url:String;

    public function new(url:String) {
        super();
        this.url = url;
    }

    private function beforeAjax(options:Object):Void {}
    private function afterAjax(options:Object, obj:Object):Void {}
    private function ajaxError(code:String, status:Int = 0, data:Object = null):AjaxError {
        return new AjaxError(code, status, data);
    }

    public function ajax(method:String, path:String, options:Object = null):Promise {

        if (options == null)
            options = {};

        options.method = method;
        options.path = path;

        var deferred:Deferred = new Deferred();

        var requestID:String = StringTools.hex(Math.floor(Math.random() * 0xffff));
        options.requestID = requestID;
        if (verbose) trace("AJAX[" + requestID + "] " + method + " " + this.url + path);

        beforeAjax(options);

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
                afterAjax(options, obj);
                deferred.resolve(obj);
                return;
            }
            deferred.reject(ajaxError(AjaxError.HTTP_ERROR, status, data));
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
            deferred.reject(ajaxError(AjaxError.SECURITY_ERROR));
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
                deferred.reject(ajaxError(AjaxError.IO_ERROR, status, data));
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

#elseif js

import js.node.http.ClientRequest;
//import lime.events.Event;
//import lime.events.EventDispatcher;

class Ajax extends ClientRequest
{
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
        var urlRequest = new Http(this.url + path);
        urlRequest.async = true;

        if (options.data) {
            var data = Json.stringify(options.data);
            urlRequest.setPostData(data);
            if (verbose) trace("AJAX[" + requestID + "] data=" + data);
        }

        urlRequest.setHeader("Content-type", "application/json");
        configureListeners(urlRequest, deferred, options);
        urlRequest.request(method.toUpperCase() != "GET");

        return deferred;
    }

    private function configureListeners(dispatcher:Http, deferred:Deferred, options:Object):Void {

        var status:Int = 0;
        var data:Object = null;

        var removeListeners:Http->Void = null;

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
                    cache.set(options.cacheID, obj);
                deferred.resolve(obj);
                return;
            }
            deferred.reject(ajaxError(AjaxError.HTTP_ERROR, status, data));
        }

        function complete(event:Event):Void {
            // trace("complete: " + event);
            // var loader:URLLoader = cast(event.target, URLLoader);
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
            deferred.reject(ajaxError(AjaxError.SECURITY_ERROR));
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
                deferred.reject(ajaxError(AjaxError.IO_ERROR, status, data));
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
}

#end

// vim: sw=4:ts=4:et:
