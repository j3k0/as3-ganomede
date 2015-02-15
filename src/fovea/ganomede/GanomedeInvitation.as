package fovea.ganomede
{
    public class GanomedeInvitation {
        public var id:String;
        public var gameId:String;
        public var type:String;
        public var to:String;
        public var from:String;

        public function GanomedeInvitation(obj:Object = null) {
            if (!obj) return;
            if (obj.id) id = obj.id;
            if (obj.gameId) gameId = obj.gameId;
            if (obj.type) type = obj.type;
            if (obj.to) to = obj.to;
            if (obj.from) from = obj.from;
        }
    }
}
// vim: sw=4:ts=4:et:
