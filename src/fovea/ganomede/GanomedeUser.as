package fovea.ganomede
{
    public class GanomedeUser {
        public var username:String;
        public var givenName:String;
        public var surname:String;
        public var email:String;
        public var password:String;
        public var token:String;

        public function GanomedeUser(obj:Object = null) {
            if (obj) {
                username = obj.username;
                givenName = obj.givenName;
                surname = obj.surname;
                email = obj.email;
                password = obj.password;
                token = obj.token;
            }
        }

        public function get authenticated():Boolean {
            return this.token ? true : false;
        }

        public function fromJSON(obj:Object):void {
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
}
// vim: sw=4:ts=4:et:
