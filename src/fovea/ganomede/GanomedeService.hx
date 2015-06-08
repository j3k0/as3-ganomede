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
}

// vim: sw=4:ts=4:et:
