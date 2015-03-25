package fovea.async;

import openfl.errors.Error;

/**
    * A Promise represents the outcome of a process, or action which will be yeilded at an undetermined point. Promises
    * make dealing with asyncronous operations simple by exposing a simple API and hiding away all the event handling
    * and garbage collection boiler plate code.
    *
    * Promises will either resolve, at which point the callback registered to 'then' will be invoked, or
    * rejects, in which case the callbacks registered to 'error' will be invoked.  Promises will only ever transition
    * from PENDING to one of their RESOLVED or REJECTED.  Once a promise has RESOLVED or has been REJECTED, it will
    * not transition to any other state.  Handlers added via 'then' or 'error' after the Promise has RESOLVED or
    * REJECTED will be executed immediatley.
    *
    * The Promise interface makes use the Builder Pattern to allow method chaining; note that callbacks will be invoked
    * in the order they are added.
    *
    * Promises can also, optionally provide information about their progress whilst they are still in a PENDING state
    * by registering callbacks via the `progresses` method.
    *
    * @author Jonny Reeves.
    */
@:expose
interface Promise
{
    /**
        * Register a callback function which will be invoked when this Promise is in a RESOLVED state (ie: completed).
        * The supplied function should expect zero, or one argument (the outcome yeilded by the Deferred process).
        * Note that callbacks registered after the Promise resolves will be executed immediately.  Callbacks will be
        * exectured in the order they are supplied.
        */
    function then(callback : Dynamic->Void) : Promise;

    /**
        * Register a callback function which will be invoked should this Promise be rejected (ie: fail to resolve).
        * The supplied function should expect zero or one argument (an Error object yeilded by the Deferred process).
        * Note that callbacks registered after the Promise is rejected will be executed immediately.  Callbacks will be
        * exectured in the order they are supplied.
        */
    function error(callback : Error->Void) : Promise;

    /**
        * Register a callback which will be executed after all other callbacks have been invoked.  Typically this 
        * is used to destroy or free the client.
        */
    function always(callback : Void->Void) : Promise;

    /**
        * Invert the 'then' and 'error' callback. Useful when you expect something to fail.
        */
    function invert() : Promise;
}
// vim: sw=4:ts=4:et:
