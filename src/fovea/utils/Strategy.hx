package fovea.utils;

import openfl.utils.Object;

@:expose
class Strategy {
    public var canExecute:Object->Bool = null;
    public var execute:Object->Bool = null;

    public function new(canExecute:Object->Bool, execute:Object->Bool) {
        this.canExecute = canExecute;
        this.execute = execute;
    }
}
// vim: sw=4:ts=4:et:
