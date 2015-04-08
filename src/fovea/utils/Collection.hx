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
    private var merger:Strategy;

    public function new() {
#if flash
        super();
#end
        merger = new StrategyChain([
            new MergeArray(this),
            new MergeExisting(this),
            new MergeNonExisting(this)
        ]);
    }

    public function asArray():Array<Model> {
        var ret = new Array<Model>();
        var keys = map.keys();
        for (key in keys)
            ret.push(map.get(key));
        return ret;
    }

    public function toJSON():Object {
        var ret = [];
        var keys = map.keys();
        for (key in keys)
            ret.push(map.get(key).toJSON());
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

    // returns true iff the collection has changed
    public function keep(keys:Array<String>):Bool {
        var changed:Bool = false;
        var keepKeys = new StringMap<Bool>();
        for (i in keys)
            keepKeys.set(i, true);
        for (key in map.keys()) {
            if (!keepKeys.get(key)) {
                del(key);
                changed = true;
            }
        }
        return changed;
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

    public function merge(json:Object):Bool {
        if (merger.canExecute(json)) {
            var result:Object = merger.execute(json);
            if (result != null && result.changed) {
                dispatchEvent(new Event(Events.CHANGE));
                return true;
            }
            else {
                return false;
            }
        }
        else {
            return false;
        }
    }

    public function canMerge(json:Object):Bool {
        return merger.canExecute(json);
    }
}


// Merge an array in a collection
private class MergeArray extends Strategy {

    public function new(collection:Collection) {

        super(function(json:Object):Bool { // canMerge
            if (json == null || json.data == null) return false;
            var newArray:Array<Object> = cast(json.data, Array<Object>);
            if (newArray == null) return false;
            for (i in 0...newArray.length)
                if (!collection.canMerge(newArray[i]))
                    return false;
            return true;
        },

        function(json:Object):Object { // merge
            var newArray:Array<Object> = cast(json.data, Array<Object>);
            var keys:Array<String> = [];
            for (model in newArray) {
                keys.push(model.id);
            }
            var changed:Bool = collection.keep(keys);
            var i:Int;
            for (i in 0...newArray.length) {
                newArray[i].index = i;
                if (collection.merge(newArray[i]))
                    changed = true;
            }
            return { changed:changed };
        });
    }
}

// Merge an existing model into the collection
private class MergeExisting extends Strategy {

    public function new(collection:Collection) {

        super(function (json:Object):Bool { // canMerge
            // yes if there's an ID present in the collection
            if (json == null || json.id == null) return false;
            return collection.exists(json.id);
        },

        function (json:Object):Object { // merge
            var item:Model = collection.get(json.id);
            if (!item.equals(json)) {
                item.fromJSON(json);
                if (!collection.shouldKeep(item)) {
                    collection.del(json.id);
                }
                return { changed: true };
            }
            else {
                return { changed: false };
            }
        });
    }
}

// Merge in a new model in the collection
private class MergeNonExisting extends Strategy {

    public function new(collection:Collection) {

        super(function (json:Object):Bool { // canMerge
            // yes if there's an ID, not in the collection
            if (json == null || json.id == null) return false;
            return !collection.exists(json.id);
        },

        function (json:Object):Object { // merge
            var item:Model = collection.newModel(json);
            if (collection.shouldKeep(item)) {
                collection.set(json.id, item);
                return { changed: true };
            }
            else {
                return { changed: false };
            }
        });
    }
}
// vim: sw=4:ts=4:et:
