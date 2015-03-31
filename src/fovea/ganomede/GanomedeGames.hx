package fovea.ganomede;

import fovea.async.*;
import fovea.utils.Collection;
import openfl.utils.Object;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.events.Event;

@:expose
class GanomedeGames extends ApiClient
{
    public var initialized(default,null):Bool = false;

    private var client:GanomedeClient;
    private var type:String;
    private var coordinatorClient:GanomedeCoordinatorClient = null;

    public var collection(default,never) = new Collection<GanomedeGame>();

    public function asArray() {
        var array = collection.asArray();
        array.sort(function(a:GanomedeGame, b:GanomedeGame):Int {
            return (a.id > b.id) ? 1 : -1;
        });
        return array;
    }

    public function new(client:GanomedeClient, type:String) {
        super(client.url);
        // + "/" + GanomedeCoordinatorClient.TYPE);
        this.type = type;
        this.client = client;
        coordinatorClient = new GanomedeCoordinatorClient(client.url, null);
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
            });
    }

    public function onLoginLogout(event:Event):Void {

        var oldAuthToken:String = null;
        if (coordinatorClient != null) {
            oldAuthToken = coordinatorClient.token;
        }

        var newAuthToken:String = null;
        if (client.users.me != null) {
            newAuthToken = client.users.me.token;
        }

        if (newAuthToken != oldAuthToken) {
            coordinatorClient = new GanomedeCoordinatorClient(client.url, newAuthToken);
            collection.flushall();
            refreshArray();
        }
    }

    public function add(game:GanomedeGame):Promise {
        var token = coordinatorClient.token;

        if (!client.users.me.isAuthenticated()) {
            if (Ajax.verbose) trace("cant add game: not authenticated");
            return error(AjaxError.CLIENT_ERROR);
        }

        return coordinatorClient.addGame(game)
            .then(function(outcome:Dynamic):Void {
                if (token != coordinatorClient.token)
                    return;
                mergeGame(game.toJSON());
                dispatchEvent(new Event(GanomedeEvents.CHANGE));
            });
    }

    public function join(game:GanomedeGame):Promise {
        var token = coordinatorClient.token;
        var deferred:Deferred = new Deferred();
        coordinatorClient.joinGame(game)
        .then(function(outcome:Dynamic):Void {
            if (token != coordinatorClient.token)
                return;
            mergeGame(game.toJSON());
            dispatchEvent(new Event(GanomedeEvents.CHANGE));
            deferred.resolve();
        })
        .error(deferred.reject);
        return deferred;
    }

    public function leave(game:GanomedeGame):Promise {
        var token = coordinatorClient.token;
        var deferred:Deferred = new Deferred();
        coordinatorClient.leaveGame(game)
        .then(function(outcome:Dynamic):Void {
            if (token != coordinatorClient.token)
                return;
            mergeGame(game.toJSON());
            dispatchEvent(new Event(GanomedeEvents.CHANGE));
            deferred.resolve();
        })
        .error(deferred.reject);
        return deferred;
    }

    public function refreshArray():Promise {
        var deferred:Deferred = new Deferred();
        if (coordinatorClient.token != null) {
            var token = coordinatorClient.token;
            coordinatorClient.activeGames(type)
            .then(function(result:Object):Void {
                if (token != coordinatorClient.token)
                    return;
                if (processListGames(result))
                    deferred.resolve();
                else
                    deferred.reject(new ApiError(AjaxError.IO_ERROR));
            })
            .error(deferred.reject);
        }
        else {
            if (Ajax.verbose) trace("Can't load games if not authenticated");
            deferred.reject(new ApiError(AjaxError.CLIENT_ERROR));
        }
        return deferred;
    }

    private function processListGames(result:Object):Bool {
        try {
            var newArray:Array<Object> = cast(result.data,Array<Object>);
            var changed:Bool = false;
            var keys:Array<String> = [];
            for (game in newArray)
                keys.push(game.id);
            collection.keep(keys);
            var i:Int;
            for (i in 0...newArray.length) {
                newArray[i].index = i;
                if (mergeGame(newArray[i]))
                    changed = true;
            }
            if (changed)
                dispatchEvent(new Event(GanomedeEvents.CHANGE));
            return true;
        }
        catch (error:String) {
            return false;
        }
    }

    private function mergeGame(json:Object):Bool {
        var id:String = json.id;
        if (collection.exists(id)) {
            var item:GanomedeGame = collection.get(id);
            if (!item.equals(json)) {
                item.fromJSON(json);
                // the collection should only contain active
                if (json.status != "active") {
                    collection.del(id);
                }
                return true;
            }
            else {
                return false;
            }
        }
        else {
            if (json.status == "active") {
                collection.set(id, new GanomedeGame(json));
                return true;
            }
            else {
                return false;
            }
        }
    }
}

// vim: sw=4:ts=4:et:


