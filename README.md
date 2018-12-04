# Verilog Tic Tac Toe

This is an implementation of "Tic Tac Toe" (noughts and crosses) in Verilog.
The user plays against the FPGA. The FPGA knows what is the best next move,
and should always win or draw against the user.

The ```gen_moves.pl``` works out the best X moves for each board state,
producing a ```moves.txt``` file. The ```gen_xmove_module.pl``` script
uses this to create the ```xmove.v``` module.

The top-level module is ```ttt.v``` which is basically a large FSM
that gets a user move, validates it, updates the board, passes the board
to ```xmove.v``` to get the X move, updates the board, and loops back.

The ```user.v``` module deals with user input and output. It uses the
UART modules written by Dan Gisselquist.

The ```result.v``` module takes the board state and returns any result:
X wins, O wins, a draw or no result yet.

The ```movemask.v``` converts a user's move in decimal into a bit pattern
which can be ORed onto the 18-bit board state.

The project can be simulated in Verilator, and it now synthesises and runs
on my TinyFPGA B2 and ULX3S FPGA boards. Note for the ULX3S: you need to
disable hardware flow control on the serial connection to the board.
With _minicom_, ctrl-A O, Serial port setup, F, Exit.

## ULX3S HDMI Version

In the _HDMI_ folder you will find a version of the code with HDMI display
for the ULX3S board. This was contributed by
[emard](https://github.com/emard/). There is still a serial port user
interface, but the board is also shown as nine coloured squares on the
HDMI output.

Note: the squares are renumbered to to reflect the numeric keypad on
most PC keyboards: top row is 7, 8, 9; bottom row is 1, 2, 3.
