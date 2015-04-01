package fovea.ganomede;

import fovea.async.*;
import fovea.utils.Collection;
import openfl.utils.Object;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.events.Event;

@:expose
class GanomedeGames extends UserClient
{
    private var type:String;
    public var collection(default,never) = new Collection<GanomedeGame>();
    public function asArray() {
        var array = collection.asArray();
        array.sort(function(a:GanomedeGame, b:GanomedeGame):Int {
            return (a.id > b.id) ? 1 : -1;
        });
        return array;
    }

    public function new(client:GanomedeClient, type:String) {
        super(client, coordinatorClientFactory);
        this.collection.keepStrategy = function(game:GanomedeGame):Bool {
            return game.status == "active";
        };
        this.collection.modelFactory = function(json:Object):GanomedeGame {
            return new GanomedeGame(json);
        };
        this.type = type;
        addEventListener("reset", onReset);
    }

    private function coordinatorClientFactory(url:String, token:String):AuthenticatedClient {
        return new GanomedeCoordinatorClient(url, token);
    }

    public function onReset(event:Event):Void {
        collection.flushall();
        refreshArray();
    }

    public function add(game:GanomedeGame):Promise {
        if (!client.users.me.isAuthenticated()) {
            if (Ajax.verbose) trace("cant add game: not authenticated");
            return error(AjaxError.CLIENT_ERROR);
        }

        return executeAuth(function():Promise {
            return cast(authClient, GanomedeCoordinatorClient).addGame(game);
        })
        .then(function(outcome:Dynamic):Void {
            collection.merge(game.toJSON());
            dispatchEvent(new Event(GanomedeEvents.CHANGE));
        });
    }

    public function join(game:GanomedeGame):Promise {
        return executeAuth(function():Promise {
            return cast(authClient, GanomedeCoordinatorClient).joinGame(game);
        })
        .then(function(outcome:Dynamic):Void {
            collection.merge(game.toJSON());
            dispatchEvent(new Event(GanomedeEvents.CHANGE));
        });
    }

    public function leave(game:GanomedeGame):Promise {
        return executeAuth(function():Promise {
            return cast(authClient, GanomedeCoordinatorClient).leaveGame(game);
        })
        .then(function(outcome:Dynamic):Void {
            collection.merge(game.toJSON());
            dispatchEvent(new Event(GanomedeEvents.CHANGE));
        });
    }

    public function refreshArray():Promise {
        var deferred:Deferred = new Deferred();
        if (authClient.token != null) {
            executeAuth(function():Promise {
                return cast(authClient, GanomedeCoordinatorClient).activeGames(type);
            })
            .then(function(result:Object):Void {
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
                if (collection.merge(newArray[i]))
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

    /*
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
    */
}

// vim: sw=4:ts=4:et:


