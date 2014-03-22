primary_files =
home_machine_boost_include_dir = C:/mingw64/include/
options = -O0 -ggdb -Wall -Wextra -std=c++11 -Isystem$(home_machine_boost_include_dir)
profiling_options = -p -pg
compile = g++ $(options) -o $@ -c $<
libraries =  -lmingw32 -lSDL2main -lSDL2 -lgdi32 -lwinmm -limm32 -lole32 -lversion -loleaut32 -lboost_program_options
link = g++ $(options)  $^ -o $@

all: main.exe

%.o: %.cpp
	$(compile)

main.exe: $(primary_files) main.o
	$(link) $(libraries)

clean:
	rm $(primary_files) main.o main.exe
