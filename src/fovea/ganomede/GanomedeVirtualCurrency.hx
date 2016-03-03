package fovea.ganomede;

import fovea.async.*;
import fovea.utils.Collection;
import fovea.utils.Model;
import openfl.utils.Object;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.events.Event;
import fovea.events.Events;

@:expose
class GanomedeVirtualCurrency extends UserClient
{
    //
    // Collection of products
    //
    public var products(default,never) = new Collection();
    public function refreshProductsArray():Promise {
        return refreshCollection(products, function arrayRefreshed():Promise {
            return cast(authClient, GanomedeVirtualCurrencyClient).listProducts();
        });
    }

    //
    // Collection of balances
    //
    public var balances(default,never) = new Collection();
    public function refreshBalance(currencyCode:String):Promise {
        return cast(authClient, GanomedeVirtualCurrencyClient).getCount(currencyCode)
        .then(function getCountResult(outcome:Dynamic):Void {
            if (outcome.data) {
                outcome.data.id = outcome.data.currency;
                balances.merge(outcome.data);
            }
        });
    }

    public function new(client:GanomedeClient) {
        super(client, virtualcurrencyClientFactory, GanomedeVirtualCurrencyClient.TYPE);
        products.modelFactory = function productFactory(json:Object):GanomedeVProduct {
            return new GanomedeVProduct(json);
        };
        balances.modelFactory = function balanceFactor(json:Object):GanomedeVMoney {
            return new GanomedeVMoney(json);
        };
        addEventListener("reset", onReset);
        products.addEventListener(Events.CHANGE, dispatchEvent);
    }

    public function virtualcurrencyClientFactory(url:String, token:String):AuthenticatedClient {
        return new GanomedeVirtualCurrencyClient(url, token);
    }

    private function onReset(event:Event):Void {
        products.flushall();
        balances.flushall();
        refreshProductsArray();
    }

    /*
    public function add(virtualcurrency:GanomedeVirtualCurrency):Promise {
        if (!client.users.me.isAuthenticated()) {
            if (Ajax.verbose) trace("cant add virtualcurrency: not authenticated");
            return error(AjaxError.CLIENT_ERROR);
        }
        virtualcurrency.from = client.users.me.username;

        return executeAuth(function addVirtualCurrencyFn():Promise {
            var virtualcurrencyClient:GanomedeVirtualCurrencyClient = cast authClient;
            return virtualcurrencyClient.addVirtualCurrency(virtualcurrency);
        })
        .then(function virtualcurrencyAdded(outcome:Dynamic):Void {
            products.merge(virtualcurrency.toJSON());
        });
    }

    public function cancel(virtualcurrency:GanomedeVirtualCurrency):Promise {
        return deleteVirtualCurrency(virtualcurrency, "cancel");
    }
    public function accept(virtualcurrency:GanomedeVirtualCurrency):Promise {
        return deleteVirtualCurrency(virtualcurrency, "accept");
    }
    public function refuse(virtualcurrency:GanomedeVirtualCurrency):Promise {
        return deleteVirtualCurrency(virtualcurrency, "refuse");
    }

    private function deleteVirtualCurrency(virtualcurrency:GanomedeVirtualCurrency, reason:String):Promise {
        var deferred:Deferred = new Deferred();
        executeAuth(function deleteVirtualCurrencyFn():Promise {
            var virtualcurrencyClient:GanomedeVirtualCurrencyClient = cast authClient;
            return virtualcurrencyClient.deleteVirtualCurrency(virtualcurrency, reason);
        })
        .then(function virtualcurrencyDeleted(outcome:Dynamic):Void {
            products.del(virtualcurrency.id);
            dispatchEvent(new Event(Events.CHANGE));
            deferred.resolve();
        })
        .error(deferred.reject);
        return deferred;
    }
    */
}

// vim: sw=4:ts=4:et:
