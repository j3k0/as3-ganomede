package fovea.ganomede;

import fovea.async.*;
import fovea.utils.Collection;
import openfl.utils.Object;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.events.Event;
import fovea.events.Events;

@:expose
class GanomedeInvitations extends UserClient
{
    public var collection(default,never) = new Collection<GanomedeInvitation>();
    public function asArray() {
        var array = collection.asArray();
        array.sort(function(a:GanomedeInvitation, b:GanomedeInvitation):Int {
            return a.index - b.index;
        });
        return array;
    }

    public function new(client:GanomedeClient) {
        super(client, invitationsClientFactory, GanomedeInvitationsClient.TYPE);
        this.collection.modelFactory = function(json:Object):GanomedeInvitation {
            return new GanomedeInvitation(json);
        };
        addEventListener("reset", onReset);
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
            collection.mergeModel(invitation.toJSON());
            dispatchEvent(new Event(Events.CHANGE));
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
        var deferred:Deferred = new Deferred();
        var invitationsClient:GanomedeInvitationsClient = cast authClient;
        if (invitationsClient.token != null) {
            executeAuth(invitationsClient.listInvitations)
            .then(function(result:Object):Void {
                if (collection.mergeArray(result))
                    deferred.resolve();
                else
                    deferred.reject(new ApiError(AjaxError.IO_ERROR));
            })
            .error(deferred.reject);
        }
        else {
            if (Ajax.verbose) trace("Can't load invitations if not authenticated");
            deferred.reject(new ApiError(AjaxError.CLIENT_ERROR));
        }
        return deferred;
    }
}

// vim: sw=4:ts=4:et:
