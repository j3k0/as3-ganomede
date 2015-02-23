package fovea.events;

#if flash
    import openfl.events.Event;
    import openfl.events.EventDispatcher;
#elseif js
    import js.node.events.EventEmitter;
#else
#end

@:expose
class Events
#if flash
    extends EventDispatcher
#elseif js
    extends EventEmitter
#end
{
    public function run() {
    }

#if flash

    public function on(event:String, callback:Event->Void):Void { addEventListener(event, callback); }
    public function off(event:String, callback:Event->Void):Void { removeEventListener(event, callback); }
    public function addListener(event:String, callback:Dynamic):Void { on(event, callback); }
    public function removeListeners(event:String, callback:Dynamic):Void { off(event, callback); }
    public function emit(event:String, arg:Event):Void { dispatchEvent(new Event(event)); }

#elseif js

    public function addEventListener(event:String, callback:Event->Void):Void { on(event, callback); }
    public function off(event:String, callback:Event->Void):Void { removeListener(event, callback); }
    public function removeEventListener(event:String, callback:Event->Void):Void { removeListener(event, callback); }
    public function dispatchEvent(event:Event):Void { emit(event.type, event); }

#else

    // TODO

#end
}

// vim: sw=4:ts=4:et:
