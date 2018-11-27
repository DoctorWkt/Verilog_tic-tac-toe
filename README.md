# Verilog Tic Tac Toe

This is an implementation of "Tic Tac Toe" in Verilog. The user plays against
the FPGA. The FPGA knows what is the best next move, and should always win
or draw against the user.

It's a work in progress. Right now it runs under Verilator but eventually I
want to synthesise it and get it to run on a TinyFPGA B2 board.

The ```gen_moves.pl``` works out the best X moves for each board state,
producing a ```moves.txt``` file. The ```gen_xmove_module.pl``` script
uses this to create the ```gen_xmove.v``` module.

The top-level module is ```ttt.v``` which is basically a large FSM
that gets a user move, validates it, updates the board, passes the board
to ```gen_xmove.v``` to get the X move, updates the board, and loops back.

The ```user.v``` module deals with user input and output. Right now I'm using
$display and $fgetc, but eventually I will add a UART module, and change this
to have a FSM to send strings, and to read characters from the UART.
