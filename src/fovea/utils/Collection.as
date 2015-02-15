package fovea.utils
{
    import flash.events.EventDispatcher;
    import flash.events.Event;

    public class Collection extends EventDispatcher {
        private var _storage:Object = {};

        public function asArray():Array {
            var ret:Array = [];
            for (var key:String in _storage)
                ret.push(_storage[key]);
            return ret;
        }

        public function get(key:String):* {
            return _storage[key];
        }

        public function del(key:String):void {
            delete _storage[key];
            dispatchEvent(new Event("del:" + key));
            dispatchEvent(new Event("del"));
        }

        public function set(key:String, value:*):void {
            _storage[key] = value;
            dispatchEvent(new Event("set:" + key));
            dispatchEvent(new Event("set"));
        }

        public function exists(key:String):Boolean {
            return _storage[key] != undefined;
        }

        public function keep(keys:Array):void {
            var keepKeys:Object = {};
            for (var i:int = 0; i < keys.length; ++i)
                keepKeys[keys[i]] = true;
            for (var key:String in _storage) {
                if (!keepKeys[key])
                    del(key);
            }
        }

        public function flushall():void {
            var oldStorage:Object = {};
            _storage = {};
            for (var key:String in oldStorage)
                dispatchEvent(new Event("del:" + key));
            dispatchEvent(new Event("del"));
        }
    }
}
// vim: sw=4:ts=4:et:
