package fovea.async
{
    import flash.utils.setTimeout;

    /**
     * Calls all functions in the array.
     *
     * Each function is expected to return a Promise.
     *
     * Returns a new Promise which will resolve once all the functions are resolved.
     *
     * If any of the supplied function reject then the returned Promise will also reject.
     */
    public function waterfall(fn:Array) : Promise
    {
        var deferred:Deferred = new Deferred();

        if (fn.length === 0) {
            deferred.resolve();
            return deferred;
        }

        setTimeout(function onTick():void {
            var f:Function = fn.shift();
            f()
                .then(function onResolve():void {
                    waterfall(fn)
                        .then(deferred.resolve)
                        .error(deferred.reject);
                })
                .error(deferred.reject);
        }, 0);

        return deferred;
    }
}
// vim: sw=4:ts=4:et:
