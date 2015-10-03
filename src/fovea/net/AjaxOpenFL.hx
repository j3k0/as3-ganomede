package fovea.net;

import openfl.utils.Object;
import fovea.async.Deferred;
import fovea.async.Promise;
import fovea.utils.NativeJSON;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestHeader;
import openfl.net.URLRequestMethod;
import openfl.events.HTTPStatusEvent;
import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.Event;
import fovea.events.Events;
import openfl.errors.Error;
import openfl.utils.Object;

class AjaxOpenFL implements IAjax
{
    public var parent:Ajax;

    public function new(parent:Ajax) {
        this.parent = parent;
    }
    public static function factory(parent:Ajax):IAjax {
        return new AjaxOpenFL(parent);
    }

    private function beforeAjax(options:Object):Void {
        this.parent.beforeAjax(options);
    }
    private function afterAjax(options:Object, obj:Object):Void {
        this.parent.afterAjax(options, obj);
    }
    private function ajaxError(code:String, status:Int = 0, data:Object = null, url:String = null):AjaxError {
        return this.parent.ajaxError(code, status, data, url);
    }
    private function url():String {
        return this.parent.url;
    }

    public function ajax(method:String, path:String, options:Object = null):Promise {

        if (options == null)
            options = {};
        options.method = method;
        options.path = path;

        var deferred:Deferred = new Deferred();

        var requestID:String = StringTools.hex(Math.floor(Math.random() * 0xffff));
        options.requestID = requestID;
        Ajax.dtrace("AJAX[" + requestID + "] " + method + " " + this.url() + path);

        beforeAjax(options);

        // Prepare the request
        var urlRequest:URLRequest= new URLRequest(this.url() + path);
        urlRequest.method = method.toUpperCase();

        if (options.data) {
            urlRequest.data = NativeJSON.stringify(options.data);
            Ajax.dtrace("AJAX[" + requestID + "] data=" + urlRequest.data);
        }

        urlRequest.requestHeaders.push(new URLRequestHeader("Content-type", "application/json"));
        urlRequest.requestHeaders.push(new URLRequestHeader("Accept", "application/json"));

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
                Ajax.connection.dispatchEvent(Ajax.onlineEvent);
                Ajax.dtrace("AJAX[" + options.requestID + "] success[" + status + "]: " + NativeJSON.stringify(data));
                var obj:Object = {
                    status: status,
                    data: data
                };
                afterAjax(options, obj);
                deferred.resolve(obj);
            }
            else {
                Ajax.dtrace("AJAX[" + options.requestID + "] error[" + status + "]: " + NativeJSON.stringify(data));
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
            Ajax.dtrace("AJAX[" + options.requestID + "] status[" + status + "]");
        }

        /* dispatcher.addEventListener(Event.OPEN, function(event:Event):Void {
            trace("openHandler: " + event); });
        dispatcher.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):Void {
            trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal); }); */

        function securityError(event:SecurityErrorEvent):Void {
            //trace("securityErrorHandler: " + event);
            removeListeners(dispatcher);
            deferred.reject(ajaxError(AjaxError.SECURITY_ERROR));
            Ajax.connection.dispatchEvent(Ajax.offlineEvent);
        }

        function ioError(event:IOErrorEvent):Void {
            var loader:URLLoader = cast(event.target, URLLoader);
            data = jsonData(loader);
            if (data) {
                done();
            }
            else {
                Ajax.dtrace("AJAX[" + options.requestID + "] ioErrorHandler: " + event);
                removeListeners(dispatcher);
                deferred.reject(ajaxError(AjaxError.IO_ERROR, status, data));
                if (!options.silentIOError)
                    Ajax.connection.dispatchEvent(Ajax.offlineEvent);
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
            Ajax.dtrace("[AJAX] JSON parsing Error (" + Std.string(e) + ")");
            Ajax.dtrace("[AJAX] data = \"" + urlLoader.data.toString() + "\"");
        }
        return json;
    }
}
// vim: sw=4:ts=4:et:
