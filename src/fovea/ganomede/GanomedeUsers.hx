package fovea.ganomede;

import fovea.async.*;
import fovea.events.Event;
import openfl.utils.Object;
import fovea.net.AjaxError;

@:expose
class GanomedeUsers extends ApiClient
{
    public static inline var TYPE:String = "users/v1";

    public var initialized(default,null):Bool = false;
    private var client:GanomedeClient = null;
    // current authenticated user
    public var me(default,null):GanomedeUser = new GanomedeUser();

    public function new(client:GanomedeClient) {
        super(client.url + "/" + TYPE);
        this.client = client;
    }

    public function initialize():Promise {
        var deferred:Deferred = new Deferred();
        deferred.resolve();
        return deferred.then(function(obj:Object):Void {
                initialized = true;
                if (me.isAuthenticated()) {
                    dispatchLoginEvent(null);
                }
            });
    }

    private function dispatchLoginEvent(result:Object):Void {
        dispatchEvent(new Event(GanomedeEvents.LOGIN));
    }

    public function signUp(user:GanomedeUser):Promise {
        me = user;
        return ajax("POST", "/accounts", {
            data: user.toJSON(),
            parse: parseMe
        })
        .then(dispatchLoginEvent);
    }

    public function login(user:GanomedeUser):Promise {
        me = user;
        return ajax("POST", "/login", {
            data: {
                username: user.username,
                password: user.password
            },
            parse: parseMe
        })
        .then(dispatchLoginEvent);
    }

    public function logout() {
        me = new GanomedeUser();
        dispatchEvent(new Event(GanomedeEvents.LOGOUT));
    }

    public function fetch(user:GanomedeUser):Promise {
        var deferred:Deferred = new Deferred();
        if ((user.username == me.username) ||
            (user.email == me.username) ||
            (user.username == me.email)) {
            ajax("GET", "/auth/" + me.token + "/me", {
                parse: parseMe
            })
            .then(function(outcome:Object):Void {
                deferred.resolve(user);
            })
            .error(deferred.reject);
        } 
        else {
            deferred.reject(new ApiError(AjaxError.IO_ERROR)); // TODO
        }

        return deferred;
    }

    // Retrieve metadata for a user, cache the result.
    // Note, saving metadata have to update the cache, or this will fail miserably!
    public function loadUserMetadata(username:String, key:String):Promise {
        var deferred:Deferred = new Deferred();
        var endpoint:String = "/" + username + "/metadata/" + key;
        var obj:Object = cached("GET", endpoint);
        if (obj) {
            deferred.resolve(obj.data);
        }
        else {
            cachedAjax("GET", endpoint)
            .then(function(obj:Object):Void {
                deferred.resolve(obj.data);
            })
            .error(deferred.reject);
        }
        return deferred;
    }

    // Load some metadata for the current user
    public function loadMetadata(key:String):Promise {
        return loadUserMetadata(me.username, key);
    }

    // Save metadata for the current user
    public function saveMetadata(key:String, value:String):Promise {
        var endpoint:String = "/auth/" + me.token + "/metadata/" + key;
        var data:Object = { value: value };
        return ajax("POST", endpoint, {
            data: data
        })
        .then(function(outcome:Object):Void {
            // Update the GET cache...
            var endpoint:String = "/" + me.username + "/metadata/" + key;
            setCache("GET", endpoint, {
                status: 200,
                data: data
            });
        });
    }

    private function parseMe(obj:Object):Object {
        var oldToken:String = me.token;
        var oldUsername:String = me.username;
        me.fromJSON(obj);
        if (me.token != oldToken || me.username != oldUsername) {
            dispatchEvent(new Event(GanomedeEvents.AUTH));
        }
        return me;
    }
}

// vim: sw=4:ts=4:et:
