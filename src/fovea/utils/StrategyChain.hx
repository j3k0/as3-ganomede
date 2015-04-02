package fovea.utils;

import openfl.utils.Object;

@:expose
class StrategyChain extends Strategy
{
    public function new(strategies:Array<Strategy>) {

        super(function(json:Object):Bool { // canExecute
            // if one of the strategies canExecute
            for (i in 0 ... strategies.length) {
                if (strategies[i].canExecute(json))
                    return true;
            }
            return false;
        },

        function(json:Object):Object { // execute
            // execute the first strategy that can
            for (i in 0 ... strategies.length) {
                if (strategies[i].canExecute(json))
                    return strategies[i].execute(json);
            }
            return null;
        });
    }
}

// vim: sw=4:ts=4:et:
