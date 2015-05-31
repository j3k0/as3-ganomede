package fovea.ganomede;

import openfl.utils.Object;
import fovea.async.*;
import fovea.net.AjaxError;
import fovea.net.Ajax;

#if flash
import flash.utils.ByteArray;
//import flash.net.URLRequestMethod;
//import flash.net.URLLoaderDataFormat;
//import flash.net.URLRequest;
//import flash.net.URLLoader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.HTTPStatusEvent;

import fovea.net.MultipartURLLoader;
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

        var multipart = new MultipartURLLoader();
        multipart.addFile(data, 'original.png', 'original', 'image/png');
        var endpoint = url + "/auth/" + token + "/pictures";

        var removeListeners:Void->Void = null;
        var status:Int = 0;
        var onComplete = function(event:Event):Void {
            if (Ajax.verbose) trace("[AVATARS] Complete (" + status + ")");
            removeListeners();
            var obj:Object = {
                status: status,
                url: my("original.png")
            };
            dispatchEvent(new Event(GanomedeEvents.CHANGE));
            deferred.resolve(obj);
        };
        var ioError = function(event:IOErrorEvent):Void {
            if (Ajax.verbose) trace("[AVATARS] ioError " + event);
            removeListeners();
            deferred.reject(ajaxError(AjaxError.IO_ERROR, status));
        };
        var securityError = function(event:SecurityErrorEvent):Void {
            if (Ajax.verbose) trace("[AVATARS] securityError " + event);
            removeListeners();
            deferred.reject(ajaxError(AjaxError.SECURITY_ERROR));
        };
        var httpStatus = function(event:HTTPStatusEvent):Void {
            status = event.status;
        };

        removeListeners = function():Void {
            multipart.removeEventListener(Event.COMPLETE, onComplete);
            multipart.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
            multipart.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
            multipart.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
        };
        multipart.addEventListener(Event.COMPLETE, onComplete);
        multipart.addEventListener(IOErrorEvent.IO_ERROR, ioError);
        multipart.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
        multipart.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);

        multipart.load(endpoint);
        return deferred;
    }

    // possible versions:
    //  - original.png
    //  - 256.png
    //  - 128.png
    //  - 64.png
#end

    public function user(username:String, version:String):String {
        if (cdnHost != null)
            return "http://" + cdnHost + "/" + TYPE + "/" + username + "/" + version;
        else
            return url + "/" + username + "/" + version;
    }

    public function my(version:String):String {
        var username = client.users.me.username;
        return url + "/" + username + "/" + version + "?r=" + Math.random();
    }
}

// vim: sw=4:ts=4:et:
