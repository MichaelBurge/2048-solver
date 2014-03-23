home_machine_boost_include_dir = C:/mingw64/include/
SYSINCLUDES = -Isystem$(home_machine_boost_include_dir)
LIBRARIES = -lboost_program_options
TEST_LIBRARIES = -lboost_unit_test_framework

CXX = g++
CFLAGS = -O3 -ggdb -Wall -Wextra -std=c++11 $(SYSINCLUDES)
AS = yasm
ASFLAGS = -f win64

primary_files = solver.o
profiling_options = -p -pg
link = $(CXX) $(CFLAGS) $^ -o $@

all: main.exe

%.o: %.cpp
	$(CXX) $(CFLAGS) -o $@ -c $<
%.o: %.asm
	$(AS) $(ASFLAGS) -o $@ $<

main.exe: $(primary_files) main.o
	$(link) $(LIBRARIES)

test_solver.exe: $(primary_files) tests/solver.o
	$(link) $(LIBRARIES) $(TEST_LIBRARIES)

test: test_solver.exe
	./test_solver.exe

%.s: %.cpp
	$(CXX) -mpopcnt -O3 -Wall -Wextra -std=c++11 -fno-exceptions -fno-asynchronous-unwind-tables -Wa,-aslh -S $<
example: example.s
	true
clean:
	rm $(primary_files) main.o main.exe test_solver.exe tests/solver.o example.s
