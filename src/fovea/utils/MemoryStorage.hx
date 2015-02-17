package fovea.utils;

import haxe.ds.ObjectMap;

class MemoryStorage implements IStorage
{
    public var length(get,null):Int;
    public function get_length():Int {
        var i:Int = 0;
        var it = map.keys();
        while (it.hasNext()) { i += 1; it.next(); }
        return i;
    }

    private var map:ObjectMap<String,String>;
    
    public function new() {
        map = new ObjectMap<String,String>();
    }

    public function setItem(key:String, value:String):Void {
        map.set(key, value);
    }
    public function removeItem(key:String):Void {
        map.remove(key);
    }
    public function getItem(key:String):String {
        return map.get(key);
    }
    public function clear():Void {
        map = new ObjectMap<String,String>();
    }
}

// vim: sw=4:ts=4:et:
