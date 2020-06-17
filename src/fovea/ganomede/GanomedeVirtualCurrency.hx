package fovea.ganomede;

import fovea.ganomede.models.GanomedePackPurchase;
import fovea.ganomede.models.GanomedeVProduct;
import fovea.ganomede.models.GanomedeVMoney;
import fovea.ganomede.models.GanomedeVTransaction;
import fovea.async.Deferred;
import fovea.async.Promise;
import fovea.events.Event;
import fovea.events.Events;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.utils.Collection;
import fovea.utils.Model;
import openfl.errors.Error;
import openfl.utils.Object;

@:expose
class GanomedeVirtualCurrency extends UserClient
{
    private var knownCurrencies:Array<String> = [];
    private function isKnown(currency:String):Bool {
        for (i in 0 ... knownCurrencies.length)
            if (knownCurrencies[i] == currency) return true;
        return false;
    }
    private function rememberCurrency(currency:String):Void {
        if (!isKnown(currency))
            knownCurrencies.push(currency);
    }

    //
    // Collection of products
    //
    public var products(default,never) = new Collection();

    private function initProducts():Void {
        products.modelFactory = function productFactory(json:Object):GanomedeVProduct {
            return new GanomedeVProduct(json);
        };
        products.addEventListener(Events.CHANGE, dispatchEvent);
    }

    public function refreshProductsArray():Promise {
        return refreshCollection(products, function arrayRefreshed():Promise {
            return cast(authClient, GanomedeVirtualCurrencyClient).listProducts();
        });
    }

    //
    // Collection of balances
    //
    public var balances(default,never) = new Collection();

    private function initBalances():Void {
        balances.modelFactory = function balanceFactor(json:Object):GanomedeVMoney {
            return new GanomedeVMoney(json);
        };
        balances.addEventListener(Events.CHANGE, dispatchEvent);

        // Refresh all balances each time the virtualcurrency module sends a notification
        if (client.notifications != null) {
            client.notifications.listenTo("virtualcurrency/v1", function virtualcurrencyNotification(event:Event):Void {
                refreshBalancesArray();
            });
        }
    }

    public function refreshBalances(currencies:Array<String>, deferred:Deferred = null):Promise {

        for (i in 0 ... currencies.length)
            rememberCurrency(currencies[i]);

        if (deferred == null)
            deferred = new Deferred();

        if (!isAuthOK()) {
            haxe.Timer.delay(function():Void {
                refreshBalances(currencies, deferred);
            }, 1000);
            return deferred;
        }

        executeAuth(function():Promise {
            return cast(authClient, GanomedeVirtualCurrencyClient).getCount(currencies);
        })
        .then(function getCountResult(outcome:Dynamic):Void {
            if (outcome.data) {
                var data:Array<Object> = outcome.data;
                for (i in 0 ... data.length)
                    data[i].id = data[i].currency;
                balances.merge(outcome);
            }
            deferred.resolve(outcome);
        })
        // .then(deferred.resolve)
        .error(deferred.reject);

        return deferred;
    }

    public function refreshBalancesArray():Void {
        refreshBalances(knownCurrencies);
    }

    //
    // Collection of purchases
    //
    
    public var purchases(default,never) = new Collection();

    private function initPurchases():Void {
        purchases.modelFactory = function purchaseFactor(json:Object):GanomedeVTransaction {
            return new GanomedeVTransaction(json);
        };
        purchases.addEventListener(Events.CHANGE, dispatchEvent);
    }

    public function refreshPurchasesArray(currencies:Array<String> = null):Promise {

        if (currencies != null) {
            for (i in 0 ... currencies.length)
                rememberCurrency(currencies[i]);
        }
        else {
            currencies = knownCurrencies;
        }

        return refreshCollection(purchases, function():Promise {
            return cast(authClient, GanomedeVirtualCurrencyClient).getTransactions({
                reasons: "purchase",
                currencies: currencies,
                limit: 999999
            });
        });
    }

    // Constructor
    public function new(client:GanomedeClient) {
        super(client, virtualcurrencyClientFactory, GanomedeVirtualCurrencyClient.TYPE);
        initProducts();
        initBalances();
        initPurchases();
        addEventListener("reset", onReset);
    }

    public function virtualcurrencyClientFactory(url:String, token:String):AuthenticatedClient {
        return new GanomedeVirtualCurrencyClient(url, token);
    }

    private function onReset(event:Event):Void {
        products.flushall();
        balances.flushall();
        purchases.flushall();
        refreshProductsArray();
        refreshPurchasesArray();
        refreshBalancesArray();
    }

    private function finalizePurchase(deferred:Deferred):Void {
        var finalize:Void->Void = null;
        finalize = function():Void {
            refreshPurchasesArray()
            .then(deferred.resolve)
            .error(function(err:Error):Void {
                haxe.Timer.delay(finalize, 1000);
            });
        };
        finalize();
    }

    public function purchase(pid:String, cost:GanomedeVMoney):Promise {
        var deferred = new Deferred();
        cast(authClient, GanomedeVirtualCurrencyClient).addPurchase(pid, cost)
        .then(function getTransactionsResult(outcome:Dynamic):Void {
            finalizePurchase(deferred);
            refreshBalancesArray();
        })
        .error(deferred.reject);
        return deferred;
    }

    public function purchasePack(packPurchase:GanomedePackPurchase):Promise {
        return cast(authClient, GanomedeVirtualCurrencyClient).addPackPurchase(packPurchase);
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
