package fovea.utils
{
    import flash.events.EventDispatcher;
    import flash.events.Event;

    public class Lodis extends EventDispatcher {

        private var _storage:IStorage;

        public function Lodis(storage:IStorage = null) {
            _storage = storage;
            if (!_storage) _storage = new MemoryStorage();
        }

        private function pack(value:Object):String {
            return JSON.stringify(value);
        }

        private function unpack(value:String):Object {
            return JSON.parse(value);
        }

        // Extension
        public function OSET(key:String, value:Object):void {
            SET(key, pack(value));
        }
        public function OGET(key:String):Object {
            try {
                return unpack(GET(key));
            }
            catch (error:Error) {
                return null;
            }
        }

        public function DEL(key:String):Boolean {
            _storage.removeItem(key);
            dispatchEvent(new Event("DEL:" + key));
            return true;
        }

        public function SET(key:String, value:String):Boolean {
            _storage.setItem(key, value);
            dispatchEvent(new Event("SET:" + key));
            return true;
        }

        public function GET(key:String):String {
            return _storage.getItem(key);
        }

        public function EXISTS(key:String):Boolean {
            return GET(key) != null;
        }

        public function DBSIZE():int {
            return _storage.length;
        }

        public function APPEND(key:String, value:String):Boolean {
            if (EXISTS(key)) {
                SET(key, GET(key) + value);
                return true;
            }
            return false;
        }

        public function DECR(key:String):int {
            return INCRBY(key, -1);
        }

        public function INCR(key:String):int {
            return INCRBY(key, 1);
        }

        public function DECRBY(key:String, quantity:int = 1):int {
            return INCRBY(key, -quantity);
        }

        public function INCRBY(key:String, quantity:int = 1):int {
            if (EXISTS(key)) {
                var value:Number = parseInt(GET(key));
                if (!isNaN(value)) {
                    value = value + quantity;
                    SET(key, "" + value);
                    return value;
                }
            }
            return 0;
        }

        public function FLUSHALL():void {
            _storage.clear()
        }

        public function FLUSHDB():void { FLUSHALL(); }

        public function GETSET(key:String, value:String):String {
            var old_value:String = null;
            if (EXISTS(key))
                old_value = GET(key);
            SET(key, value);
            return old_value;
        }

        public function RENAME(key:String, new_key:String):Boolean {
            var value:String = GET(key);
            DEL(key);
            return SET(new_key, value);
        }

        public function RENAMENX(key:String, new_key:String):Boolean {
            if (!EXISTS(new_key))
                return RENAME(key, new_key);
            return false;
        }

        public function SETNX(key:String, value:String):Boolean {
            if (!EXISTS(key))
                return SET(key, value);
            return false;
        }

        public function STRLEN(key:String):int {
            if (EXISTS(key))
                return GET(key).length;
            else
                return 0;
        }
    }
}
// vim: sw=4:ts=4:et:
