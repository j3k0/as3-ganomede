package fovea.net;

#if flash
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Endian;
// import flash.utils.setTimeout;
// import flash.utils.clearInterval;
import fovea.net.MultipartURLLoaderEvent;

import haxe.ds.StringMap;
import haxe.Timer;
import openfl.utils.Object;
import openfl.errors.Error;

@:expose
class MultipartURLLoader extends EventDispatcher
{
    public static inline var BLOCK_SIZE:UInt = 64 * 1024;

    private var _loader = new URLLoader();
    private var _boundary:String;
    private var _variableNames = new Array<String>();
    private var _fileNames = new Array<String>();
    private var _variables = new StringMap<String>(); //Dictionary();
    private var _files = new StringMap<FilePart>(); //Dictionary();

    private var _async:Bool = false;
    private var _path:String;
    private var _data:ByteArray;

    private var _prepared:Bool = false;
    private var asyncWriteTimeoutId:Timer;
    private var asyncFilePointer:Int = 0;
    private var totalFilesSize:UInt = 0;
    private var writtenBytes:UInt = 0;

    public var requestHeaders = new Array<URLRequestHeader>();

    public function new() {
        super();
    }

    /**
     * Start uploading data to specified path
     *
     * @param	path	The server script path
     * @param	async	Set to true if you are uploading huge amount of data
     */
    public function load(path:String, async:Bool = false):Void
    {
        if (path == null || path == '') throw new IllegalOperationError('You cant load without specifing PATH');

        _path = path;
        _async = async;

        if (_async) {
            if(!_prepared){
                constructPostDataAsync();
            } else {
                doSend();
            }
        } else {
            _data = constructPostData();
            doSend();
        }
    }

    /**
     * Start uploading data after async prepare
     */
    public function startLoad():Void
    {
        if ( _path == null || _path == '' || _async == false ) throw new IllegalOperationError('You can use this method only if loading asynchronous.');
        if ( !_prepared && _async ) throw new IllegalOperationError('You should prepare data before sending when using asynchronous.');

        doSend();
    }

    /**
     * Prepare data before sending (only if you use asynchronous)
     */
    public function prepareData():Void
    {
        constructPostDataAsync();
    }

    /**
     * Stop loader action
     */
    public function close():Void
    {
        try {
            _loader.close();
        } catch( e:Error ) { }
    }

    /**
     * Add string variable to loader
     * If you have already added variable with the same name it will be overwritten
     *
     * @param	name	Variable name
     * @param	value	Variable value
     */
    public function addVariable(name:String, value:Object = ''):Void
    {
        if (_variableNames.indexOf(name) == -1) {
            _variableNames.push(name);
        }
        _variables.set(name, value);
        _prepared = false;
    }

    /**
     * Add file part to loader
     * If you have already added file with the same fileName it will be overwritten
     *
     * @param	fileContent	File content encoded to ByteArray
     * @param	fileName	Name of the file
     * @param	dataField	Name of the field containg file data
     * @param	contentType	MIME type of the uploading file
     */
    public function addFile(fileContent:ByteArray, fileName:String, dataField:String = 'Filedata', contentType:String = 'application/octet-stream'):Void
    {
        if (_fileNames.indexOf(fileName) == -1) {
            _fileNames.push(fileName);
            _files.set(fileName, new FilePart(fileContent, fileName, dataField, contentType));
            totalFilesSize += fileContent.length;
        } else {
            var f = _files.get(fileName);
            totalFilesSize -= f.fileContent.length;
            f.fileContent = fileContent;
            f.fileName = fileName;
            f.dataField = dataField;
            f.contentType = contentType;
            totalFilesSize += fileContent.length;
        }

        _prepared = false;
    }

    /**
    * Remove all variable parts
    */
    public function clearVariables():Void
    {
        _variableNames = new Array();
        _variables = new StringMap<String>();
        _prepared = false;
    }

    /**
    * Remove all file parts
    */
    public function clearFiles():Void
    {
        for (i in 0 ... _fileNames.length) {
            var name = _fileNames[i];
            _files.get(name).dispose();
        }
        _fileNames = new Array();
        _files = new StringMap<FilePart>();
        totalFilesSize = 0;
        _prepared = false;
    }

    /**
    * Dispose all class instance objects
    */
    public function dispose(): Void
    {
        if (asyncWriteTimeoutId != null) {
            asyncWriteTimeoutId.stop();
            asyncWriteTimeoutId = null;
        }
        removeListener();
        close();

        _loader = null;
        _boundary = null;
        _variableNames = null;
        _variables = null;
        _fileNames = null;
        _files = null;
        requestHeaders = null;
        _data = null;
    }

    /**
    * Generate random boundary
    * @return	Random boundary
    */
    public function getBoundary():String
    {
        if (_boundary == null) {
            _boundary = '';
            for (i in 0 ... 0x20) {
                _boundary += String.fromCharCode(cast(97 + Math.random() * 25, Int));
            }
        }
        return _boundary;
    }

    public function getAsync():Bool
    {
        return _async;
    }

    public function getPrepared():Bool
    {
        return _prepared;
    }

    public function getDataFormat():URLLoaderDataFormat
    {
        return _loader.dataFormat;
    }

    public function setDataFormat(format:URLLoaderDataFormat):Void
    {
        if (format != URLLoaderDataFormat.BINARY && format != URLLoaderDataFormat.TEXT && format != URLLoaderDataFormat.VARIABLES) {
            throw new IllegalOperationError('Illegal URLLoader Data Format');
        }
        _loader.dataFormat = format;
    }

    public function getLoader():URLLoader
    {
        return _loader;
    }

    private function doSend():Void
    {
        var urlRequest:URLRequest = new URLRequest();
        urlRequest.url = _path;
        //urlRequest.contentType = 'multipart/form-data; boundary=' + getBoundary();
        urlRequest.method = URLRequestMethod.POST;
        urlRequest.data = _data;

        urlRequest.requestHeaders.push( new URLRequestHeader('Content-type', 'multipart/form-data; boundary=' + getBoundary()) );

        if (requestHeaders.length > 0) {
            urlRequest.requestHeaders = urlRequest.requestHeaders.concat(requestHeaders);
        }

        addListener();

        _loader.load(urlRequest);
    }

    private function constructPostDataAsync():Void
    {
        if (asyncWriteTimeoutId != null) {
            asyncWriteTimeoutId.stop();
            asyncWriteTimeoutId = null;
        }

        _data = new ByteArray();
        _data.endian = Endian.BIG_ENDIAN;

        _data = constructVariablesPart(_data);

        asyncFilePointer = 0;
        writtenBytes = 0;
        _prepared = false;
        if (_fileNames.length > 0) {
            nextAsyncLoop();
        } else {
            _data = closeDataObject(_data);
            _prepared = true;
            dispatchEvent( new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_COMPLETE) );
        }
    }

    private function constructPostData():ByteArray
    {
        var postData:ByteArray = new ByteArray();
        postData.endian = Endian.BIG_ENDIAN;

        postData = constructVariablesPart(postData);
        postData = constructFilesPart(postData);

        postData = closeDataObject(postData);

        return postData;
    }

    private function closeDataObject(postData:ByteArray):ByteArray
    {
        postData = BOUNDARY(postData);
        postData = DOUBLEDASH(postData);
        return postData;
    }

    private function constructVariablesPart(postData:ByteArray):ByteArray
    {
        var i:UInt;
        var bytes:String;

        for (index in 0 ... _variableNames.length)
        {
            var name = _variableNames[index];
            postData = BOUNDARY(postData);
            postData = LINEBREAK(postData);
            bytes = 'Content-Disposition: form-data; name="' + name + '"';
            for (i in 0 ... bytes.length) {
                postData.writeByte( bytes.charCodeAt(i) );
            }
            postData = LINEBREAK(postData);
            postData = LINEBREAK(postData);
            postData.writeUTFBytes(_variables.get(name));
            postData = LINEBREAK(postData);
        }

        return postData;
    }

    private function constructFilesPart(postData:ByteArray):ByteArray
    {
        var i:Int = 0;
        var bytes:String;

        if(_fileNames.length > 0){
            for (index in 0 ... _fileNames.length)
            {
                var name = _fileNames[index];
                postData = getFilePartHeader(postData, _files.get(name));
                postData = getFilePartData(postData, _files.get(name));

                if (i != _fileNames.length - 1)
                {
                    postData = LINEBREAK(postData);
                }
                i++;

            }
            postData = closeFilePartsData(postData);
        }

        return postData;
    }

    private function closeFilePartsData(postData:ByteArray):ByteArray
    {
        var bytes:String;

        postData = LINEBREAK(postData);
        postData = BOUNDARY(postData);
        postData = LINEBREAK(postData);
        bytes = 'Content-Disposition: form-data; name="Upload"';
        for ( i in 0 ... bytes.length ) {
            postData.writeByte( bytes.charCodeAt(i) );
        }
        postData = LINEBREAK(postData);
        postData = LINEBREAK(postData);
        bytes = 'Submit Query';
        for ( i in 0 ... bytes.length ) {
            postData.writeByte( bytes.charCodeAt(i) );
        }
        postData = LINEBREAK(postData);

        return postData;
    }

    private function getFilePartHeader(postData:ByteArray, part:FilePart):ByteArray
    {
        //var i:UInt;
        var bytes:String;

        postData = BOUNDARY(postData);
        postData = LINEBREAK(postData);
        bytes = 'Content-Disposition: form-data; name="Filename"';
        for ( i in 0 ... bytes.length ) {
            postData.writeByte( bytes.charCodeAt(i) );
        }
        postData = LINEBREAK(postData);
        postData = LINEBREAK(postData);
        postData.writeUTFBytes(part.fileName);
        postData = LINEBREAK(postData);

        postData = BOUNDARY(postData);
        postData = LINEBREAK(postData);
        bytes = 'Content-Disposition: form-data; name="' + part.dataField + '"; filename="';
        for ( i in 0 ... bytes.length ) {
            postData.writeByte( bytes.charCodeAt(i) );
        }
        postData.writeUTFBytes(part.fileName);
        postData = QUOTATIONMARK(postData);
        postData = LINEBREAK(postData);
        bytes = 'Content-Type: ' + part.contentType;
        for ( i in 0 ... bytes.length ) {
            postData.writeByte( bytes.charCodeAt(i) );
        }
        postData = LINEBREAK(postData);
        postData = LINEBREAK(postData);

        return postData;
    }

    private function getFilePartData(postData:ByteArray, part:FilePart):ByteArray
    {
        postData.writeBytes(part.fileContent, 0, part.fileContent.length);

        return postData;
    }

    private function onProgress( event: ProgressEvent ): Void
    {
        dispatchEvent( event );
    }

    private function onComplete( event: Event ): Void
    {
        removeListener();
        dispatchEvent( event );
    }

    private function onIOError( event: IOErrorEvent ): Void
    {
        removeListener();
        dispatchEvent( event );
    }

    private function onSecurityError( event: SecurityErrorEvent ): Void
    {
        removeListener();
        dispatchEvent( event );
    }

    private function onHTTPStatus( event: HTTPStatusEvent ): Void
    {
        dispatchEvent( event );
    }

    private function addListener(): Void
    {
        _loader.addEventListener( Event.COMPLETE, onComplete, false, 0, false );
        _loader.addEventListener( ProgressEvent.PROGRESS, onProgress, false, 0, false );
        _loader.addEventListener( IOErrorEvent.IO_ERROR, onIOError, false, 0, false );
        _loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, onHTTPStatus, false, 0, false );
        _loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, false );
    }

    private function removeListener(): Void
    {
        _loader.removeEventListener( Event.COMPLETE, onComplete );
        _loader.removeEventListener( ProgressEvent.PROGRESS, onProgress );
        _loader.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
        _loader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, onHTTPStatus );
        _loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
    }

    private function BOUNDARY(p:ByteArray):ByteArray
    {
        var l:Int = getBoundary().length;
        p = DOUBLEDASH(p);
        for (i in 0 ... l) {
            p.writeByte( _boundary.charCodeAt( i ) );
        }
        return p;
    }

    private function LINEBREAK(p:ByteArray):ByteArray
    {
        p.writeShort(0x0d0a);
        return p;
    }

    private function QUOTATIONMARK(p:ByteArray):ByteArray
    {
        p.writeByte(0x22);
        return p;
    }

    private function DOUBLEDASH(p:ByteArray):ByteArray
    {
        p.writeShort(0x2d2d);
        return p;
    }

    private function nextAsyncLoop():Void
    {
        var fp:FilePart;

        if (asyncFilePointer < _fileNames.length) {

            fp = _files.get(_fileNames[asyncFilePointer]);
            _data = getFilePartHeader(_data, fp);

            asyncWriteTimeoutId = haxe.Timer.delay(function():Void {
                writeChunkLoop(_data, fp.fileContent, 0);
            }, 10);

            asyncFilePointer ++;
        } else {
            _data = closeFilePartsData(_data);
            _data = closeDataObject(_data);

            _prepared = true;

            dispatchEvent( new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_PROGRESS, totalFilesSize, totalFilesSize) );
            dispatchEvent( new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_COMPLETE) );
        }
    }

    private function writeChunkLoop(dest:ByteArray, data:ByteArray, p:UInt = 0):Void
    {
        var len:UInt = cast Math.min(BLOCK_SIZE, data.length - p);
        dest.writeBytes(data, p, len);

        if (len < BLOCK_SIZE || p + len >= data.length) {
            // Finished writing file bytearray
            dest = LINEBREAK(dest);
            nextAsyncLoop();
            return;
        }

        p += len;
        writtenBytes += len;
        if ( writtenBytes % BLOCK_SIZE * 2 == 0 ) {
            dispatchEvent( new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_PROGRESS, writtenBytes, totalFilesSize) );
        }

        asyncWriteTimeoutId = haxe.Timer.delay(function():Void {
            writeChunkLoop(dest, data, p);
        }, 10);
    }
}

class FilePart
{
    public var fileContent:flash.utils.ByteArray;
    public var fileName:String;
    public var dataField:String;
    public var contentType:String;

    public function new(fileContent:flash.utils.ByteArray, fileName:String, dataField:String = 'Filedata', contentType:String = 'application/octet-stream')
    {
        this.fileContent = fileContent;
        this.fileName = fileName;
        this.dataField = dataField;
        this.contentType = contentType;
    }

    public function dispose():Void
    {
        fileContent = null;
        fileName = null;
        dataField = null;
        contentType = null;
    }
}
#end
