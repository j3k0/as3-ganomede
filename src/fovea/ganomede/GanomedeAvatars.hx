package fovea.ganomede;

import openfl.utils.Object;
import fovea.async.*;
import fovea.net.AjaxError;

#if flash
import flash.utils.ByteArray;
//import flash.net.FileReference;
import flash.net.URLRequestMethod;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.HTTPStatusEvent;
#end

@:expose
class GanomedeAvatars extends ApiClient
{
    public var initialized(default,null):Bool = false;
    public static inline var TYPE:String = "avatars/v1";
    public var cdnHost:String = null;
    private var client:GanomedeClient;

    public function new(client:GanomedeClient) {
        super(client.url + "/" + TYPE);
        this.client = client;
    }

    public function initialize():Promise {
        return ajax("GET", "/about")
        .then(function(o:Object):Void {
            initialized = true;
            if (o && o.config && o.cdnHost) {
                cdnHost = o.config.cdnHost;
            }
        });
    }

#if flash
    public function post(data:ByteArray):Promise {
        var deferred:Deferred = new Deferred();
        if (client.users == null) {
            deferred.reject(ajaxError(AjaxError.IO_ERROR, 400, { message: "Users module not enabled" }));
            return deferred;
        }
        var token = client.users.me.token;
        var uploadRequest:URLRequest = new URLRequest(url + "/" + TYPE + "/auth/" + token + "/pictures");
        uploadRequest.method = URLRequestMethod.POST;
        uploadRequest.contentType = "multipart/form-data; boundary=--dreaminingOfAWorldWithoutBoundaries";
        uploadRequest.data = data;
        var uploader:URLLoader = new URLLoader();
        var removeListeners:Void->Void = null;
        var status:Int = 0;
        var onComplete = function(event:Event):Void {
            removeListeners();
            var obj:Object = {
                status: status
            };
            deferred.resolve(obj);
        };
        var ioError = function(event:IOErrorEvent):Void {
            removeListeners();
            deferred.reject(ajaxError(AjaxError.IO_ERROR, status));
        };
        var securityError = function(event:SecurityErrorEvent):Void {
            removeListeners();
            deferred.reject(ajaxError(AjaxError.SECURITY_ERROR));
        };
        var httpStatus = function(event:HTTPStatusEvent):Void {
            status = event.status;
        };
        removeListeners = function():Void {
            uploader.removeEventListener(Event.COMPLETE, onComplete);
            uploader.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
            uploader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
            uploader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
        };
        uploader.addEventListener(Event.COMPLETE, onComplete);
        uploader.addEventListener(IOErrorEvent.IO_ERROR, ioError);
        uploader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
        uploader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
        uploader.dataFormat = URLLoaderDataFormat.BINARY;
        uploader.load(uploadRequest);
        return deferred;
    }

    // possible versions:
    //  - original.png
    //  - 256.png
    //  - 128.png
    //  - 64.png
    public function load(username:String, version:String):Promise {
      //return ajax("GET", 
        return null;
    }
#end
}

// vim: sw=4:ts=4:et:
