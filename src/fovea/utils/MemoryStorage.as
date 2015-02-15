package fovea.utils
{
    public class MemoryStorage implements Storage
    {
        private var _storage = {};
        public function setItem(key:String, value:String):void {
            _storage[key] = value;
        }
        public function removeItem(key:String):void {
            delete _storage[key];
        }
        public function getItem(key:String):String {
            return _storage[key];
        }
        public function get length():int {
            var i:int = 0;
            for (var id:String in _storage) { i += 1; }
            return i;
        }
        public function clear():void {
            _storage = {};
        }
    }
}
// vim: sw=4:ts=4:et:
