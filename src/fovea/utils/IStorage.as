package fovea.utils
{
    public interface IStorage
    {
        function setItem(key:String, value:String):void;
        function removeItem(key:String):void;
        function getItem(key:String):String;
        function get length():int;
        function clear():void;
    }
}
// vim: sw=4:ts=4:et:

