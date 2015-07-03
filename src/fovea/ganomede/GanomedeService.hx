package fovea.ganomede;

import fovea.ganomede.ApiClient;
import openfl.utils.Object;

@:expose
class GanomedeService
{
    public var type:String;
    public var version:String;
    public var description:String;
    public var host:String;
    public var port:Int;
    public var pingMs:Int;

    public function new(obj:Object) {
        if (obj == null) return;
        type = obj.type;
        version = obj.version;
        description = obj.description;
        host = obj.host;
        port = obj.port;
        pingMs = obj.pingMs;
    }

    public function splitVersion():Array<Int> {
        var sret:Array<String>;
        var ret = new Array<Int>;
        if (version != null) {
            sret = version.split(".");
            for (i in 0...sret.length) {
                ret.push(Std.parseInt(sret[i]));
            }
        }
        while (ret.length < 3) {
            ret.push(0);
        }
        return ret;
    }

    public function versionMajor():Int {
        return splitVersion()[0];
    }
    public function versionMinor():Int {
        return splitVersion()[1];
    }
    public function versionPatch():Int {
        return splitVersion()[2];
    }

    public function versionGE(major:Int, minor:Int = 0, patch:Int = 0):Bool {
        var v = splitVersion();
        if (v[0] > major) return true;
        if (v[0] < major) return false;
        if (v[1] > minor) return true;
        if (v[1] < minor) return false;
        if (v[2] >= patch) return true;
        return false;
    }

}

// vim: sw=4:ts=4:et:
