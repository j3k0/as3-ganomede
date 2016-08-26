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
class GanomedeChallenges extends UserClient
{
    public var collection(default,never) = new Collection();
    public function asArray():Array<GanomedeChallenge> {
        var array = collection.asArray();
        array.sort(function arrayComparator(a:Model, b:Model):Int {
            return Std.int(cast(a, GanomedeChallenge).start - cast(b, GanomedeChallenge).start);
        });
        return cast array;
    }
    public function toJSON():Object {
        return collection.toJSON();
    }

    public var currentChallenge = new GanomedeChallenge();
    public function current():Promise {
        // If the cached challenge still is active, return it.
        if (currentChallenge != null && currentChallenge.end >= Date.now().getTime()) {
            var deferred = new Deferred();
            deferred.resolve(currentChallenge.toJSON());
            return deferred;
        }

        // No active cached challenge, load from server.
        currentChallenge.reset();
        return cast(authClient, GanomedeChallengesClient).currentChallenge()
        .then(function currentChallengeLoaded(outcome:Dynamic):Void {
            if (outcome.data.id) {
                // Cache the loaded challenge
                currentChallenge.fromJSON(outcome.data);
                adjustTimes(currentChallenge);
            }
        });
    }

    public function postUserEntry(moves:Array<Object>):Promise {
        return Waterfall.run([
            current,
            function():Promise {
                var client = cast(authClient, GanomedeChallengesClient);
                return client.postUserEntry(currentChallenge.id, moves);
            }
        ]);
    }

    public function getUserEntries():Promise {
        var deferred = new Deferred();
        var client = cast(authClient, GanomedeChallengesClient);
        return client.getUserEntries()
        .then(function userEntriesGotten(outcome:Dynamic):Void {
            var array:Array<Object> = outcome.data;
            for (i in 0...array.length)
                array[i] = new GanomedeChallengeEntry(array[i]);
            deferred.resolve({
                data: array
            });
        })
        .error(deferred.reject);
        return deferred;
    }

    private function adjustTimes(data:GanomedeChallenge):Void {
        if (data == null) return;
        // Adjust start and end to local device time
        var now:Float = Date.now().getTime();
        var oldEnd:Float = data.end;
        data.end = now + data.secondsToEnd * 1000 - 1;
        data.start = data.end - oldEnd + data.start;
    }

    public function new(client:GanomedeClient) {
        super(client, challengesClientFactory, GanomedeChallengesClient.TYPE);
        collection.modelFactory = function modelFactory(json:Object):GanomedeChallenge {
            return new GanomedeChallenge(json);
        };
        addEventListener("reset", onReset);
        collection.addEventListener(Events.CHANGE, dispatchEvent);
        /* if (client.notifications != null) {
            client.notifications.listenTo("challenges/v1", function challengeNotification(event:Event):Void {
                refreshArray();
            });
        } */
    }

    public function getLeaderboard(challengeId:String):Promise {
        var deferred = new Deferred();
        cast(authClient, GanomedeChallengesClient).getLeaderboard(challengeId)
        .then(function getLeaderboardFn(outcome:Dynamic):Void {
            var array:Array<Object> = outcome.data;
            for (i in 0...array.length)
                array[i] = new GanomedeChallengeEntry(array[i]);
            deferred.resolve(array);
        })
        .error(deferred.reject);
        return deferred;
    }

    public function challengesClientFactory(url:String, token:String):AuthenticatedClient {
        return new GanomedeChallengesClient(url, token);
    }

    private function onReset(event:Event):Void {
        collection.flushall();
        refreshArray();
    }

    /* public function addEntry(challenge:GanomedeChallenge):Promise {
        if (!client.users.me.isAuthenticated()) {
            if (Ajax.verbose) trace("cant add challenge: not authenticated");
            return error(AjaxError.CLIENT_ERROR);
        }
        challenge.from = client.users.me.username;

        return executeAuth(function addChallengeFn():Promise {
            var challengesClient:GanomedeChallengesClient = cast authClient;
            return challengesClient.addChallenge(challenge);
        })
        .then(function challengeAdded(outcome:Dynamic):Void {
            collection.merge(challenge.toJSON());
        });
    } */

    public function refreshArray():Promise {
        return refreshCollection(collection, function arrayRefreshed():Promise {
            return cast(authClient, GanomedeChallengesClient).listChallenges();
        });
    }
}

// vim: sw=4:ts=4:et:
