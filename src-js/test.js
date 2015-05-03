var ganomede = require("../index");
var client = null;
var user = null;

var serverUrl = process.env.GANOMEDE_TEST_SERVER_URL;
if (!serverUrl) {
    console.error("Please specify your test server URL in GANOMEDE_TEST_SERVER_URL environment variable");
    process.exit(1);
}

function initialize(done) {
    client = ganomede.createClient(serverUrl, {
        registry: { enabled: true },
        users: { enabled: true },
        notifications: { enabled: true },
        invitations: { enabled: true },
        turngames: { enabled: true },
        games: {
            enabled: true,
            type: "triominos/v1"
        }
    });
    client.initialize()
    .then(function initializeSuccess(res) {
        console.log("initialize success");
        console.dir(client.registry.services);
        done();
    })
    .error(function initializeError(err) {
        console.error("initialize error");
        console.dir(err);
        process.exit(1);
    });
}

function login(done) {
    user = new ganomede.GanomedeUser({
        username: process.env.GANOMEDE_TEST_USERNAME,
        password: process.env.GANOMEDE_TEST_PASSWORD
    });
    if (!user.username || !user.password) {
        console.error("Please specify your test username and password using environment variables:");
        console.error(" - GANOMEDE_TEST_USERNAME");
        console.error(" - GANOMEDE_TEST_PASSWORD");
        process.exit(1);
    }
    client.users.login(user)
    .then(function loginSuccess(res) {
        console.log("login success");
        console.dir(user);
        done();
    })
    .error(function loginError(err) {
        console.error("login error");
        console.dir(err);
        process.exit(1);
    });
}

function profile(done) {
    client.users.fetch(user)
    .then(function profileSuccess() {
        console.log("profile success");
        console.dir(user);
        done();
    })
    .error(function profileError(err) {
        console.error("profile error");
        console.dir(err);
        process.exit(1);
    });
}

function refreshInvitations(done) {
    client.invitations.refreshArray()
    .then(done)
    .error(function(err) {
        console.error("invitations error (refresh)");
        console.dir(err);
        process.exit(1);
    });
}

function invitations(done) {

    console.log("invitations");
    console.dir(client.invitations.asArray());

    var invitation = new ganomede.GanomedeInvitation({
        type: "triominos/v1",
        to: "joe",
        gameId: "dummy"
    });
    client.invitations.add(invitation)
    .then(function() {
        console.log("invitation success");
        console.dir(client.invitations.asArray());
        client.invitations.cancel(invitation)
        .then(done)
        .error(function cancelError(err) {
            console.error("invitation cancel error");
            console.dir(err);
            process.exit(1);
        });
    })
    .error(function invitationError(err) {
        console.error("invitation error");
        console.dir(err);
        process.exit(1);
    });
}

function notifications(done) {
    console.log("notification");
    var rnd = "" + Math.random();
    var nCalls = 0;
    client.notifications.listenTo("test/v1", function(event) {
        if (event.notification.data.rnd !== rnd) {
            // old message
            return;
        }
        nCalls += 1;
        if (nCalls > 1) {
            console.error("notification error (called too many times)");
            process.exit(1);
        }
        console.log("notification success");
        if (event.notification.data.iamtrue !== true
            || event.notification.type !== "success"
            || event.notification.from !== "test/v1") {
            console.error("notification error");
            process.exit(1);
        }
        done();
    });
    var n = new ganomede.GanomedeNotification({
        from: "test/v1",
        to: "testuser",
        type: "success",
        data: {
            iamtrue: true,
            rnd:rnd
        }
    });
    client.notifications.apiSecret = process.env.API_SECRET;
    console.log("send notification");
    setTimeout(function() {
        client.notifications.send(n)
        .error(function(err) {
            console.error("notifications error (sending notif)");
            console.dir(err);
            process.exit(1);
        });
    }, 100);
}

function refreshGames(done) {
    client.games.refreshArray()
    .then(done)
    .error(function(err) {
        console.error("games error (refresh)");
        console.dir(err);
        process.exit(1);
    });
}

function leaveAllGames(done) {
    var games = client.games.asArray();
    console.log("leaveAllGames (" + games.length + ")");
    var numDone = 0;
    var oneDone = function() {
        numDone += 1;
        if (numDone == games.length)
            done();
        if (numDone > games.length) {
            console.error("games error (done callback called too many times)");
            process.exit(1);
        }
    };
    for (var i = 0; i < games.length; ++i) {
        client.games.leave(games[i])
        .then(oneDone)
        .error(function(err) {
            console.error("games error (leave)");
            console.dir(err);
            process.exit(1);
        });
    }
    if (games.length == 0) {
        done();
    }
}

var game2p;
function createGame2P(done) {
    var a0 = client.games.asArray();
    if (a0.length != 0) {
        console.error("no active games at startup");
        process.exit(1);
    }
    var g = new ganomede.GanomedeGame({
        type: client.options.games.type,
        players: [ "testuser", "testuser2" ]
    });
    console.log("create 2 players game");
    client.games.add(g)
    .then(function(res) {
        var a1 = client.games.asArray();
        if (a1.length != 0) {
            console.error("still no active games");
            process.exit(1);
        }
        if (!g.id || !g.url) {
            console.log("game id and url should have been generated");
            process.exit(1);
        }
        game2p = g;
        done();
    })
    .error(function(err) {
        console.error("games error (addGame)");
        console.dir(err);
        process.exit(1);
    });
}

function createTurnGame2P(done) {
    var g = new ganomede.GanomedeTurnGame().fromGame(game2p);
    console.log("create 2 players turngame");
    client.turngames.add(g)
    .then(function(res) {
        if (g.turn != game2p.players[0] && g.turn != game2p.players[1]) {
            console.log("it should be to one of the players to play");
            console.log(g.turn, game2p.players);
            process.exit(1);
        }
        if (g.gameData.stock.pieces.length != 33) {
            console.log("stock should have 33 pieces");
            process.exit(1);
        }
        done();
    })
    .error(function(err) {
        console.error("turngames error (addGame)");
        console.dir(err);
        process.exit(1);
    });
}

function createGame1P(done) {
    var a0 = client.games.asArray();
    if (a0.length != 0) {
        console.error("no active games at startup");
        process.exit(1);
    }
    var g = new ganomede.GanomedeGame({
        type: client.options.games.type,
        players: [ "testuser" ]
    });
    client.games.add(g)
    .then(function(res) {
        var a1 = client.games.asArray();
        if (a1.length != 1) {
            console.error("there should be 1 active games");
            console.dir(a1);
            process.exit(1);
        }
        if (!g.id || !g.url) {
            console.log("game id and url should have been generated");
            process.exit(1);
        }
        done();
    })
    .error(function(err) {
        console.error("games error (addGame)");
        console.dir(err);
        process.exit(1);
    });
}

function logout(done) {
    console.log("logout");
    client.users.logout();
    done();
}

function done() {
    console.log("All good! We're done.");
    setTimeout(process.exit.bind(process, 0), 1000);
}

//ganomede.net.Ajax.verbose = true;

var testStrategyChain = require("./testStrategyChain");

initialize(
    testStrategyChain.bind(null,
    login.bind(null,
    profile.bind(null,
    refreshInvitations.bind(null,
    invitations.bind(null,
    notifications.bind(null,
    notifications.bind(null,
    refreshGames.bind(null,
    leaveAllGames.bind(null,
    createGame2P.bind(null,
    createTurnGame2P.bind(null,
    createGame1P.bind(null,
    leaveAllGames.bind(null,
    logout.bind(null,
    done
)))))))))))))));

setTimeout(function() {
    console.error("test timeout");
    process.exit(1);
}, 60000);
