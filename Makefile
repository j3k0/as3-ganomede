HAXE_MAIN=fovea.ganomede.GanomedeClient fovea.async.Waterfall

help:
	@echo make run ..... Runs the app
	@echo make build ... Compiles the app
	@echo make clean ... Cleanup binaries

bin/ganomede.swc:
	@mkdir -p bin
	./haxe -swf bin/ganomede.swc -dce no -lib openfl -cp src ${HAXE_MAIN}

bin/ganomede-as3:
	@mkdir -p bin
	./haxe -as3 bin/ganomede-as3 -dce no -lib openfl -cp src ${HAXE_MAIN}

swc:
	@mkdir -p bin
	./haxe -swf bin/ganomede.swc -dce no -lib openfl -cp src ${HAXE_MAIN}

as3:
	@mkdir -p bin
	./haxe -as3 bin/ganomede-as3 -dce no -lib openfl -cp src ${HAXE_MAIN}

js:
	@mkdir -p bin
	@#./haxe -js bin/ganomede.js -dce no -lib openfl -cp lib/js-kit -cp src ${HAXE_MAIN}
	./haxe -js bin/ganomede.js -lib openfl -cp lib/js-kit -cp src ${HAXE_MAIN}

build: swc
	@mkdir -p bin
	./amxmlc -output bin/Main.swf src-as3/Main.as -compiler.source-path src-as3/ -compiler.library-path bin/ganomede.swc

run: build
	./adl src/Main-app.xml bin

clean:
	rm -fr bin
