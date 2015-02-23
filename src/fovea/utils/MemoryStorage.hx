package fovea.utils;

import haxe.ds.StringMap;

@:expose
class MemoryStorage implements IStorage
{
    public function length():Int {
        var i:Int = 0;
        var it = map.keys();
        while (it.hasNext()) { i += 1; it.next(); }
        return i;
    }

    private var map:StringMap<String>;
    
    public function new() {
        map = new StringMap<String>();
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
        map = new StringMap<String>();
    }
}

// vim: sw=4:ts=4:et:
