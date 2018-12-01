##
## Verilator Rules
##
.PHONY: all
#.DELETE_ON_ERROR:
TOPMOD  := ttt
VLOGFIL := $(TOPMOD).v
VCDFILE := $(TOPMOD).vcd
SIMPROG := $(TOPMOD)_tb
SIMFILE := $(SIMPROG).cpp
VDIRFB  := ./obj_dir
COSIMS  := uartsim.cpp
all: $(VCDFILE)

GCC := g++
CFLAGS = -g -Wall -I$(VINC) -I $(VDIRFB)
#
# Modern versions of Verilator and C++ may require an -faligned-new flag
# CFLAGS = -g -Wall -faligned-new -I$(VINC) -I $(VDIRFB)

VERILATOR=verilator
VFLAGS := -O3 -MMD --trace -Wall

## Find the directory containing the Verilog sources.  This is given from
## calling: "verilator -V" and finding the VERILATOR_ROOT output line from
## within it.  From this VERILATOR_ROOT value, we can find all the components
## we need here--in particular, the verilator include directory
VERILATOR_ROOT ?= $(shell bash -c '$(VERILATOR) -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')
##
## The directory containing the verilator includes
VINC := $(VERILATOR_ROOT)/include

$(VDIRFB)/V$(TOPMOD).cpp: $(TOPMOD).v xmove.v movemask.v user.v
	$(VERILATOR) $(VFLAGS) -cc --top-module $(TOPMOD) $(VLOGFIL)

$(VDIRFB)/V$(TOPMOD)__ALL.a: $(VDIRFB)/V$(TOPMOD).cpp
	make --no-print-directory -C $(VDIRFB) -f V$(TOPMOD).mk

$(SIMPROG): $(SIMFILE) $(VDIRFB)/V$(TOPMOD)__ALL.a $(COSIMS)
	$(GCC) $(CFLAGS) $(VINC)/verilated.cpp				\
		$(VINC)/verilated_vcd_c.cpp $(SIMFILE) $(COSIMS)	\
		$(VDIRFB)/V$(TOPMOD)__ALL.a -o $(SIMPROG)

test: $(VCDFILE)

$(VCDFILE): $(SIMPROG)
	./$(SIMPROG)

## 
.PHONY: clean
clean:
	rm -rf $(VDIRFB)/ $(SIMPROG) $(VCDFILE) ttt/ 
	rm -f moves.txt xmove.v
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin
	rm -rf ULX3S_45F.json ulx3s_out.config ulx3s.bit

##
## Find all of the Verilog dependencies and submodules
##
DEPS := $(wildcard $(VDIRFB)/*.d)

## Include any of these submodules in the Makefile
## ... but only if we are not building the "clean" target
## which would (oops) try to build those dependencies again
##
ifneq ($(MAKECMDGOALS),clean)
ifneq ($(DEPS),)
include $(DEPS)
endif
endif

# Generate the xmove.v module by
# calculating the best X moves
xmove.v: gen_xmove_module.pl moves.txt
	chmod +x gen_xmove_module.pl
	./gen_xmove_module.pl > xmove.v

moves.txt: gen_moves.pl
	chmod +x gen_moves.pl
	./gen_moves.pl | sort | uniq > moves.txt


##
## The following are rules to make the TinyFPGA bitstream
##
PROJ = TinyFPGA_B2
PIN_DEF = pins.pcf
DEVICE = lp8k

.PHONY: bin
bin: $(PROJ).rpt $(PROJ).bin

%.blif: %.v xmove.v
	yosys -q -p 'synth_ice40 -top $(PROJ) -blif $@' $<

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d 8k -P cm81 -o $@ -p $^

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

.PHONY: prog
prog: $(PROJ).bin
	tinyfpgab --program $<

##
## Rules to make the bitstream for the ULX3S board with an ECP5 45F FPGA

ulx3s.bit: ulx3s_out.config
	ecppack ulx3s_out.config ulx3s.bit

ulx3s_out.config: ULX3S_45F.json
	nextpnr-ecp5 --45k --json ULX3S_45F.json --basecfg ulx3s_empty.config \
		--lpf ulx3s_v20.lpf \
		--textcfg ulx3s_out.config

ULX3S_45F.json: ULX3S_45F.ys ULX3S_45F.v xmove.v
	yosys ULX3S_45F.ys

uprog: ulx3s.bit
	sudo ~wkt/.bin/ujprog *.bit
