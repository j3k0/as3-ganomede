package fovea.ganomede.models;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeGameRank {
    public var game:GanomedeGameScores;
    public var outcome:GanomedeGameOutcome;

    public function new(obj:Object) {
        game = new GanomedeGameScores(obj.game);
        outcome = new GanomedeGameOutcome(obj.outcome);
    }

    public function toJSON():Object {
        return {
            game: game.toJSON(),
            outcome: outcome.toJSON()
        };
    }

    public function id():String { return game.id; }
    public function date():Float { return game.date; }
    public function numPlayers():Int { return game.players.length; }
    public function player(index:Int):GanomedePlayerScore { return game.players[index]; }
    public function newLevel():Float { return outcome.newLevel; }
    public function newRank():Int { return outcome.newRank; }
}

// vim: sw=4:ts=4:et:
