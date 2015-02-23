package fovea.async;

import haxe.Timer.delay;

/**
 * Calls all functions in the array.
 *
 * Each function is expected to return a Promise.
 *
 * Returns a new Promise which will resolve once all the functions are resolved.
 *
 * If any of the supplied function reject then the returned Promise will also reject.
 */

@:expose
class Waterfall {

    public static function run(fn:Array<Void->Promise>) : Promise
    {
        var deferred:Deferred = new Deferred();

        if (fn.length == 0) {
            deferred.resolve();
            return deferred;
        }

        delay(function onTick():Void {
            var f:Void->Promise = fn.shift();
            f()
                .then(function onResolve(outcome:Dynamic):Void {
                    run(fn)
                        .then(deferred.resolve)
                        .error(deferred.reject);
                })
                .error(deferred.reject);
        }, 0);

        return deferred;
    }

}
// vim: sw=4:ts=4:et:
