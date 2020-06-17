package fovea.ganomede;

import fovea.ganomede.models.GanomedeTurnGame;
import fovea.events.Event;

@:expose
class GanomedeTurnGameEvent extends Event
{
    public var turngame:GanomedeTurnGame;

    public function new(g:GanomedeTurnGame) {
        super(g.type);
        this.turngame = g;
    }
}
// vim: sw=4:ts=4:et:
