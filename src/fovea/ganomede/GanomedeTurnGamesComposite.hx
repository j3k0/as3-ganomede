package fovea.ganomede;

import fovea.async.*;
import openfl.utils.Object;
import haxe.ds.StringMap;
import fovea.net.AjaxError;

@:expose
class GanomedeTurnGamesComposite
{
    private var pool:GanomedeClientsPool;
    private var client:GanomedeClient;

    private var idMap = new StringMap<Int>();

    public function new(client:GanomedeClient, pool:GanomedeClientsPool) {
        this.pool = pool;
        this.client = client;
    }

    public function add(turngame:GanomedeTurnGame):Promise {
        var deferred:Deferred = new Deferred();
        prepareClient(turngame)
        .then(function(result:Dynamic):Void {
            var client:GanomedeClient = cast result.client;
            client.turngames.add(turngame)
            .then(deferred.resolve)
            .error(deferred.reject);
        })
        .error(deferred.reject);
        return deferred;
    }

    private function prepareClient(game:GanomedeTurnGame):Promise {
        var deferred:Deferred = new Deferred();
        pool.initializeClient(game.url, {
            turngame: { enabled: true },
            users: { enabled: true },
            notifications: { enabled: true}
        })
        .then(function(result):Void {
            var client:GanomedeClient = cast result.client;
            if (!client.users.me.isAuthenticated()) {
                client.users.login(new GanomedeUser({
                    username: this.client.users.me.username,
                    password: this.client.users.me.password
                }))
                .then(function(result:Dynamic):Void {
                    idMap.set(game.id, result.id);
                    deferred.resolve(result);
                })
                .error(deferred.reject);
            }
            else {
                deferred.resolve(result);
            }
        })
        .error(deferred.reject);
        return deferred;
    }

    public function get(id:String):GanomedeTurnGame {
        if (idMap.exists(id)) {
            var client = pool.getClient(idMap.get(id));
            return client.turngames.get(id);
        }
        else {
            return null;
        }
    }

    public function refresh(turngame:GanomedeTurnGame):Promise {
        if (idMap.exists(turngame.id)) {
            var client = pool.getClient(idMap.get(turngame.id));
            return client.turngames.refresh(turngame);
        }

        var deferred:Deferred = new Deferred();

        if (turngame.url != null) {
            prepareClient(turngame)
            .then(function(result) {
                var client:GanomedeClient = cast result.client;
                client.turngames.refresh(turngame)
                .then(deferred.resolve)
                .error(deferred.reject);
            })
            .error(deferred.reject);
        }
        else {
            deferred.reject(new ApiError(AjaxError.HTTP_ERROR, 400));
        }

        return deferred;
    }

    public function refreshArray(array:Array<GanomedeTurnGame>):Promise {
        return Parallel.runWithArgs(array, refresh);
    }
}
