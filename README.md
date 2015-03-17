# Ganomede

This is a multi-language client-side library to interact with a Ganomede server.

For now, it supports:

 * Javascript with NodeJS
 * Actionscript 3 (AIR and Flash Player)

# Author
Jean-Christophe Hoelt <hoelt@fovea.cc>

# License
GPL v3

# Javascript Documentation

## API

### Initialization

First thing, you have to create a ganomede client and initialize it.

```js
var ganomede = require("ganomede");
var client = new ganomede.GanomedeClient("http://ganomede.server.com:12000");
client.initialize()
    .then(function() {
        console.log("Initialization OK");
    })
    .error(function(err) {
        trace("Initialization ERROR");
    });
```

### Registry

The `registry` module allows you to retrieve informations about running services.

```js
var registry = client.registry;
for (var i = 0; i < registry.services.length; ++i) {
    var service = registry.services[i];
    console.log(" - " + service.type + " version " + service.version);
}
```

The code above will display the list of services as retrieves at initialization or at the last call to
`getServices`. If you really want the most up-to-date, non-cached list of running services, you can:

```js
registry.getServicesAsync()
    .then(function() {
        for (var i = 0; i < registry.services.length; ++i) {
            var service = registry.services[i];
            console.log(" - " + service.type + " version " + service.version);
        }
    });
```

### Users management

The `users` module allows you to manage user session (registration, login, profile (registration, login, profile).

To retrieve the client's `GanomedeUsers` instance:

```js
var users = client.users;
```

#### Sign up

Create a new `GanomedeUser` and sign him up.

```js
var me = new ganomede.GanomedeUser({
    username: 'testsignup',
    givenName: 'Test',
    surname: 'Ganomede Signup',
    email: 'testsignup@fovea.cc',
    password: 'Password1234!'
});
users.signUp(me)
    .then(function() {
        console.log("I am now authenticated");
    })
    .error(function(err) {
        console.log("Registration failed");
        if (err.apiCode == ganomede.ApiError.ALREADY_EXISTS)
            console.log("User already exists");
    });
```

#### Login

Create a new `GanomedeUser` with a username and password, login:

```js
var me = new ganomede.GanomedeUser({
    username: 'testlogin',
    password: 'Password1234!'
});
users.login(me)
    .then(function() {
        console.log("I am now logged in");
    })
    .error(function(err):void {
        console.log("Loggin failed");
        if (err.apiCode == ganomede.ApiError.INVALID) {
            console.log("Login failed");
            console.log(err.data.message);
        }
    });
```

#### Profile

```js
users.fetch(users.me)
    .then(function(user) {
        console.log(user.email);
        console.log(user.givenName);
        console.log(user.surname);
    });
```

### Invitations

The `invitations` module allows you to manage the users invitations (send, accept, reject, cancel).

To retrieve the client's `GanomedeInvitations` instance:

```js
var invitations = client.invitations;
```

Note: the array of invitations is gonna be this of the logged in user.

#### class GanomedeInvitation

fields:
```js
    var id:String;
    var gameId:String;
    var type:String;
    var to:String;
    var from:String;
    var index:Int;
```

methods:
* constructor(obj)
* toJSON()
* fromJSON(obj)

#### List invitations

```js
var array = client.invitations.asArray();
```

Returns and array of `GanomedeInvitation`, the module handles keeping this list up to date.

If you wanna make sure to request the list from the server:
```js
client.invitations.refreshArray()
.then(function() {
    // client.invitations.asArray has been updated
});
```

#### Create an invitation

```js
var invitation = new ganomede.GanomedeInvitation({
    type: "triominos/v1",
    to: "joe",
    gameId: "dummy"
});

client.invitations.add(invitation)
.then(function() {
    console.log("invitation success");
})
.error(function invitationError(err) {
    console.error("invitation error");
    console.dir(err);
    process.exit(1);
});
```

#### Cancel an invitations

Retrieve the `invitation` to cancel from the array of invitations. Then:
```js
client.invitations.cancel(invitation)
.then(function() {
    console.log("invitation cancelled");
})
.error(function cancelError(err) {
    console.error("invitation cancel error");
});
```

#### Accept or refuse an invitation

Like `cancel`, but the methods are called `accept` and `refuse`.

#### Listen to updates

Whenever there's a change in the list of invitations, the "ganomede.change" event is triggered by the invitations module.

```js
client.invitations.on("ganomede.change", function() {
    // list of invitations has been updated
});
```

**Untested** but may work...?

### Notifications

```js
var notifications = client.notifications;
```

#### Send a notification

```js
var notification = new ganomede.GanomedeNotification({
    to:   "username",
    from: "invitations/v1",
    type: "received",
    data: {
        from: "otheruser",
        gameId: "123"
    }
});
notifications.apiSecret = "1234567890";
notifications.send(notifications)
.then(...)
.error(...);
```

#### Listen to notifications

```js
notifications.listenTo("invitations/v1", function(event) {
    if (event.notification.type === "received") {
        console.log("invitation received from " + event.notification.data.from);
    }
});
```

## Contribute


# AS3 Documentation

## Getting started

Install Adobe Air, make sure air tools are in the PATH.

To get help about compiling and running the project.
```sh
make
```

## API Documentation

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

The `users` module allows you to manage user session (registration, login, profile).

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
users.fetch(users.me)
    .then(function(user:GanomedeUser):void {
        trace(user.email);
        trace(user.givenName);
        trace(user.surname);
    });
```
