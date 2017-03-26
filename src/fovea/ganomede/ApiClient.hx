package fovea.ganomede;

import fovea.async.Deferred;
import fovea.async.Promise;
import haxe.ds.StringMap;
import openfl.utils.Object;
import fovea.net.*;

@:expose
class ApiClient extends Ajax
{
    // cache requests result
    private var cache = new StringMap<Object>();
    public function clearCache():Void {
        cache = new StringMap<Object>();
    }

    public function new(url:String) {
        super(url);
    }

    public function service(type:String):ApiClient {
        var separator:String = "/";
        if (this.url.length > 0 && this.url.charAt(this.url.length - 1) == '/')
            separator = "";
        if (type.length > 0 && type.charAt(0) == '/')
            separator = "";
        return new ApiClient(this.url + separator + type);
    }

    public function setCache(method:String, path:String, value:Object):Void {
        var cacheID = method + ":" + path;
        cache.set(cacheID, value);
    }

    public function cached(method:String, path:String):Object {
        var key = method + ":" + path;
        if (cache.exists(key))
            return cache.get(method + ":" + path);
        else
            return null;
    }

    public var pending = new StringMap<Promise>();
    public function setPending(method, path, deferred):Promise {
        var key = method + ":" + path;
        pending.set(key, deferred);
        deferred.always(function():Void {
            pending.remove(key);
        });
        return deferred;
    }
    public function getPending(method, path):Promise {
        var key = method + ":" + path;
        if (pending.exists(key))
            return pending.get(key);
        else
            return null;
    }

    public function cachedAjax(method:String, path:String, options:Object = null):Promise {
        if (options == null)
            options = {};

        var obj:Object = cached(method, path);
        if (obj != null) {
            var deferred:Deferred = new Deferred();
            deferred.resolve(obj);
            //
            // JC: I just commented the ajax call out.
            // I understand this triggers a refresh,
            // so cached metadata don't get outdated too quickly,
            // but then this caching doesn't save any server load...
            // TODO: run it just from time to time
            // (store "lastFetchDate" for each request)
            //
            // ajax(method, path, { cache: true, parse: options.parse });
            return deferred;
        }

        var pending = getPending(method, path);
        if (pending != null) {
            return pending;
        }

        return setPending(
            method, path,
            ajax(method, path, { cache: true, parse: options.parse }));
    }

    // Return a rejected promise with an ApiError
    public function error(code:String, status:Int = 0, data:Object = null):Promise {
        var p:Deferred = new Deferred();
        var e:ApiError = new ApiError(code, status, data);
        p.reject(e);
        return p;
    }

    public override function ajaxError(code:String, status:Int = 0, data:Object = null, url:String = null):AjaxError {
        return new ApiError(code, status, data, url);
    }

    public override function beforeAjax(options:Object):Void {
        if (options.cache) {
            options.cacheID = options.method + ":" + options.path;
            if (Ajax.verbose) trace("AJAX[" + options.requestID + "]: will cache");
        }
    }

    public override function afterAjax(options:Object, obj:Object):Void {
        if (options.parse)
            obj.data = options.parse(obj.data);
        if (options.cacheID)
            cache.set(options.cacheID, obj);
    }

    public function ajaxGetData(path:String):Deferred {
        var deferred:Deferred = new Deferred();
        ajax("GET", path)
        .then(function(outcome:Object):Void {
            if (outcome == null || outcome.data == null) {
                deferred.reject(new ApiError(AjaxError.IO_ERROR));
            }
            else {
                deferred.resolve(outcome.data);
            }
        })
        .error(deferred.reject);
        return deferred;
    }
}

// vim: sw=4:ts=4:et:
