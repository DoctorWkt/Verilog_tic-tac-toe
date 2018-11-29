// Combinatorial logic to determine if a
// board layout is a win for X, a win for O, a
// draw or none of the above.
//
// Author: Warren Toomey
// (c) 2018, Warren Toomey, GPL3

`default_nettype none

module result(i_board, o_result);
  input wire [17:0] i_board;
  output reg [1:0] o_result;

  localparam NONE = 0;
  localparam XWIN = 1;
  localparam OWIN = 2;
  localparam DRAW = 3;

  // An X move is 11, an O move is 01 on the board

  always @(*)
    // See if we have the right bit pattens for X wins and O wins
    if ((i_board & 18'b111111000000000000) == 18'b111111000000000000)
      o_result = XWIN;
    else if ((i_board & 18'b111111000000000000) == 18'b010101000000000000)
      o_result = OWIN;
    else if ((i_board & 18'b000000111111000000) == 18'b000000111111000000)
      o_result = XWIN;
    else if ((i_board & 18'b000000111111000000) == 18'b000000010101000000)
      o_result = OWIN;
    else if ((i_board & 18'b000000000000111111) == 18'b000000000000111111)
      o_result = XWIN;
    else if ((i_board & 18'b000000000000111111) == 18'b000000000000010101)
      o_result = OWIN;
    else if ((i_board & 18'b110000110000110000) == 18'b110000110000110000)
      o_result = XWIN;
    else if ((i_board & 18'b110000110000110000) == 18'b010000010000010000)
      o_result = OWIN;
    else if ((i_board & 18'b001100001100001100) == 18'b001100001100001100)
      o_result = XWIN;
    else if ((i_board & 18'b001100001100001100) == 18'b000100000100000100)
      o_result = OWIN;
    else if ((i_board & 18'b000011000011000011) == 18'b000011000011000011)
      o_result = XWIN;
    else if ((i_board & 18'b000011000011000011) == 18'b000001000001000001)
      o_result = OWIN;
    else if ((i_board & 18'b110000001100000011) == 18'b110000001100000011)
      o_result = XWIN;
    else if ((i_board & 18'b110000001100000011) == 18'b010000000100000001)
      o_result = OWIN;
    else if ((i_board & 18'b000011001100110000) == 18'b000011001100110000)
      o_result = XWIN;
    else if ((i_board & 18'b000011001100110000) == 18'b000001000100010000)
      o_result = OWIN;

    // See if we have some empty squares still left
    else if ((i_board & 18'b110000000000000000) == 18'b000000000000000000)
      o_result = NONE;
    else if ((i_board & 18'b001100000000000000) == 18'b000000000000000000)
      o_result = NONE;
    else if ((i_board & 18'b000011000000000000) == 18'b000000000000000000)
      o_result = NONE;
    else if ((i_board & 18'b000000110000000000) == 18'b000000000000000000)
      o_result = NONE;
    else if ((i_board & 18'b000000001100000000) == 18'b000000000000000000)
      o_result = NONE;
    else if ((i_board & 18'b000000000011000000) == 18'b000000000000000000)
      o_result = NONE;
    else if ((i_board & 18'b000000000000110000) == 18'b000000000000000000)
      o_result = NONE;
    else if ((i_board & 18'b000000000000001100) == 18'b000000000000000000)
      o_result = NONE;
    else if ((i_board & 18'b000000000000000011) == 18'b000000000000000000)
      o_result = NONE;

    // No winner, no empty squares, must be a draw
    else o_result = DRAW;
endmodule
