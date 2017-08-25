#SunOS GNU C++ Compiler
CC = g++
AR = ar
AR_FLAG = -r
AR2 = ranlib
ARCH64   = -m64
ARCH32   = -m32
SO_FLAG = -fPIC
CFLAGS = $(ARCH)  -ffor-scope -Wno-deprecated -g -O2 
STDLIBS = -lm -lw -lc -lposix4 -ldl -lkvm -lkstat -lsocket -lnsl -lthread -lpthread -lrt
