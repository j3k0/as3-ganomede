package fovea.ganomede;

import fovea.async.*;
import fovea.events.Event;
import fovea.events.Events;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.utils.Collection;
import fovea.utils.Model;
import openfl.errors.Error;
import openfl.utils.Object;

@:expose
class GanomedeTurnGames extends UserClient
{
    public var collection(default,never) = new Collection();
    /*public function asArray():Array<GanomedeTurnGame> {
        var array = collection.asArray();
        array.sort(function(a:Model, b:Model):Int {
            return cast(a, GanomedeTurnGame).index - cast(b, GanomedeTurnGame).index;
        });
        return cast array;
    }*/
    public function toJSON():Object {
        return collection.toJSON();
    }

    public function new(client:GanomedeClient) {
        super(client, turngameClientFactory, GanomedeTurnGameClient.TYPE);
        collection.modelFactory = function(json:Object):GanomedeTurnGame {
            return new GanomedeTurnGame(json);
        };
        addEventListener("reset", onReset);
        collection.addEventListener(Events.CHANGE, dispatchEvent);
        if (client.notifications != null) {
            client.notifications.listenTo("turngame/v1", function(e:Event):Void {
                var event:GanomedeNotificationEvent = cast e;
                // refresh the updated game
                if (event.notification.type == "move") {
                    collection.merge(event.notification.data.game);
                }
            });
        }
    }

    public function turngameClientFactory(url:String, token:String):AuthenticatedClient {
        return new GanomedeTurnGameClient(url, token);
    }

    private function onReset(event:Event):Void {
        collection.flushall();
        // refreshArray();
    }

    public function get(id:String):GanomedeTurnGame {
        return cast(collection.get(id), GanomedeTurnGame);
    }

    public function add(turngame:GanomedeTurnGame):Promise {
        if (!client.users.me.isAuthenticated()) {
            if (Ajax.verbose) trace("cant create turngame: not authenticated");
            return error(AjaxError.CLIENT_ERROR);
        }
        return executeAuth(function():Promise {
            var turngamesClient:GanomedeTurnGameClient = cast authClient;
            return turngamesClient.addGame(turngame);
        })
        .then(function(outcome:Dynamic):Void {
            collection.merge(turngame.toJSON());
        });
    }

    public function refresh(turngame:GanomedeTurnGame):Promise {
        if (!client.users.me.isAuthenticated()) {
            if (Ajax.verbose) trace("cant load turngame: not authenticated");
            return error(AjaxError.CLIENT_ERROR);
        }
        return executeAuth(function():Promise {
            var turngamesClient:GanomedeTurnGameClient = cast authClient;
            return turngamesClient.getGame(turngame);
        })
        .then(function(outcome:Dynamic):Void {
            collection.merge(turngame.toJSON());
        });
    }

    public function addMove(turngame:GanomedeTurnGame, move:GanomedeTurnMove):Promise {
        if (!client.users.me.isAuthenticated()) {
            if (Ajax.verbose) trace("cant add move to turngame: not authenticated");
            return error(AjaxError.CLIENT_ERROR);
        }
        return executeAuth(function():Promise {
            var turngamesClient:GanomedeTurnGameClient = cast authClient;
            return turngamesClient.addMove(turngame, move);
        })
        .then(function(outcome:Dynamic):Void {
            collection.merge(turngame.toJSON());
        });
    }

    // Refresh the turngames which IDs are in the array parameter.
    public function refreshArray(array:Array<String>):Promise {
        return Parallel.runWithArgs(array, function(id:String):Promise {
            var deferred = new Deferred();
            refresh(new GanomedeTurnGame({ id:id }))
            .then(deferred.resolve)
            .error(function(err:Error):Void {
                if (Ajax.verbose) trace("failed to refresh turngame(" + id + "): " + err);
                deferred.resolve(null);
            });
            return deferred;
        });
    }

    /*
    public function refreshArray():Promise {
        return refreshCollection(collection, function():Promise {
            return cast(authClient, GanomedeTurnGamesClient).listTurnGames();
        });
    }
    */
}
// vim: sw=4:ts=4:et:
