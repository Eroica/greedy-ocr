CC=clang
CXX=clang++
CFLAGS=-Wall -Wno-unused-function -Wno-unused-variable -Wreturn-type-c-linkage -g
CXXFLAGS=-Wall -Wno-unused-function -Wno-unused-variable -Wreturn-type-c-linkage -g -std=c++14 -I.

LIBRARIES:= -lopencv_core -lopencv_highgui -lopencv_imgproc

DEPS=text_detection.cpp
OBJ=text_detection.o main.o

RM=rm -f

# compile only, C source
%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

# compile only, C++ source
%.o: %.cpp $(DEPS)
	$(CXX) -c -o $@ $< $(CXXFLAGS)

# link
main: $(OBJ)
	$(CXX) $(LIBRARIES) -o $@ $^ $(CXXFLAGS)

clean:
	$(RM) $(OBJ)