package fovea.utils;

import fovea.async.*;
import fovea.ganomede.helpers.*;
import openfl.errors.Error;

@:expose
class ReadyStatus
{
    public var isReady(default,null):Bool = false;
    public var error(default,null):Error = null;
    private var readyCallbacks = new Array<Deferred>();

    public function reset():Void {
        isReady = false;
        error = null;
        readyCallbacks = new Array<Deferred>();
    }

    public function ready():Promise {
        var deferred:Deferred = new Deferred();
        if (isReady)
            deferred.resolve(null);
        else if (error != null)
            deferred.reject(error);
        else
            readyCallbacks.push(deferred);
        return deferred;
    }
 
    public function setReady():Void {
        isReady = true;
        error = null;
        var a = readyCallbacks;
        readyCallbacks = new Array<Deferred>();
        for (i in 0...a.length)
            a[i].resolve(null);
    }

    public function setError(err:Error):Void {
        error = err;
        isReady = false;
        var a = readyCallbacks;
        readyCallbacks = new Array<Deferred>();
        for (i in 0...a.length)
            a[i].reject(err);
    }
}
// vim: ts=4:sw=4:et:
