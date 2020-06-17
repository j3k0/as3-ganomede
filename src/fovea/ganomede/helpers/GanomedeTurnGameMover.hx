package fovea.ganomede.helpers;

import fovea.async.*;
import fovea.ganomede.models.GanomedeGame;
import fovea.ganomede.models.GanomedeTurnGame;
import fovea.ganomede.models.GanomedeTurnMove;
import fovea.net.AjaxError;
import openfl.utils.Object;

@:expose
class GanomedeTurnGameMover
{
    private var client:Ganomede;

    public function new(client:Ganomede) {
        this.client = client;
    }

    public function addMove(game:GanomedeGame, turngame:GanomedeTurnGame, move:GanomedeTurnMove):Promise {
        return client.turngames.addMove(turngame, move)
        .then(function(outcome:Dynamic):Void {
            if (turngame.status == "gameover") {
                client.games.gameover(game, turngame.gameData);
            }
        });
    }
}
