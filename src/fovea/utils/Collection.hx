package fovea.utils;

import haxe.ds.ObjectMap;

import openfl.events.EventDispatcher;
import openfl.events.Event;

@:generic
class Collection<T> extends EventDispatcher {

    private var map = new ObjectMap<String,T>();

    public function asArray():Array<T> {
        var ret = new Array<T>();
        for (key in map.keys())
            ret.push(map.get(key));
        return ret;
    }

    public function get(key:String):T {
        return map.get(key);
    }

    public function del(key:String):Void {
        map.remove(key);
        dispatchEvent(new Event("del:" + key));
        dispatchEvent(new Event("del"));
    }

    public function set(key:String, value:T):Void {
        map.set(key, value);
        dispatchEvent(new Event("set:" + key));
        dispatchEvent(new Event("set"));
    }

    public function exists(key:String):Bool {
        return map.exists(key);
    }

    public function keep(keys:Array<String>):Void {
        var keepKeys = new ObjectMap<String,Bool>();
        for (i in keys)
            keepKeys.set(i, true);
        for (key in map.keys()) {
            if (!keepKeys.get(key))
                del(key);
        }
    }

    public function flushall():Void {
        var oldMap = map;
        map = new ObjectMap<String,T>();
        for (key in oldMap.keys())
            dispatchEvent(new Event("del:" + key));
        dispatchEvent(new Event("del"));
    }
}

// vim: sw=4:ts=4:et:
