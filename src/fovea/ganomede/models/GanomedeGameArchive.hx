package fovea.ganomede.models;

import openfl.utils.Object;
import fovea.utils.Model;
import openfl.Vector;

@:expose
class GanomedeGameArchive {
    public var array:Vector<GanomedeGameRank>;

    public function new(obj:Vector<GanomedeGameRank> = null) {
        if (obj != null)
            this.array = obj;
        else
            this.array = new Vector<GanomedeGameRank>();
    }

    public static function fromJSON(obj:Array<Object>) {
        var array:Vector<GanomedeGameRank> = new Vector<GanomedeGameRank>(obj.length);
        for (i in 0...obj.length)
            array[i] = new GanomedeGameRank(obj[i]);
        return new GanomedeGameArchive(array);
    }

    public function slice(startIndex:Int, ?endIndex:Int):GanomedeGameArchive {
        if (endIndex != null)
            return new GanomedeGameArchive(this.array.slice(startIndex, endIndex));
        else
            return new GanomedeGameArchive(this.array.slice(startIndex));
    }

    public function last(numEntries:Int):GanomedeGameArchive {
        return slice(-numEntries);
    }

    public function reverse():GanomedeGameArchive {
        this.array.reverse();
        return this;
    }

    public function map(fn:GanomedeGameRank->Dynamic):Array<Dynamic> {
        return [for (i in 0...array.length) fn(array[i])];
    }

    public function forEach(fn:GanomedeGameRank->Void):Void {
        for (i in 0...array.length) fn(array[i]);
    }
}

// vim: sw=4:ts=4:et:
