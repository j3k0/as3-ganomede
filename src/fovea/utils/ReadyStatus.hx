package fovea.utils;

import fovea.async.*;
import fovea.ganomede.helpers.*;

@:expose
class ReadyStatus
{
    public var isReady(default,null):Bool = false;
    private var readyCallbacks = new Array<Deferred>();

    public function reset():Void {
        isReady = false;
        readyCallbacks = new Array<Deferred>();
    }

    public function ready():Promise {
        var deferred:Deferred = new Deferred();
        if (this.isReady)
            deferred.resolve(null);
        else
            readyCallbacks.push(deferred);
        return deferred;
    }
 
    public function setReady():Void {
        this.isReady = true;
        var a = readyCallbacks;
        readyCallbacks = new Array<Deferred>();
        for (i in 0...a.length)
            a[i].resolve(null);
    }
}
// vim: ts=4:sw=4:et:
