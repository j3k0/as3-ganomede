package fovea.ganomede;

@:expose
class AuthenticatedClient extends ApiClient
{
    public var clientId(default,null):String = null;
    public var token(default,null):String = null;

    public function new(baseUrl:String, type:String, token:String) {
        super(baseUrl + "/" + type + "/auth/" + token);
        this.token = token;
        this.clientId = "" + Math.random() + "/" + Math.random();
    }
}
// vim: sw=4:ts=4:et:
