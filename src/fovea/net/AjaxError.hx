package fovea.net;

import openfl.errors.Error;
import openfl.utils.Object;

@:expose
class AjaxError extends Error
{
    // Codes
    public static inline var HTTP_ERROR:String = "HTTP";
    public static inline var IO_ERROR:String = "IO";
    public static inline var SECURITY_ERROR:String = "SECURITY";
    public static inline var CLIENT_ERROR:String = "CLIENT";

    // IO Error statuses
    public static inline var IO_ERROR_JSON = 1;

    public function new(pcode:String, pstatus:Int = 0, pdata:Object = null)
    {
        var msg:String = "AjaxError[" + pcode + "]";
        if (pstatus != 0) {
            msg += " status:" + pstatus;
        }
        super(msg, 1838012);
        this.code = pcode;
        this.status = pstatus;
        this.data = pdata;
    }

    public var code(default,null):String = null;
    public var status(default,null):Int = 0;
    public var data(default,null):Object = null;
}

// vim: sw=4:ts=4:et:

