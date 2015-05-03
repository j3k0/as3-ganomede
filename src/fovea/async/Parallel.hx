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
class Parallel
{
    public static function run(fn:Array<Void->Promise>) : Promise
    {
        var deferred:Deferred = new Deferred();

        if (fn.length == 0) {
            deferred.resolve();
            return deferred;
        }

        delay(function onTick():Void {
            var nCalls:Int = 0;
            function done(outcome:Dynamic):Void {
                nCalls += 1;
                if (nCalls == 2)
                    deferred.resolve();
            }

            var f:Void->Promise = fn.shift();
            f().then(done).error(deferred.reject);
            run(fn).then(done).error(deferred.reject);
        }, 0);

        return deferred;
    }

    public static function runWithArgs(args:Array<Dynamic>, fn:Dynamic->Promise) : Promise {
        var deferred:Deferred = new Deferred();

        if (args.length == 0) {
            deferred.resolve();
            return deferred;
        }

        delay(function onTick():Void {
            var nCalls:Int = 0;
            function done(outcome:Dynamic):Void {
                nCalls += 1;
                if (nCalls == 2)
                    deferred.resolve();
            }

            var a:Dynamic = args.shift();
            fn(a).then(done).error(deferred.reject);
            runWithArgs(args, fn).then(done).error(deferred.reject);
        }, 0);

        return deferred;
    }
}
// vim: sw=4:ts=4:et:
