package fovea.utils;

    import openfl.events.EventDispatcher;
    import openfl.events.Event;
    import openfl.errors.Error;
    import openfl.utils.Object;
    import haxe.Json;

    class Lodis extends EventDispatcher {

        private var _storage:IStorage;

        public function Lodis(storage:IStorage = null) {
            _storage = storage;
            if (_storage == null) {
                _storage = new MemoryStorage();
            }
        }

        private function pack(value:Object):String {
            return Json.stringify(value);
        }

        private function unpack(value:String):Object {
            return Json.parse(value);
        }

        // Extension
        public function OSET(key:String, value:Object):Void {
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

        public function DEL(key:String):Bool {
            _storage.removeItem(key);
            dispatchEvent(new Event("DEL:" + key));
            return true;
        }

        public function SET(key:String, value:String):Bool {
            _storage.setItem(key, value);
            dispatchEvent(new Event("SET:" + key));
            return true;
        }

        public function GET(key:String):String {
            return _storage.getItem(key);
        }

        public function EXISTS(key:String):Bool {
            return GET(key) != null;
        }

        public function DBSIZE():Int {
            return _storage.length();
        }

        public function APPEND(key:String, value:String):Bool {
            if (EXISTS(key)) {
                SET(key, GET(key) + value);
                return true;
            }
            return false;
        }

        public function DECR(key:String):Int {
            return INCRBY(key, -1);
        }

        public function INCR(key:String):Int {
            return INCRBY(key, 1);
        }

        public function DECRBY(key:String, quantity:Int = 1):Int {
            return INCRBY(key, -quantity);
        }

        public function INCRBY(key:String, quantity:Int = 1):Int {
            if (EXISTS(key)) {
                var value:Null<Int> = Std.parseInt(GET(key));
                if (value != null) {
                    value = value + quantity;
                    SET(key, "" + value);
                    return value;
                }
            }
            return quantity;
        }

        public function FLUSHALL():Void {
            _storage.clear();
        }

        public function FLUSHDB():Void { FLUSHALL(); }

        public function GETSET(key:String, value:String):String {
            var old_value:String = null;
            if (EXISTS(key))
                old_value = GET(key);
            SET(key, value);
            return old_value;
        }

        public function RENAME(key:String, new_key:String):Bool {
            var value:String = GET(key);
            DEL(key);
            return SET(new_key, value);
        }

        public function RENAMENX(key:String, new_key:String):Bool {
            if (!EXISTS(new_key))
                return RENAME(key, new_key);
            return false;
        }

        public function SETNX(key:String, value:String):Bool {
            if (!EXISTS(key))
                return SET(key, value);
            return false;
        }

        public function STRLEN(key:String):Int {
            if (EXISTS(key))
                return GET(key).length;
            else
                return 0;
        }
    }

// vim: sw=4:ts=4:et:
