
BIN_PATH=/opt/bin

all:
	echo MAY HAVE TO RUN AS ROOT!
	mkdir -p $(BIN_PATH)
	chmod 777 ./bin/*
	cp -fv ./bin/*.* $(BIN_PATH)
