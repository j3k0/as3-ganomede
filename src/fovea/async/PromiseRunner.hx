package fovea.async;

@:expose
interface PromiseRunner
{
    function run(promise:Void->Promise):Promise;
}
// vim: sw=4:ts=4:et:
