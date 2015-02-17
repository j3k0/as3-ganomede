package fovea.ganomede;

import fovea.async.*;
import openfl.events.Event;
import fovea.utils.Collection;
import openfl.utils.Object;

class GanomedeInvitations extends ApiClient
{
    public var initialized(get,null):Bool = false;
    public function get_initialized():Bool { return initialized; }

    private var client:GanomedeClient;
    private var invitationsClient:GanomedeInvitationsClient;

    public var collection(get,null) = new Collection<GanomedeInvitation>();
    public function get_array():Array<GanomedeInvitation> {
        return collection.asArray()
            .sort(function(a:GanomedeInvitation, b:GanomedeInvitation):Int {
                return a.index - b.index;
            });
    }

    public function new(client:GanomedeClient) {
        super(client.url + "/" + GanomedeInvitationsClient.TYPE);
        client = client;
        invitationsClient = new GanomedeInvitationsClient(client.url, null);
    }

    public function initialize():Promise {
        var deferred:Deferred = new Deferred();

        client.users.addEventListener(GanomedeEvents.LOGIN, onLoginLogout);
        client.users.addEventListener(GanomedeEvents.LOGOUT, onLoginLogout);

        deferred.resolve();
        return deferred
            .then(function():Void {
                initialized = true;
            });
    }

    public function onLoginLogout(event:Event):Void {

        var oldAuthToken:String = null;
        if (invitationsClient) oldAuthToken = invitationsClient.token;

        var newAuthToken:String = null;
        if (client.me) newAuthToken = client.me.token;

        if (newAuthToken != oldAuthToken) {
            invitationsClient = new GanomedeInvitationsClient(client.url, newAuthToken);
            collection.flushall();
            refreshArray();
        }
    }

    public function add(invitation:GanomedeInvitation):Promise {
        if (!client.me.authenticated) {
            if (verbose) trace("cant add invitation: not authenticated");
            return error(ApiError.CLIENT_ERROR);
        }
        invitation.from = client.me.username;

        return invitationsClient.addInvitation(invitation)
            .then(function():Void {
                mergeInvitation(invitation.toJSON());
                dispatchEvent(new Event(GanomedeEvents.CHANGE));
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
        invitationsClient.deleteInvitation(invitation, reason)
        .then(function():Void {
            collection.del(invitation.id);
            dispatchEvent(new Event(GanomedeEvents.CHANGE));
            deferred.resolve();
        })
        .error(deferred.reject);
        return deferred;
    }

    public function refreshArray():Promise {
        var deferred:Deferred = new Deferred();
        if (invitationsClient.token) {
            invitationsClient.listInvitations()
            .then(function(result:Object):Void {
                if (processListInvitations(result))
                    deferred.resolve();
                else
                    deferred.reject(new ApiError(ApiError.IO_ERROR));
            })
            .error(deferred.reject);
        }
        else {
            if (verbose) trace("Can't load invitations if not authenticated");
            deferred.reject(new ApiError(ApiError.CLIENT_ERROR));
        }
        return deferred;
    }

    private function processListInvitations(result:Object):Bool {
        var newArray:Array<Object> = cast(result.data,Array<Object>);
        if (newArray) {
            var changed:Bool = false;
            var keys:Array = [];
            for (invitation in newArray)
                keys.push(invitation.id);
            collection.keep(keys);
            var i:Int;
            for (i in 0...newArray.length) {
                newArray[i].index = i;
                if (mergeInvitation(newArray[i]))
                    changed = true;
            }
            if (changed)
                dispatchEvent(new Event(GanomedeEvents.CHANGE));
            return true;
        }
        else {
            return false;
        }
    }

    private function mergeInvitation(json:Object):Bool {
        var id:String = json.id;
        if (collection.exists(id)) {
            var item:GanomedeInvitation = collection.get(id);
            if (!item.equals(json)) {
                item.fromJSON(json);
                return true;
            }
            else {
                return false;
            }
        }
        else {
            collection.set(id, new GanomedeInvitation(json));
            return true;
        }
    }
}

// vim: sw=4:ts=4:et:

