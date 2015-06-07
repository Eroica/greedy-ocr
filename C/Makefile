CC=clang
CXX=clang++
CFLAGS=-Wall -Werror -Wno-unused-function -Wno-unused-variable -g
CXXFLAGS=-Wall -Werror -Wno-unused-function -Wno-unused-variable -g -std=c++14 -I.

LIBRARIES:= -lopencv_core -lopencv_highgui -lopencv_imgproc

DEPS=component_analysis.cpp vector.h
OBJ=vector.o text_detection.o component_analysis.o main.o

# RM=rm -f

# compile only, C source
%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

# compile only, C++ source
%.o: %.cpp $(DEPS)
	$(CXX) -c -o $@ $< $(CXXFLAGS)

# link
main: $(OBJ)
	$(CXX) $(LIBRARIES) -o $@ $^ $(CXXFLAGS)

# clean:
#     $(RM) $(OBJ)


# CC=clang++

# #FRAMEWORKS:= -framework Foundation
# #LIBRARIES:= -lobjc `pkg-config --libs --cflags opencv`
# LIBRARIES:= -lopencv_core -lopencv_highgui -lopencv_imgproc
# #LIBRARIES:= -lopencv_core -lopencv_highgui -lopencv_imgproc


# #SOURCE=TextDetection.m main.m ray.m chain.m points.m graph.c list.c
# SOURCE=text_detection.c component_analysis.cpp vector.c main.c


# # CFLAGS=-Wall -Werror -g -v $(SOURCE)
# CFLAGS=-Wall -Werror -Wno-unused-function -Wno-unused-variable
# LDFLAGS=$(LIBRARIES) $(FRAMEWORKS)
# OUT=-o main

# all:
# 	#clang++ $(CFLAGS) $(LDFLAGS) $(CPP_SOURCE)
# 	$(CC) $(CFLAGS) $(LDFLAGS) $(SOURCE) $(OUT)
# #	$(CC) $(CFLAGS) $(OUT) $(SOURCE) $(LDFLAGS) -I. -std=c++14

# #clang -o main TextDetection.m main.m -fobjc-arc -framework Foundation `pkg-config --libs --cflags opencv`