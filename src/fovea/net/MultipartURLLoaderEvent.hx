package fovea.net;

#if flash
import flash.events.Event;

@:expose
class MultipartURLLoaderEvent extends Event
{
    public static inline var DATA_PREPARE_PROGRESS:String = 'dataPrepareProgress';
    public static inline var DATA_PREPARE_COMPLETE:String = 'dataPrepareComplete';
    
    public var bytesWritten:UInt = 0;
    public var bytesTotal:UInt = 0;
    
    public function new(type:String, w:UInt = 0, t:UInt = 0) 
    {
        super(type);
        bytesTotal = t;
        bytesWritten = w;
    }
    
}
#end
