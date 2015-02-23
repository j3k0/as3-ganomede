package fovea.ganomede;

import openfl.utils.Object;
import fovea.net.AjaxError;

@:expose
class ApiError extends AjaxError
{
    // Api Codes
    public static inline var INVALID:String = "StormpathResourceError400";
    public static inline var ALREADY_EXISTS:String = "StormpathResourceError2001";

    public function new(pcode:String, pstatus:Int = 0, pdata:Object = null)
    {
        super(pcode, pstatus, pdata);

        // API Message
        if (data != null && data.message)
            apiMessage = data.message;
        else
            apiMessage = message;

        // API Code
        if (data != null && data.code)
            apiCode = data.code;
        else if (status != 0)
            apiCode = code + status;
        else
            apiCode = code;
    }

    public var apiMessage(default,null):String = null;
    public var apiCode(default,null):String = null;
}

// vim: sw=4:ts=4:et:
