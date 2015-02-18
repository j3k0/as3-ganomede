package fovea.ganomede;

import openfl.utils.Object;

class GanomedeUser {
    public var username:String;
    public var givenName:String;
    public var surname:String;
    public var email:String;
    public var password:String;

    public var token(default,set):String = null;
    public function set_token(value:String):String {
        token = value;
        if (token == "") token = null;
        return token;
    }

    public function isAuthenticated():Bool {
        return !(token == null || token == "");
    }

    public function new(obj:Object = null) {
        if (obj != null) {
            username = obj.username;
            givenName = obj.givenName;
            surname = obj.surname;
            email = obj.email;
            password = obj.password;
            token = obj.token;
        }
    }

    public function fromJSON(obj:Object):Void {
        if (obj.username) username = obj.username;
        if (obj.givenName) givenName = obj.givenName;
        if (obj.surname) surname = obj.surname;
        if (obj.email) email = obj.email;
        if (obj.password) password = obj.password;
        if (obj.token) token = obj.token;
    }

    public function toJSON():Object {
        return {
            username: username,
            givenName: givenName,
            surname: surname,
            email: email,
            password: password
        };
    }
}

// vim: sw=4:ts=4:et:
