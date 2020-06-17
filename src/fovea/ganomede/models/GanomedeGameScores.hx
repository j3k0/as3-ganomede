package fovea.ganomede.models;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeGameScores {
    public var id:String;
    public var date:Float;
    public var players:Array<GanomedePlayerScore>;

    public function new(obj:Object) {
        id = obj.id;
        date = obj.date;
        players = obj.players.map(
            function(p:Object):GanomedePlayerScore {
                return new GanomedePlayerScore(p);
        });
    }

    public function toJSON():Object {
        return {
            id: id,
            date: date,
            players: players.map(function(p:GanomedePlayerScore):Object {
                return p.toJSON();
            })
        };
    }
}

// vim: sw=4:ts=4:et:
