package fovea.async;

import haxe.ds.Vector;
import openfl.errors.Error;

/**
 * A Deferred object provides the means to fulfil a Promise by the means of calling 'resolve', 'reject' and
 * 'progress'.  Typlically a Deferred object is instantiated and retained by a client so that when the operation
 * then, rejects, or progresses, the appropriate methods can be invoked.  The client can invoke 'abort' if
 * the Deferred operation needs to be terminated (in which case none of the callback will be invoked.)
 *
 * A Deferred object uses a finite state machine to ensure that it can only transition from PENDING to one of
 * either RESOLVED or REJECTED to ensure that the Promise gets resolved in a predicable fashion.
 *
 * @author Jonny Reeves.
 */
@:expose
class Deferred implements Promise
{
    private static inline var PENDING:Int = 0;
    private static inline var RESOLVED:Int = 1;
    private static inline var REJECTED:Int  = 2;
    private static inline var ABORTED:Int = 3;

    private var _completeListeners = new Array<Dynamic->Void>();
    private var _failListeners = new Array<Error->Void>();

    private var _finalCallback:Void->Void;
    private var _state:Int = PENDING;
    private var _outcome:Dynamic;

    /**
     * Notifies all 'then' handlers that the deferred operation was succesful.  An optional outcome object
     * can be supplied which will provided to all the then handlers.
     *
     * @parm outcome    The optional result of the Deferred operation.
     */
    public function resolve(outcome:Dynamic = null):Deferred
    {
        if (_state != PENDING) {
            return this;
        }

        _outcome = outcome;
        _state = RESOLVED;

        for (i in 0..._completeListeners.length) {
            _completeListeners[i](_outcome);
        }

        clearListeners();
        invokeFinalCallback();
        return this;
    }

    /**
     * Notifies all 'error' handlers that this deferred operation has been unsuccesful.  The supplied Error object
     * will be supplied to all of the handlers.
     *
     * @param error     Error object which explains how or why the operation was unsuccesful.
     */
    public function reject(error:Error) : Deferred
    {
        if (_state != PENDING) {
            return this;
        }

        // By contact, we will always supply an Error object to the fail handlers.
        _outcome = error != null ? error : new Error("Promise Rejected");
        _state = REJECTED;

        for (i in 0..._failListeners.length) {
            _failListeners[i](_outcome);
        }

        clearListeners();
        invokeFinalCallback();
        return this;
    }

    /**
     * Aborts the deferred operation; none of the handlers bound to the Promise will be invoked; typically this
     * is used when the Deferred's host needs to cancel the operation.
     */
    public function abort() : Void
    {
        _state = ABORTED;
        _outcome = null;
        _finalCallback = null;

        clearListeners();
    }

    public function then(callback:Dynamic->Void) : Promise
    {
        if (_state == PENDING) {
            _completeListeners.push(callback);
        }
        else if (_state == RESOLVED) {
            callback(_outcome);
        }

        return this;
    }

    public function error(callback:Error->Void) : Promise
    {
        if (_state == PENDING) {
            _failListeners.push(callback);
        }
        else if (_state == REJECTED) {
            callback(_outcome);
        }

        return this;
    }

    public function always(callback:Void->Void) : Promise
    {
        if (_state == PENDING) {
            _finalCallback = callback;
        }
        else {
            callback();
        }
        return this;
    }

    private function clearListeners() : Void
    {
        while (_completeListeners.length > 0)
            _completeListeners.pop();
        while (_failListeners.length > 0)
            _failListeners.pop();
    }

    private function invokeFinalCallback() : Void
    {
        if (_finalCallback != null) {
            _finalCallback();
            _finalCallback = null;
        }
    }

    public function invert() : Promise
    {
        var deferred:Deferred = new Deferred();
        then(deferred.reject).error(deferred.resolve);
        return deferred;
    }
}
// vim: sw=4:ts=4:et:
