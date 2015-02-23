package fovea.utils;

@:expose
interface IStorage
{
    function setItem(key:String, value:String):Void;
    function removeItem(key:String):Void;
    function getItem(key:String):String;
    function length():Int;
    function clear():Void;
}
// vim: sw=4:ts=4:et:

