package fovea.net;

import openfl.utils.Object;
import fovea.async.Promise;

@:expose
interface IAjax
{
    function ajax(method:String, path:String, options:Object = null):Promise;
}
// vim: sw=4:ts=4:et:
