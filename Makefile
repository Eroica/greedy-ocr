CC=clang

FRAMEWORKS:= -framework Foundation
LIBRARIES:= -lobjc `pkg-config --libs --cflags opencv`

SOURCE=TextDetection.m main.m ray.m chain.m

# CFLAGS=-Wall -Werror -g -v $(SOURCE)
CFLAGS=-Wall -Werror -Wno-unused-function
LDFLAGS=$(LIBRARIES) $(FRAMEWORKS)
OUT=-o main

all:
	$(CC) $(CFLAGS) $(LDFLAGS) -ObjC $(SOURCE) $(OUT)


#clang -o main TextDetection.m main.m -fobjc-arc -framework Foundation `pkg-config --libs --cflags opencv`