package fovea.ganomede;

import fovea.async.*;
import openfl.utils.Object;

class GanomedeRegistry extends ApiClient
{
    public var initialized(default,null):Bool = false;
    public var services(default,null) = new Array<GanomedeService>();

    private var client:GanomedeClient = null;

    public function new(client:GanomedeClient, url:String) {
        super(url);
        this.client = client;
    }

    // Load the list of services
    //
    // Beware, initialization may fail if the device isn't online.
    //
    // Call initialize again if you want to try time again.
    public function initialize():Promise {
        return getServices()
            .then(storeServices)
            .then(function(o:Object):Void {
                initialized = true;
            });
    }

    // Load and cache the list of services from server
    public function getServices():Promise {
        return cachedAjax("GET", "/services", { parse: parseServices })
            .then(storeServices);
    }

    // Update the stored list of services
    private function storeServices(result:Object):Void {
        if (result.data && result.data.length) {
            services = cast result.data;
        }
    }

    // Load and cache the list of services from server
    public function getServicesAsync():Promise {
        var deferred:Deferred = new Deferred();
        ajax("GET", "/services", { parse: parseServices, cache: true })
            .then(storeServices)
            .then(function(obj:Object):Void {
                deferred.resolve(services);
            })
            .error(deferred.reject);
        return deferred;
    }

    // Allocate GanomedeService instance from request data
    private function parseServices(obj:Object):Object {
        var array:Array<Object> = cast(obj, Array<Object>);
        for (i in 0...array.length)
            array[i] = new GanomedeService(array[i]);
        return array;
    }
}

// vim: sw=4:ts=4:et:
