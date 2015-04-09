package fovea.net;

import openfl.utils.Object;
import fovea.async.Deferred;
import fovea.async.Promise;
import fovea.utils.NativeJSON;

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
import fovea.events.Events;
import openfl.errors.Error;
import openfl.utils.Object;

class Ajax extends Events
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
            urlRequest.data = NativeJSON.stringify(options.data);
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
            if (status >= 200 && status <= 299) {
                if (verbose) trace("AJAX[" + options.requestID + "] success[" + status + "]: " + NativeJSON.stringify(data));
                var obj:Object = {
                    status: status,
                    data: data
                };
                afterAjax(options, obj);
                deferred.resolve(obj);
            }
            else {
                if (verbose) trace("AJAX[" + options.requestID + "] error[" + status + "]: " + NativeJSON.stringify(data));
                deferred.reject(ajaxError(AjaxError.HTTP_ERROR, status, data));
            }
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
            if (verbose) trace("AJAX[" + options.requestID + "] status[" + status + "]");
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
            var loader:URLLoader = cast(event.target, URLLoader);
            data = jsonData(loader);
            if (data) {
                done();
            }
            else {
                if (verbose) trace("AJAX[" + options.requestID + "] ioErrorHandler: " + event);
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
    private function jsonData(urlLoader:URLLoader):Object {
        var json:Object = null;
        try {
            if (urlLoader.data) {
                json = NativeJSON.parse(urlLoader.data.toString());
            }
        }
        catch (e:Dynamic) {
            if (verbose) {
                trace("[AJAX] JSON parsing Error (" + Std.string(e) + ")");
            }
        }
        return json;
    }
}

#elseif js

import js.node.http.ClientRequest;
import js.node.Http.HttpClient;
import js.node.Http.HttpReqOpt;
import js.node.Http.HttpClientResp;
import js.node.Http;
import fovea.events.Events;

//import lime.events.Event;
//import lime.events.EventDispatcher;

@:expose
class Ajax extends Events
{
    public static var verbose:Bool = false;

    public var url:String;

    public var protocol:String;
    public var host:String;
    public var port:Int;
    public var path:String;

    public function new(url:String) {

        this.url = url;

        // extract protocol from the url
        this.protocol = url.split(":")[0];

        // extract path from the url
        this.path = "";
        var array = url.split("/");
        for (i in 3...array.length)
            this.path += "/" + array[i];

        // extract host and port
        var hostPort = url.split("/")[2];
        this.host = hostPort.split(":")[0];
        this.port = 80;
        if (this.host != hostPort) {
            this.port = Std.parseInt(hostPort.split(":")[1]);
        }
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

        var data = "";
        if (options.data) {
            data = NativeJSON.stringify(options.data);
        }

        var reqOptions:HttpReqOpt = {
            host: this.host,
            port: this.port,
            path: this.path + "/" + path,
            method: method,
            headers: {
                "Content-type": "application/json",
                'Content-Length': data.length
            }
        };

        // Prepare the request
        var req = Http.request(reqOptions, function(res:HttpClientResp):Void {
            var status = res.statusCode;
            var data = "";
            res.on("data", function(chunk:String):Void {
                data += chunk;
            });
            res.on("end", function():Void {
                if (verbose) trace("AJAX[" + requestID + "] processing request");
                if (status >= 200 && status <= 299) {
                    var json:Dynamic = null;
                    try {
                        if (data != "")
                            json = cast(NativeJSON.parse(data));
                    }
                    catch (err:Dynamic) {
                        trace("[AJAX " + options.requestID + "] JSON parse error (" + data + ")");
                        if (err.stack)
                            trace("[AJAX " + options.requestID + "] " + err.stack);
                        else
                            trace("[AJAX " + options.requestID + "] " + err);
                        deferred.reject(ajaxError(AjaxError.IO_ERROR, AjaxError.IO_ERROR_JSON, data));
                        return;
                    }
                    var obj:Object = {
                        status: status,
                        data: json
                    };
                    if (verbose) trace("AJAX[" + options.requestID + "] done[" + status + "]: " + data);
                    afterAjax(options, obj);
                    deferred.resolve(obj);
                    return;
                }
                deferred.reject(ajaxError(AjaxError.HTTP_ERROR, status, data));
            });
        });

        req.on("error", function(error:Dynamic):Void {
            deferred.reject(ajaxError(AjaxError.IO_ERROR, 0, error.message));
        });

        if (options.data) {
            req.write(data);
            if (verbose) trace("AJAX[" + requestID + "] data=" + data);
        }
        req.end();

        return deferred;
    }
}

#end

// vim: sw=4:ts=4:et:
