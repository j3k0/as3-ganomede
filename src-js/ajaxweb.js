var ajax = require("../bin/ajax");

var ajaxWeb = {};
var ajaxes = {};
var ajaxRequest = ajaxWeb.ajaxRequest = function(reqId, baseUrl, method, path, options) {
    var a = ajaxes[baseUrl];
    if (!a)
        a = ajaxes[baseUrl] = new fovea.net.Ajax(baseUrl);
    console.log("ajax[" + reqId + "] " + method + " " + baseUrl + "/" + path);
    if (options)
        console.log("ajax[" + reqId + "] options:" + JSON.stringify(options));
    a.ajax(method, path, options)
    .then(function(outcome) {
        console.log("ajax[" + reqId + "] outcome:" + JSON.stringify(outcome));
        ajaxOnSuccess({
            reqId: reqId,
            outcome: outcome
        });
    })
    .error(function(err) {
        console.log("ajax[" + reqId + "] err:" + JSON.stringify(err));
        if (typeof err.data == "string") {
            try {
                err.data = JSON.parse(err.data);
            }
            catch (e) {
                console.log("ajax[" + reqId + "] err.data isn't valid JSON");
            }
        }
        ajaxOnError({
            reqId: reqId,
            err: err
        });
    });
};

var flashObject = null;

var ajaxInitialize = ajaxWeb.ajaxInitialize = function(pFlashObject) {
    flashObject = pFlashObject;
};

var ajaxOnSuccess = function(data) {
    document.getElementById(flashObject).ajaxOnSuccess(data);
}

var ajaxOnError = function(data) {
    document.getElementById(flashObject).ajaxOnError(data);
}

module.exports = ajaxWeb;

if (typeof window != 'undefined') {
    window.ajaxRequest = ajaxRequest;
    window.ajaxInitialize = ajaxInitialize;
}
