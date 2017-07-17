package fovea.ganomede;

import fovea.async.*;
import openfl.utils.Object;
import fovea.net.Ajax;
import fovea.net.AjaxError;
import fovea.events.Event;
import fovea.events.Events;

//
// Link to ganomede-data module.
//
// The server module stores public readable JSON documents.
//
// This class provides the access point to retrieve those documents.
//
// See https://github.com/j3k0/ganomede-data for the full REST API
//
@:expose
class GanomedeData extends ApiClient
{
    public static inline var TYPE:String = "data/v1";

    public function new(client:GanomedeClient) {
        super(client.url + "/" + TYPE);
    }

    public function initialize():Promise {
        return new Deferred().resolve(null);
    }

    public function getData(docName:String):Promise {
        return ajaxGetData("/docs/" + docName);
    }
}

// vim: sw=4:ts=4:et:

