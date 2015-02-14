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

The `registry` module allows you to retrieve informations about running services.

```js
var registry:GanomedeRegistry = client.registry;
for (var i:int = 0; i < registry.services.length; ++i) {
    var service:GanomedeService = registry.services[i];
    trace(" - " + service.type + " version " + service.version);
}
```

The code above will display the list of services as retrieves at initialization or at the last call to
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

### Users management

The `users` module allows you to manage user session (registration, login, profile (registration, login, profile).

To retrieve the client's `GanomedeUsers` instance:

```js
var users:GanomedeUsers = client.users;
```

#### Sign up

Create a new `GanomedeUser` and sign him up.

```js
var me:GanomedeUser = new GanomedeUser({
    username: 'testsignup',
    givenName: 'Test',
    surname: 'Ganomede Signup',
    email: 'testsignup@fovea.cc',
    password: 'Password1234!'
});
users.signUp(me)
    .then(function():void {
        trace("I am now authenticated");
    })
    .error(function(err:ApiError):void {
        trace("Registration failed");
        if (err.apiCode == ALREADY_EXISTS)
            trace("User already exists");
    });
```

#### Login

Create a new `GanomedeUser` with a username and password, login:

```js
var me:GanomedeUser = new GanomedeUser({
    username: 'testlogin',
    password: 'Password1234!'
});
users.login(me)
    .then(function():void {
        trace("I am now logged in");
    })
    .error(function(err:ApiError):void {
        trace("Loggin failed");
        if (err.apiCode == ApiError.INVALID) {
            trace("Login failed");
            trace(err.data.message);
        }
    });
```

#### Profile

```js
users.fetch(user.me)
    .then(function(user:GanomedeUser):void {
        trace(
    });
```

## Author
Jean-Christophe Hoelt <hoelt@fovea.cc>

## License
GPL v3
