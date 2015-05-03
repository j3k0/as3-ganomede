package tests
{
    import flash.net.URLRequestMethod;

    import fovea.ganomede.*;
    import fovea.async.*;

    public class TestRun {

        //public static const GANOMEDE_URL:String = "http://192.168.59.103:80";
        public static const GANOMEDE_URL:String = "https://ganomede-devel.fovea.cc";

        public function TestRun() {
            // ApiClient.verbose = true;
        }

        public function run():Promise {
            return Waterfall.run([
                testClient,
                testService,
                testRegitry,
                testRegitryGetServicesAsync,
                testInitialize,
                testUserSignUp,
                testUserLogin,
                testUserLoginFailed,
                testUserProfile,
                testInvitations,
                testInvitationsRefresh
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
                    Assert.isTrue(result.status == 200,
                        "testClient status should be 200");
                    Assert.instanceOf(result.data, Array,
                        "testClient result.data should be an Array");
                    deferred.resolve();
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
                    Assert.isTrue(result.status == 200,
                        "testService status should be 200");
                    Assert.instanceOf(result.data, Array,
                        "testService result.data should be an Array");
                    deferred.resolve();
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testRegitry():Promise {
            trace("testRegitry");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL, {
                registry: { enabled: true }
            });
            var registry:GanomedeRegistry = client.registry;

            registry.initialize().
                then(function():void {
                    Assert.isTrue(registry.initialized,
                        "testRegitry should be initialized");
                    Assert.instanceOf(registry.services, Array,
                        "testRegitry services should be an Array");
                    Assert.instanceOf(registry.services[0], GanomedeService,
                        "testRegitry services[0] should be a GanomedeService");
                    deferred.resolve();
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testRegitryGetServicesAsync():Promise {
            trace("testRegitryGetServicesAsync");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL, {
                registry: { enabled: true }
            });
            var registry:GanomedeRegistry = client.registry;

            registry.getServicesAsync().
                then(function(services:Array):void {
                    Assert.instanceOf(services, Array);
                    Assert.instanceOf(services[0], GanomedeService);
                    deferred.resolve();
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testInitialize():Promise {
            trace("testInitialize");
            var deferred:Deferred = new Deferred();
            var client:Ganomede= new Ganomede(GANOMEDE_URL, {
                registry: { enabled: true }
            });

            client.initialize()
                .then(function():void {
                    Assert.isTrue(client.initialized);
                    Assert.isTrue(client.registry.initialized);
                    deferred.resolve();
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testUserSignUp():Promise {
            trace("testUserSignUp");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL, {
                users: { enabled: true }
            });

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
                    // If signup fails because the user already exists, we're good.
                    Assert.instanceOf(err, ApiError);
                    Assert.isTrue(err.code == "HTTP");
                    Assert.isTrue(err.status == 409, "User already exists");
                    Assert.isTrue(err.data.code == ApiError.ALREADY_EXISTS);
                    deferred.resolve();
                });

            return deferred;
        }

        public function testUserLogin():Promise {
            trace("testUserLogin");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL, {
                users: { enabled: true }
            });

            var users:GanomedeUsers = client.users;
            var me:GanomedeUser = new GanomedeUser({
                username: 'testuser',
                password: 'Changeme1'
            });
            users.login(me)
                .then(function():void {
                    Assert.isTrue(users.me == me,
                        "testUserLogin me should be the current user");
                    Assert.isTrue(me.token != null,
                        "testUserLogin me should have a token");
                    Assert.isTrue(me.isAuthenticated(),
                        "testUserLogin me should be authenticated");
                    deferred.resolve();
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testUserProfile():Promise {
            trace("testUserProfile");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL, {
                users: { enabled: true }
            });

            var users:GanomedeUsers = client.users;
            var me:GanomedeUser = new GanomedeUser({
                username: 'testuser@fovea.cc', // note: it's possible to use email as username
                password: 'Changeme1'
            });
            users.login(me)
                .then(function():void {
                    users.fetch(me)
                        .then(function(user:GanomedeUser):void {
                            Assert.isTrue(user == me, "user is me");
                            Assert.isTrue(user.username == "testuser", "username is testuser"); // username fixed
                            Assert.isTrue(user.email == "testuser@fovea.cc", "email is testuser@fovea.cc");
                            //Assert.isTrue(user.givenName == "Test", "given name is Test");
                            //Assert.isTrue(user.surname == "Ganomede Login", "surname is Ganomede Login");
                            deferred.resolve();
                        })
                        .error(deferred.reject);
                })
                .error(deferred.reject);

            return deferred;
        }

        public function testUserLoginFailed():Promise {
            trace("testUserLoginFailed");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL, {
                users: { enabled: true }
            });
            var users:GanomedeUsers = client.users;
            var me:GanomedeUser = new GanomedeUser({
                username: 'testuser',
                password: 'wrongPassword'
            });
            users.login(me)
                .then(deferred.reject)
                .error(function(err:ApiError):void {
                    Assert.isTrue(users.me == me,
                        "testUserLoginFailed me should be the current user");
                    Assert.isTrue(!me.isAuthenticated(),
                        "testUserLoginFailed me should not be authenticated");
                    Assert.isTrue(err.status == 400,
                        "testUserLoginFailed should fail with status 400");
                    Assert.isTrue(err.apiCode == "StormpathResourceError7100",
                        "testUserLoginFailed should fail with apiCode INVALID");
                    deferred.resolve();
                });

            return deferred;
        }

        public function testInvitations():Promise {
            trace("testInvitations");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL, {
                users: { enabled: true },
                invitations: { enabled: true }
            });
            var invitations:GanomedeInvitations = client.invitations;

            invitations.initialize().then(function():void {
                Assert.isTrue(invitations.asArray().length == 0);

                function testNoAuth():Promise {
                    trace("testInvitations.noAuth");
                    var i:GanomedeInvitation = new GanomedeInvitation({
                        from: null,
                        to: "joe",
                        gameId: "dummy"
                    });
                    return invitations.add(i).invert();
                }

                function login():Promise {
                    trace("testInvitations.login");
                    var me:GanomedeUser = new GanomedeUser({
                        username: 'testuser@fovea.cc', // note: it's possible to use email as username
                        password: 'Changeme1'
                    });
                    return client.users.login(me);
                }

                function testWrongFrom():Promise {
                    trace("testInvitations.wrongFrom");
                    var i:GanomedeInvitation = new GanomedeInvitation({
                        from: "notme",
                        to: "joe",
                        gameId: "dummy"
                    });
                    return invitations.add(i).invert();
                }

                var invite:GanomedeInvitation;
                var l0:int;

                function testOK():Promise {
                    trace("testInvitations.ok");
                    invite = new GanomedeInvitation({
                        type: "triominos/v1",
                        to: "joe",
                        gameId: "dummy"
                    });
                    l0 = invitations.asArray().length;
                    return invitations.add(invite)
                    .then(function():void {
                        Assert.isTrue(invite.id != null, "invitation should now have an ID");
                        Assert.isTrue(invitations.asArray().length == l0 + 1, "should now have l0+1 invitation");
                        Assert.isTrue(invitations.asArray()[l0].to == "joe", "should be to joe");
                        Assert.isTrue(invitations.asArray()[l0].from == "testuser", "should be from me");
                    });
                }

                function cleanup():Promise {
                    trace("testInvitations.cleanup");
                    return invitations.cancel(invite)
                    .then(function():void {
                        Assert.isTrue(invitations.asArray().length == l0, "should now have l0 invitation");
                    });
                }

                Waterfall.run([
                    testNoAuth, login, testWrongFrom, testOK, cleanup
                ])
                .then(deferred.resolve)
                .error(deferred.reject);
            }).error(deferred.reject);

            return deferred;
        }

        public function testInvitationsRefresh():Promise {
            trace("testInvitationsRefresh");
            var client:GanomedeClient = new GanomedeClient(GANOMEDE_URL, {
                users: { enabled: true },
                invitations: { enabled: true }
            });
            var invitations:GanomedeInvitations = client.invitations;

            function login():Promise {
                trace("testInvitationsRefresh.login");
                var me:GanomedeUser = new GanomedeUser({
                    username: 'testuser2',
                    password: 'Password1234!'
                });
                return client.users.login(me);
            }

            var invite:GanomedeInvitation;
            function createInvitation():Promise {
                trace("testInvitationsRefresh.create");
                invite = new GanomedeInvitation({
                    type: "triominos/v1",
                    to: "joe",
                    gameId: "dummy"
                });
                return invitations.add(invite);
            }

            function refreshInvitations():Promise {
                trace("testInvitationsRefresh.refresh");
                // invitations.addEventListener(GanomedeEvents.CHANGE, changed);
                return invitations.refreshArray();
            }

            function cleanupWithAccept():Promise {
                return invitations.accept(invite)
                .error(function(error:ApiError):void {
                    Assert.isTrue(error.status == 400);
                    Assert.isTrue(error.data.code == "InvalidContent")
                }).invert();
            }

            function cleanupWithCancel():Promise {
                return invitations.accept(invite)
                .error(function(error:ApiError):void {
                    Assert.isTrue(error.status == 400);
                    Assert.isTrue(error.data.code == "InvalidContent")
                })
                .invert();
            }

            return Waterfall.run([
                invitations.initialize,
                login,
                createInvitation,
                refreshInvitations,
                cleanupWithAccept,
                cleanupWithCancel
            ]);
        }
    }
}
// vim: sw=4:ts=4:et:
