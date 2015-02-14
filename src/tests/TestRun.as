package tests
{
    import flash.net.URLRequestMethod;

    import fovea.ganomede.ApiClient;
    import fovea.ganomede.GanomedeClient;
    import fovea.ganomede.GanomedeRegistry;

    import fovea.async.Promise;
    import fovea.async.Deferred;
    import fovea.async.when;
    import fovea.async.waterfall;

    public class TestRun {
        public function TestRun() {
        }

        public function run():Promise {
            return waterfall([testClient, testService, testRegitry]);
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

            registry.getServices()
                .then(function(result:Object):void {
                    test(function():void {
                        Assert.isTrue(result.status == 200);
                        Assert.instanceOf(result.data, Array);
                    }, deferred);
                })
                .error(deferred.reject);

            return deferred;
        }
    }
}
// vim: sw=4:ts=4:et:
