HAXE_MAIN=fovea.ganomede.GanomedeClient fovea.async.Waterfall

help:
	@echo make run ..... Runs the app
	@echo make build ... Compiles the app
	@echo make clean ... Cleanup binaries

swc:
	@mkdir -p bin
	./haxe -swf bin/ganomede.swc -dce no -cp src -cp lib/openfl ${HAXE_MAIN}

js:
	@mkdir -p bin
	./haxe -js bin/ganomede.js -dce no -cp src -cp lib/openfl ${HAXE_MAIN}

build: swc
	@mkdir -p bin
	amxmlc -output bin/Main.swf src-as3/Main.as -compiler.source-path src-as3/ -compiler.library-path bin/ganomede.swc

run: build
	adl src/Main-app.xml bin

clean:
	rm -fr bin
