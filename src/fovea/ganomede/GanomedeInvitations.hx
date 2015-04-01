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
class GanomedeInvitations extends UserClient
{
    public var collection(default,never) = new Collection();
    public function asArray() {
        var array = collection.asArray();
        array.sort(function(a:Model, b:Model):Int {
            return cast(a, GanomedeInvitation).index - cast(b, GanomedeInvitation).index;
        });
        return array;
    }

    public function new(client:GanomedeClient) {
        super(client, invitationsClientFactory, GanomedeInvitationsClient.TYPE);
        collection.modelFactory = function(json:Object):GanomedeInvitation {
            return new GanomedeInvitation(json);
        };
        addEventListener("reset", onReset);
        collection.addEventListener(Events.CHANGE, dispatchEvent);
    }

    public function invitationsClientFactory(url:String, token:String):AuthenticatedClient {
        return new GanomedeInvitationsClient(url, token);
    }

    private function onReset(event:Event):Void {
        collection.flushall();
        refreshArray();
    }

    public function add(invitation:GanomedeInvitation):Promise {
        if (!client.users.me.isAuthenticated()) {
            if (Ajax.verbose) trace("cant add invitation: not authenticated");
            return error(AjaxError.CLIENT_ERROR);
        }
        invitation.from = client.users.me.username;

        return executeAuth(function():Promise {
            var invitationsClient:GanomedeInvitationsClient = cast authClient;
            return invitationsClient.addInvitation(invitation);
        })
        .then(function(outcome:Dynamic):Void {
            collection.merge(invitation.toJSON());
        });
    }

    public function cancel(invitation:GanomedeInvitation):Promise {
        return deleteInvitation(invitation, "cancel");
    }
    public function accept(invitation:GanomedeInvitation):Promise {
        return deleteInvitation(invitation, "accept");
    }
    public function refuse(invitation:GanomedeInvitation):Promise {
        return deleteInvitation(invitation, "refuse");
    }

    private function deleteInvitation(invitation:GanomedeInvitation, reason:String):Promise {
        var deferred:Deferred = new Deferred();
        executeAuth(function():Promise {
            var invitationsClient:GanomedeInvitationsClient = cast authClient;
            return invitationsClient.deleteInvitation(invitation, reason);
        })
        .then(function(outcome:Dynamic):Void {
            collection.del(invitation.id);
            dispatchEvent(new Event(Events.CHANGE));
            deferred.resolve();
        })
        .error(deferred.reject);
        return deferred;
    }

    public function refreshArray():Promise {
        return refreshCollection(collection, function():Promise {
            return cast(authClient, GanomedeInvitationsClient).listInvitations();
        });
    }
}

// vim: sw=4:ts=4:et:
