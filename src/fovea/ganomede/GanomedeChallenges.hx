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

    public function current():Promise {
        return cast(authClient, GanomedeChallengesClient).currentChallenge();
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
