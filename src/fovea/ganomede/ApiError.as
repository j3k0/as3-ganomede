package fovea.ganomede
{
    public class ApiError extends Error
    {
        public static const HTTP_ERROR:String = "HTTP";
        public static const IO_ERROR:String = "IO";
        public static const SECURITY_ERROR:String = "SECURITY";

        public function ApiError(code:String, status:int = 0, data:Object = null)
        {
            var msg:String = "ApiError[" + code + "]";
            if (status) {
                msg += " status:" + status;
            }
            super(msg, 1838012);
            _status = status;
            _data = data;
        }

        private var _status:int = 0;
        public function get status():int { return _status; }

        private var _data:Object = null;
        public function get data():Object { return _data; }
    }
}
