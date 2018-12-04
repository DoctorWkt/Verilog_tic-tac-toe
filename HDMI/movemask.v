// Combinatorial logic to convert a move from
// decimal 1-9 into a 18-bit move for the user.
// Indicate bad moves as well.
//
// Author: Warren Toomey
// (c) 2018, Warren Toomey, GPL3

`default_nettype none

module movemask(i_move, i_user, o_mask, o_bad_move);
  input wire [3:0] i_move;
  input wire i_user;
  output reg [17:0] o_mask;
  output reg o_bad_move;

  wire [17:0] bitmove;		// 2-bit move mask
  assign bitmove= (i_user == 1) ? 18'd3 : 18'd1;	// X is 11, O is 01

  // user input layout from PC numpad: 789/456/123
  always @(*)
    case (i_move)
      4'd1: begin
	o_mask = 18'd0 | (bitmove << 16); o_bad_move = 0;
      end
      4'd2: begin
	o_mask = 18'd0 | (bitmove << 14); o_bad_move = 0;
      end
      4'd3: begin
	o_mask = 18'd0 | (bitmove << 12); o_bad_move = 0;
      end
      4'd4: begin
	o_mask = 18'd0 | (bitmove << 10); o_bad_move = 0;
      end
      4'd5: begin
	o_mask = 18'd0 | (bitmove << 8); o_bad_move = 0;
      end
      4'd6: begin
	o_mask = 18'd0 | (bitmove << 6); o_bad_move = 0;
      end
      4'd7: begin
	o_mask = 18'd0 | (bitmove << 4); o_bad_move = 0;
      end
      4'd8: begin
	o_mask = 18'd0 | (bitmove << 2); o_bad_move = 0;
      end
      4'd9: begin
	o_mask = 18'd0 | (bitmove << 0); o_bad_move = 0;
      end
      default: begin
	o_mask = 0; o_bad_move = 1;
      end
    endcase
endmodule
