CC=g++
cflags=-ggdb
assembler: assemble
	$(CC) -o assemble assemble.cpp