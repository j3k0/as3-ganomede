package fovea.ganomede;

import openfl.utils.Object;
import fovea.utils.Model;

@:expose
class GanomedeChallengeEntry extends Model {

    public var username:String;
    public var timestamp:Float;
    public var score:Float;
    public var time:Float;

    public var challengeId:String;
    public var bestScore:Float;
    public var bestTime:Float;
    public var ranking:Float;

    public function new(obj:Object = null) {
        super(obj);
    }

    public override function fromJSON(obj:Object):Void {
        if (obj == null) return;
        if (obj.id) id = obj.id;
        if (obj.username) username = obj.username;
        if (obj.timestamp) timestamp = obj.timestamp;
        else if (obj.start) timestamp = obj.start;
        if (obj.score) score = obj.score;
        if (obj.time) time = obj.time;
        if (obj.bestTime) bestTime = obj.bestTime;
        if (obj.bestScore) bestScore = obj.bestScore;
        if (obj.ranking) ranking = obj.ranking;
        if (obj.challengeId) challengeId = obj.challengeId;
    }

    public override function toJSON():Object {
        return {
            id:id,
            username:username,
            timestamp:timestamp,
            score:score,
            time:time,
            bestTime:bestTime,
            bestScore:bestScore,
            ranking:ranking,
            challengeId:challengeId
        };
    }
}

// vim: sw=4:ts=4:et:
