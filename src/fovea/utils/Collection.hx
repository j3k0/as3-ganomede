package fovea.utils;

import haxe.ds.StringMap;
import fovea.events.Event;
import fovea.events.Events;
import openfl.utils.Object;

@:expose
class Collection extends Events {

    private var map = new StringMap<Model>();
    public var keepStrategy:Model->Bool = null;
    public var modelFactory:Object->Model = null;

    public function asArray():Array<Model> {
        var ret = new Array<Model>();
        var keys = map.keys();
        for (key in keys)
            ret.push(map.get(key));
        return ret;
    }

    public function get(key:String):Model {
        return map.get(key);
    }

    public function del(key:String):Void {
        map.remove(key);
        dispatchEvent(new Event("del:" + key));
        dispatchEvent(new Event("del"));
    }

    public function set(key:String, value:Model):Void {
        map.set(key, value);
        dispatchEvent(new Event("set:" + key));
        dispatchEvent(new Event("set"));
    }

    public function exists(key:String):Bool {
        return map.exists(key);
    }

    public function keep(keys:Array<String>):Void {
        var keepKeys = new StringMap<Bool>();
        for (i in keys)
            keepKeys.set(i, true);
        for (key in map.keys()) {
            if (!keepKeys.get(key))
                del(key);
        }
    }

    public function flushall():Void {
        var oldMap = map;
        map = new StringMap<Model>();
        for (key in oldMap.keys())
            dispatchEvent(new Event("del:" + key));
        dispatchEvent(new Event("del"));
    }

    public function shouldKeep(item:Model):Bool {
        return keepStrategy != null ? keepStrategy(item) : true;
    }

    public function newModel(json:Object):Model {
        if (modelFactory != null) {
            return modelFactory(json);
        }
        else {
            return null;
        }
    }

    public function mergeModel(json:Object):Bool {
        var id:String = json.id;
        if (exists(id)) {
            var item:Model = get(id);
            if (!item.equals(json)) {
                item.fromJSON(json);
                if (!shouldKeep(item)) {
                    del(id);
                }
                return true;
            }
            else {
                return false;
            }
        }
        else {
            var item:Model = newModel(json);
            if (shouldKeep(item)) {
                set(id, item);
                return true;
            }
            else {
                return false;
            }
        }
    }

    public function mergeArray(result:Object):Bool {
        try {
            var newArray:Array<Object> = cast(result.data, Array<Object>);
            var changed:Bool = false;
            var keys:Array<String> = [];
            for (model in newArray)
                keys.push(model.id);
            keep(keys);
            var i:Int;
            for (i in 0...newArray.length) {
                newArray[i].index = i;
                if (mergeModel(newArray[i]))
                    changed = true;
            }
            if (changed)
                dispatchEvent(new Event(Events.CHANGE));
            return true;
        }
        catch (error:String) {
            return false;
        }
    }
}
// vim: sw=4:ts=4:et:
