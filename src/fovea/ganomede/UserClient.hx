package fovea.ganomede;

import fovea.events.Event;
import fovea.async.Promise;
import fovea.async.Deferred;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.utils.Collection;
import fovea.utils.Model;
import openfl.utils.Object;
import openfl.errors.Error;

// An ApiClient that is connected to 1 users.
// Defer internal ajax calls to an AuthenticatedClient
@:expose
class UserClient extends ApiClient
{
    public var initialized(default,null):Bool = false;
    public var client(default,null):GanomedeClient;
    public var authClient(default,null):AuthenticatedClient = null;
    private var clientFactory:String->String->AuthenticatedClient;

    public function new(client:GanomedeClient, clientFactory:String->String->AuthenticatedClient, type:String = null) {
        super(client.url + (type != null ? "/" + type : ""));
        this.client = client;
        this.clientFactory = clientFactory;
        this.authClient = clientFactory(client.url, null);
    }

    public function initialize():Promise {
        var deferred:Deferred = new Deferred();

        client.users.addEventListener(GanomedeEvents.LOGIN, onLoginLogout);
        client.users.addEventListener(GanomedeEvents.LOGOUT, onLoginLogout);
        client.users.addEventListener(GanomedeEvents.AUTH, onLoginLogout);

        deferred.resolve();
        return deferred
            .then(function(outcome:Object):Void {
                initialized = true;
                dispatchEvent(new Event("change:initialize"));
            });
    }

    // Will execute the given method, calling success or error
    // only if the authClient didn't change since.
    public function executeAuth(f:Void->Promise):Promise {
        var cid0:String = getClientID();
        var deferred:Deferred = new Deferred();
        if (!isAuthOK()) return deferred;
        f()
        .then(function(outcome:Object):Void {
            if (cid0 == getClientID() && isAuthOK()) {
                deferred.resolve(outcome);
            }
        })
        .error(function(err:Error):Void {
            if (cid0 == getClientID() && isAuthOK()) {
                deferred.reject(err);
            }
        });
        return deferred;
    }

    public function getToken():String {
        return authClient != null ? authClient.token : null;
    }
    public function getClientID():String {
        return authClient != null ? authClient.clientId : null;
    }
    public function isAuthOK():Bool {
        return getToken() != null && client.users.me.token == getToken();
    }

    private function onLoginLogout(event:Event):Void {

        var oldAuthToken:String = null;
        if (authClient != null) {
            oldAuthToken = authClient.token;
        }

        var newAuthToken:String = null;
        if (client.users.me != null) {
            newAuthToken = client.users.me.token;
        }

        if (newAuthToken != oldAuthToken) {
            if (Ajax.verbose) trace("[UserClient] reset");
            authClient = clientFactory(client.url, newAuthToken);
            dispatchEvent(new Event("reset"));
        }
    }

    public function refreshCollection(collection:Collection, ajaxCall:Void->Promise):Promise {
        var deferred:Deferred = new Deferred();
        if (authClient.token != null) {
            executeAuth(ajaxCall)
            .then(function(result:Object):Void {
                if (collection.canMerge(result)) {
                    collection.merge(result);
                    deferred.resolve();
                }
                else {
                    deferred.reject(new ApiError(AjaxError.IO_ERROR));
                }
            })
            .error(deferred.reject);
        }
        else {
            if (Ajax.verbose) trace("Can't load if not authenticated");
            deferred.reject(new ApiError(AjaxError.CLIENT_ERROR));
        }
        return deferred;
    }
}
