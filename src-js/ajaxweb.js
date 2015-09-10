var ajax = require("../bin/ajax");

var ajaxWeb = {};
var ajaxRequest = ajaxWeb.ajaxRequest = function(reqId, method, path, options) {
};

var ajaxOnSuccess = function() {
    document.getElementById("flashObject").ajaxOnSuccess(arguments);
}

var ajaxOnError = function() {
    document.getElementById("flashObject").ajaxOnError(arguments);
}

module.exports = ajaxWeb;

if (typeof window != 'undefined') {
    window.aaajaxxx = ajax;
    window.ajaxRequest = ajaxRequest;
}
