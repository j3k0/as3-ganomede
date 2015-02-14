help:
	@echo make run ..... Runs the app
	@echo make build ... Compiles the app
	@echo make clean ... Cleanup binaries

build:
	@mkdir -p bin
	amxmlc -output bin/Main.swf src/Main.as -compiler.source-path src/

run: build
	adl src/Main-app.xml bin

clean:
	rm -fr bin
