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
            setTimeout(deferred.resolve, 0);
            return deferred;
        }

        setTimeout(function():void {
            var f:Function = fn.shift();
            f()
                .then(function():void {
                    waterfall(fn)
                        .then(deferred.resolve)
                        .error(deferred.reject);
                })
                .error(deferred.reject);
        }, 0);

        return deferred;
    }
}
