package tests
{
    import flash.net.URLRequestMethod;

    import fovea.ganomede.*;
    import fovea.async.*;

    public class TestRun {

        public static const GANOMEDE_URL:String = "http://192.168.59.103:80";

        public function TestRun() {
        }

        public function run():Promise {
            return parallel([
                testClient,
                testService,
                testRegitry,
                testRegitryGetServicesAsync,
                testInitialize,
                testUserSignUp,
                testUserLogin,
                testUserLoginFailed,
                testUserProfile,
                testInvitations
            ])
            .error(function(err:Error):void {
                trace(err);
                if (err as ApiError) {
                    trace(JSON.stringify((err as ApiError).data));
                }
            });
        }

        private function test(t:Function, promise:Deferred):void {
            try {
                t();
                promise.resolve();
            }
            catch (e:Error) {
                trace(e);
                trace(e.getStackTrace());
                promise.reject(e);
            }
        }

        public function testClient():Promise {
            trace("testClient");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL);

            client.ajax("GET", "/registry/v1/services")
                .then(function(result:Object):void {
                    test(function():void {
                        Assert.isTrue(result.status == 200);
                        Assert.instanceOf(result.data, Array);
                    }, deferred);
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testService():Promise {
            trace("testService");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL);
            var service:ApiClient = client.service("registry/v1");

            service.ajax("GET", "/services")
                .then(function(result:Object):void {
                    test(function():void {
                        Assert.isTrue(result.status == 200);
                        Assert.instanceOf(result.data, Array);
                    }, deferred);
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testRegitry():Promise {
            trace("testRegitry");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL);
            var registry:GanomedeRegistry = client.registry;

            registry.initialize().
                then(function():void {
                    test(function():void {
                        Assert.isTrue(registry.initialized);
                        Assert.instanceOf(registry.services, Array);
                        Assert.instanceOf(registry.services[0], GanomedeService);
                    }, deferred);
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testRegitryGetServicesAsync():Promise {
            trace("testRegitryGetServicesAsync");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL);
            var registry:GanomedeRegistry = client.registry;

            registry.getServicesAsync().
                then(function(services:Array):void {
                    test(function():void {
                        Assert.instanceOf(services, Array);
                        Assert.instanceOf(services[0], GanomedeService);
                    }, deferred);
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testInitialize():Promise {
            trace("testInitialize");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL);

            client.initialize()
                .then(function():void {
                    test(function():void {
                        Assert.isTrue(client.initialized);
                        Assert.isTrue(client.registry.initialized);
                    }, deferred);
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testUserSignUp():Promise {
            trace("testUserSignUp");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL);

            var users:GanomedeUsers = client.users;
            var me:GanomedeUser = new GanomedeUser({
                username: 'testsignup',
                givenName: 'Test',
                surname: 'Ganomede Signup',
                email: 'testsignup@fovea.cc',
                password: 'Password1234!'
            });
            users.signUp(me)
                .then(function():void {
                    test(function():void {
                        Assert.isTrue(users.me == me, "me should be the current user");
                        Assert.isTrue(me.token, "me should have a token");
                    }, deferred);
                })
                .error(function(err:ApiError):void {
                    test(function():void {
                        // If signup fails because the user already exists, we're good.
                        Assert.instanceOf(err, ApiError);
                        Assert.isTrue(err.code == "HTTP");
                        Assert.isTrue(err.status == 409, "User already exists");
                        Assert.isTrue(err.data.code == ApiError.ALREADY_EXISTS);
                    }, deferred);
                });

            return deferred;
        }

        public function testUserLogin():Promise {
            trace("testUserLogin");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL);

            var users:GanomedeUsers = client.users;
            var me:GanomedeUser = new GanomedeUser({
                username: 'testuser',
                password: 'Changeme1'
            });
            users.login(me)
                .then(function():void {
                    test(function():void {
                        Assert.isTrue(users.me == me, "me should be the current user");
                        Assert.isTrue(me.token, "me should have a token");
                        Assert.isTrue(me.authenticated);
                    }, deferred);
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testUserProfile():Promise {
            trace("testUserProfile");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL);

            var users:GanomedeUsers = client.users;
            var me:GanomedeUser = new GanomedeUser({
                username: 'testuser@fovea.cc', // note: it's possible to use email as username
                password: 'Changeme1'
            });
            users.login(me)
                .then(function():void {
                    users.fetch(me)
                        .then(function(user:GanomedeUser):void {
                            test(function():void {
                                Assert.isTrue(user == me);
                                Assert.isTrue(user.username == "testuser"); // username fixed
                                Assert.isTrue(user.email == "testuser@fovea.cc");
                                Assert.isTrue(user.givenName == "Test");
                                Assert.isTrue(user.surname == "Ganomede Login");
                            }, deferred);
                        })
                        .error(deferred.reject);
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testUserLoginFailed():Promise {
            trace("testUserLoginFailed");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL);
            var users:GanomedeUsers = client.users;
            var me:GanomedeUser = new GanomedeUser({
                username: 'testuser',
                password: 'wrongPassword'
            });
            users.login(me)
                .then(deferred.reject)
                .error(function(err:ApiError):void {
                    test(function():void {
                        Assert.isTrue(users.me == me, "me should be the current user");
                        Assert.isTrue(!me.authenticated, "me should not be authenticated");
                        Assert.isTrue(err.status == 400, "should fail with status 400");
                        Assert.isTrue(err.apiCode == ApiError.INVALID, "should fail with apiCode INVALID");
                    }, deferred);
                });

            return deferred;
        }

        public function testInvitations():Promise {
            trace("testInvitations");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL);
            var invitations:GanomedeInvitations = client.invitations;

            deferred.resolve();

            return deferred;
        }
    }
}
// vim: sw=4:ts=4:et:
