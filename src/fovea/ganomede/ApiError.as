package fovea.ganomede
{
    public class ApiError extends Error
    {
        // Codes
        public static const HTTP_ERROR:String = "HTTP";
        public static const IO_ERROR:String = "IO";
        public static const SECURITY_ERROR:String = "SECURITY";
        public static const CLIENT_ERROR:String = "CLIENT";

        // Api Codes
        public static const INVALID:String = "StormpathResourceError400";
        public static const ALREADY_EXISTS:String = "StormpathResourceError2001";

        public function ApiError(code:String, status:int = 0, data:Object = null)
        {
            var msg:String = "ApiError[" + code + "]";
            if (status) {
                msg += " status:" + status;
            }
            super(msg, 1838012);
            _code = code;
            _status = status;
            _data = data;
        }

        private var _code:String = null;
        public function get code():String { return _code; }

        private var _status:int = 0;
        public function get status():int { return _status; }

        private var _data:Object = null;
        public function get data():Object { return _data; }

        public function get apiMessage():String {
            if (_data && _data.message)
                return _data.message;
            else
                return super.message();
        }

        public function get apiCode():String {
            if (_data && _data.code)
                return _data.code;
            else if (status) {
                return _code + _status;
            }
            else {
                return _code;
            }
        }
    }
}
// vim: sw=4:ts=4:et:
