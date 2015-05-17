package fovea.ganomede;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeTurnGame extends Model {
    public var type:String;
    public var players:Array<String>;
    public var turn:String;
    public var status:String;
    public var gameData:Object;
    public var gameConfig:Object;

    // server handling this turngame
    public var url:String;

    public function new(obj:Object = null) {
        super(obj);
    }

    public function fromGame(game:GanomedeGame):GanomedeTurnGame {
        fromJSON(game.toJSON());
        return this;
    }

    public override function fromJSON(obj:Object):Void {
        if (obj.id && id != obj.id) { id = obj.id; dispatchUpdate(); }
        if (obj.type && type != obj.type) { type = obj.type; dispatchUpdate(); }
        if (obj.players && players != obj.players) { players = obj.players; dispatchUpdate(); }
        if (obj.turn && turn != obj.turn) { turn = obj.turn; dispatchUpdate(); }
        if (obj.status && status != obj.status) { status = obj.status; dispatchUpdate(); }
        if (obj.gameData && gameData != obj.gameData) { gameData = obj.gameData; dispatchUpdate(); }
        if (obj.gameConfig && gameConfig != obj.gameConfig) { gameConfig = obj.gameConfig; dispatchUpdate(); }
        if (obj.url && url != obj.url) { url = obj.url; dispatchUpdate(); }
    }

    private var listeners = new Array<Void->Void>();
    public function addListener(fn:Void->Void):Void {
        listeners.push(fn);
    }
    public function removeListener(fn:Void->Void):Void {
        listeners.remove(fn);
    }
    function dispatchUpdate():Void {
        for (i in 0 ... listeners.length) {
            listeners[i]();
        }
    }

    public override function toJSON():Object {
        return {
            id:id,
            type:type,
            players:players,
            turn:turn,
            status:status,
            gameData:gameData,
            gameConfig:gameConfig,
            url:url
        };
    }
}
// vim: sw=4:ts=4:et:
