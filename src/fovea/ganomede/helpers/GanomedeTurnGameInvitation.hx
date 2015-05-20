// Manage the process of sending / accepting an invitation to a turngame.
//
// Invitation process:
//   - check in the list of games that there isn't a game in progress with other user
//   - create a game with the coordinator
//   - create a turngame
//   - send the invitation
//
// Accept process:
//   - accept the invitation
//   - join the game
//

package fovea.ganomede.helpers;

import fovea.async.*;
import fovea.net.AjaxError;
import openfl.utils.Object;

@:expose
class GanomedeTurnGameInvitation extends GanomedeInvitation
{
    private var client:Ganomede;

    public function new(client:Ganomede, obj:Object = null) {
        this.client = client;
        super(obj);
    }

    private function alreadyHasGameWith(friend:String):Bool {
        var array = client.games.collection.asArray();
        for (i in 0...array.length) {
            var g:GanomedeGame = cast array[i];
            if (g.status != "gameover") {
                for (j in 0...g.players.length) {
                    if (g.players[j] == friend) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    private function alreadyHasInvitationTo(friend:String):Bool {
        var array = client.invitations.collection.asArray();
        for (i in 0...array.length) {
            var g:GanomedeInvitation = cast array[i];
            if (g.to == friend) {
                return true;
            }
        }
        return false;
    }

    public function send(game:GanomedeGame, force:Bool = false):Promise {
        var friend:String = game.players[game.players.length - 1];
        return Waterfall.run([
            // Check game not exists
            function():Promise {
                var deferred:Deferred = new Deferred();
                if (!force && alreadyHasGameWith(friend)) {
                    deferred.reject(new ApiError(AjaxError.HTTP_ERROR, 400, {
                        code: "DuplicateGame",
                        message: "A game with this player already exists"
                    }));
                }
                else {
                    deferred.resolve(null);
                }
                return deferred;
            },
            // Check invitation not exists
            function():Promise {
                var deferred:Deferred = new Deferred();
                if (!force && alreadyHasInvitationTo(friend)) {
                    deferred.reject(new ApiError(AjaxError.HTTP_ERROR, 400, {
                        code: "DuplicateInvitation",
                        message: "An invitation with this player already exists"
                    }));
                }
                else {
                    deferred.resolve(null);
                }
                return deferred;
            },
            // Create game in coordinator
            function():Promise {
                return client.games.add(game);
            },
            // Create turngame
            function():Promise {
                var turngame = new GanomedeTurnGame(game.toJSON());
                return client.turngames.add(turngame);
            },
            // Send invitation
            function():Promise {
                this.fromJSON({
                    type: game.type,
                    to: friend,
                    gameId: game.id
                });
                return client.invitations.add(this);
            }
        ]);
    }

    public function accept():Promise {
        return Waterfall.run([
            function():Promise {
                return client.invitations.accept(this);
            },
            function():Promise {
                return client.games.join(new GanomedeGame({
                    id: this.gameId
                }));
            }
        ]);
    }
}
