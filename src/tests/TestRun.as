package tests
{
    import flash.net.URLRequestMethod;

    import fovea.ganomede.*;
    import fovea.async.*;

    public class TestRun {
        public function TestRun() {
        }

        public function run():Promise {
            return waterfall([testClient, testService, testRegitry, testInitialize]);
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
            var client:GanomedeClient = new GanomedeClient("http://zalka.fovea.cc:48080");

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
            var client:GanomedeClient = new GanomedeClient("http://zalka.fovea.cc:48080");
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
            var client:GanomedeClient = new GanomedeClient("http://zalka.fovea.cc:48080");
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

        public function testInitialize():Promise {
            trace("testInitialize");
            var deferred:Deferred = new Deferred();
            var client:GanomedeClient = new GanomedeClient("http://zalka.fovea.cc:48080");

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
    }
}
// vim: sw=4:ts=4:et:
