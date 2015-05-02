var haxe = require("./bin/ganomede");

haxe.fovea.ganomede.utils = haxe.fovea.utils;
haxe.fovea.ganomede.net = haxe.fovea.net;
haxe.fovea.ganomede.async = haxe.fovea.async;

haxe.fovea.ganomede.createClient = function(url, options) {
    return new haxe.fovea.ganomede.Ganomede(url, options);
};

module.exports = haxe.fovea.ganomede;
