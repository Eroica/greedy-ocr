CC=clang++

#FRAMEWORKS:= -framework Foundation
#LIBRARIES:= -lobjc `pkg-config --libs --cflags opencv`
#LIBRARIES:= -lopencv_core -lopencv_highgui -lopencv_imgproc
LIBRARIES:= -lopencv_core -lopencv_highgui -lopencv_imgproc


#SOURCE=TextDetection.m main.m ray.m chain.m points.m graph.c list.c

SOURCE=TextDetection.cpp FeaturesMain.cpp

# CFLAGS=-Wall -Werror -g -v $(SOURCE)
CFLAGS=-Wall -Werror -Wno-unused-function -Wno-unused-variable
LDFLAGS=$(LIBRARIES) $(FRAMEWORKS)
OUT=-o main

all:
#	$(CC) $(CFLAGS) $(LDFLAGS) -ObjC $(SOURCE) $(OUT)
	$(CC) $(CFLAGS) $(OUT) $(SOURCE) $(LDFLAGS) -I. -std=c++14

#clang -o main TextDetection.m main.m -fobjc-arc -framework Foundation `pkg-config --libs --cflags opencv`