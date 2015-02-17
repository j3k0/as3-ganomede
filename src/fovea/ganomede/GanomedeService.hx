package fovea.ganomede
{
    import fovea.ganomede.ApiClient;

    public class GanomedeService
    {
        public var type:String;
        public var version:String;
        public var description:String;
        public var host:String;
        public var port:int;
        public var pingMs:int;

        public function GanomedeService(obj:Object) {
            type = obj.type;
            version = obj.version;
            description = obj.description;
            host = obj.host;
            port = obj.port;
            pingMs = obj.pingMs;
        }
    }
}
// vim: sw=4:ts=4:et:
