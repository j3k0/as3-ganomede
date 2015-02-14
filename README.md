# AS3-Ganomede

This is a client-side library in AS3 to interact with a Ganomede server.

## Getting started

Install Adobe Air, make sure air tools are in the PATH.

To get help about compiling and running the project.
```sh
make
```

## Documentation

### Initialization

First thing, you have to create a ganomede client and initialize it.

```js
var client:GanomedeClient = new GanomedeClient("http://ganomede.server.com:12000");
client.initialize()
    .then(function():void {
        trace("Initialization OK");
    })
    .error(function():void {
        trace("Initialization ERROR");
    });
```

### Registry

The registry allows you to retrieve informations about running services.

```js
var registry:GanomedeRegistry = client.registry;
for (var i:int = 0; i < registry.services.length; ++i) {
    var service:GanomedeService = registry.services[i];
    trace(" - " + service.type + " version " + service.version);
}
```

The code above will display the list of services as retrieve at initialization or at the last call to
`getServices`. If you really want the most up-to-date, non-cached list of running services, you can:

```js
registry.getServicesAsync()
    .then(function():void {
        for (var i:int = 0; i < registry.services.length; ++i) {
            var service:GanomedeService = registry.services[i];
            trace(" - " + service.type + " version " + service.version);
        }
    });
```

## Author
Jean-Christophe Hoelt <hoelt@fovea.cc>

## License
GPL v3
