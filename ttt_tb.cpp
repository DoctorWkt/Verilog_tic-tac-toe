#include <verilatedos.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <signal.h>
#include "verilated.h"
#include "Vttt.h"
#include "testb.h"

int	main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);
	TESTB<Vttt>	*tb
		= new TESTB<Vttt>;

	tb->opentrace("ttt.vcd");

	for(unsigned clocks=0; clocks < 200; clocks++) {
		tb->tick();
	}
	printf("\n\nSimulation complete\n");
}
