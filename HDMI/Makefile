YOSYS=yosys
NEXTPNR=nextpnr-ecp5
ECPPACK=ecppack

.PHONY: all
all: ulx3s_45f_ttt.bit

# Generate the xmove.v module by
# calculating the best X moves
moves.txt: ../gen_moves.pl
	chmod +x ../gen_moves.pl
	../gen_moves.pl | sort | uniq > moves.txt

xmove.v: ../gen_xmove_module.pl moves.txt
	chmod +x ../gen_xmove_module.pl
	../gen_xmove_module.pl > xmove.v

ttt.ys: xmove.v ULX3S_45F.v ttt.v user.v xmove.v movemask.v ../result.v \
		DVI_3x3.v TMDS_encoder.v clock.v OBUFDS.v
	chmod +x ysgen.sh
	./ysgen.sh ULX3S_45F.v ttt.v user.v xmove.v movemask.v ../result.v \
		DVI_3x3.v TMDS_encoder.v clock.v OBUFDS.v  > ttt.ys
	echo "hierarchy -top ULX3S_45F" >> ttt.ys
	echo "synth_ecp5 -json ttt.json" >> ttt.ys

ttt.json: ttt.ys
	$(YOSYS) -q ttt.ys

ulx3s_45f_ttt.config: ttt.json
	$(NEXTPNR) --45k --json ttt.json --lpf ulx3s_v20_segpdi.lpf \
		--basecfg ../ulx3s_empty.config --textcfg ulx3s_45f_ttt.config

ulx3s_45f_ttt.bit: ulx3s_45f_ttt.config
	$(ECPPACK) --input ulx3s_45f_ttt.config --bit ulx3s_45f_ttt.bit
        
.PHONY: clean
clean:
	rm -f ttt.ys moves.txt xmove.v ttt.json ulx3s_45f_ttt.config \
		ulx3s_45f_ttt.bit
