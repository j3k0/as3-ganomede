var ganomede = require("../index");

function assert(msg, ok) {
    if (!ok) {
        console.log("assertion failed: " + msg);
        process.exit(1);
    }
}

module.exports = function(done) {
    var sc = new ganomede.utils.StrategyChain([
        new ganomede.utils.Strategy(
            function(obj) { return obj.ok; },
            function(odj) { obj.executed = true; }
        )
    ]);
    assert("canExecute", sc.canExecute({ ok:true }));
    assert("canExecute", !sc.canExecute({ ok:false }));
    var obj = {};
    sc.execute(obj);
    assert("execute", !obj.executed);
    obj.ok = true;
    sc.execute(obj);
    assert("execute", obj.executed);
    done();
}
