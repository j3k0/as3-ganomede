var ganomede = require("../index");
var client = null;
var user = null;

var serverUrl = process.env.GANOMEDE_TEST_SERVER_URL;
if (!serverUrl) {
    console.error("Please specify your test server URL in GANOMEDE_TEST_SERVER_URL environment variable");
    process.exit(1);
}

function initialize(done) {
    client = new ganomede.GanomedeClient(serverUrl);
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

function done() {
    console.log("All good! We're done.");
}

ganomede.net.Ajax.verbose = true;

initialize(
    login.bind(null,
    profile.bind(null,
    invitations.bind(null,
    done))));

