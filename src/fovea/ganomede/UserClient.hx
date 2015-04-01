package fovea.ganomede;

import fovea.events.Event;
import fovea.async.Promise;
import fovea.async.Deferred;
import fovea.net.Ajax;
import openfl.utils.Object;

// An ApiClient that is connected to 1 users.
// Defer internal ajax calls to an AuthenticatedClient
@:expose
class UserClient extends ApiClient
{
    public var initialized(default,null):Bool = false;
    public var client(default,null):GanomedeClient;
    public var ajaxClient(default,null):AuthenticatedClient = null;
    private var clientFactory:String->String->AuthenticatedClient;

    public function new(client:GanomedeClient, clientFactory:String->String->AuthenticatedClient, type:String) {
        super(client.url + "/" + type);
        this.client = client;
        this.clientFactory = clientFactory;
        this.ajaxClient = clientFactory(client.url, null);
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

    public function onLoginLogout(event:Event):Void {

        var oldAuthToken:String = null;
        if (ajaxClient != null) {
            oldAuthToken = ajaxClient.token;
        }

        var newAuthToken:String = null;
        if (client.users.me != null) {
            newAuthToken = client.users.me.token;
        }

        if (newAuthToken != oldAuthToken) {
            if (Ajax.verbose) trace("[UserClient] reset");
            ajaxClient = clientFactory(client.url, newAuthToken);
            dispatchEvent(new Event("reset"));
        }
    }

}
