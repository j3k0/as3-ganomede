package fovea.ganomede;

import fovea.async.*;
import haxe.ds.StringMap;
import openfl.utils.Object;
import openfl.errors.Error;

@:expose
class GanomedeClientsPool
{
    private var pool = new StringMap<Int>();

    // Clients are stored in this array. Their ID is the index in the array.
    // It's not possible to remove a client.
    private var array = new Array<GanomedeClient>();

    public function new() {}

    public function initializeClient(url:String, options:Dynamic):Promise {

        // key is only the URL...
        //
        // That's because we don't want to have 2 connections to the same server.
        // Issue will occur if first client loaded has less featured enabled
        // than the newly requested client. For our use case, this won't happen.
        // The only case where an already loaded client is re-requested will be
        // to get a turngame client, the already loaded client will either be a
        // turngame client or the full-featured high-level client.
        var key:String = url;

        var deferred:Deferred = new Deferred();
        if (!pool.exists(key)) {
            var client = new GanomedeClient(url, options);
            client.initialize()
            .then(function(outcome:Dynamic):Void {
                var id = array.length;
                array.push(client);
                pool.set(key, id);
                deferred.resolve({
                    id: id,
                    client: client
                });
            })
            .error(function(err:Error):Void {
                deferred.reject(err);
            });
        }
        else {
            var id = pool.get(key);
            deferred.resolve({
                id: id,
                client: getClient(id)
            });
        }
        return deferred;
    }

    public function getClient(id:Int):GanomedeClient {
        return array[id];
    }
}
