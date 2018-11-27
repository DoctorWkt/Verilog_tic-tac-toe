// User I/O module for Tic-tac-toe
// Author: Warren Toomey
// (c) 2018, Warren Toomey, GPL3

// This is the module that deals with the user.
// When i_result_stb strobes high, show the
// board to the user and any result or draw.
// When i_needinput is high and the user makes
// a move, set o_move and strobe o_validmove_stb.

`default_nettype none
module user(i_clk, i_board, i_result, i_isdraw,
	    i_result_stb, i_needinput, o_busy,
	    o_move, o_validmove_stb);

  input wire i_clk;		// Global clock
  input wire [17:0] i_board;	// State of the game board
  input wire [1:0] i_result;	// If non-zero, game result (win/lose)
  input wire  i_isdraw;		// If non-zero, was a draw
  input wire  i_result_stb;	// If non-zero, above 2 are valid
  input wire  i_needinput;	// If non-zero, top level needs input
  output reg o_busy;		// If non-zero, we are busy, ignore i_needinput
  output reg [3:0] o_move;	// Move made by user, when o_validmove_stb
  output reg o_validmove_stb;	// is high the move is valid
  initial o_validmove_stb=0;
  initial o_busy=0;

  integer fh;			// The filehandle connected to stdin
/* verilator lint_off UNUSED */
  reg [7:0] wide_char;		// Storage for each char typed by user
/* verilator lint_on UNUSED */

  // Open stdin for reading
  initial begin
    fh= $fopen("/dev/stdin","r");
    if (fh == -1) begin
      $display("Can't open stdin for reading"); $finish;
    end
  end

  // Convert each board bitpair into ASCII characters
  wire [7:0] square[1:9];

  localparam SP = 8'h20;
  localparam O  = 8'h4f;
  localparam X  = 8'h58;

  assign square[1] = (i_board[17:16]== 2'b00) ? " " :
		     (i_board[17:16]== 2'b01) ? O  : X;
  assign square[2] = (i_board[15:14]== 2'b00) ? SP :
		     (i_board[15:14]== 2'b01) ? O  : X;
  assign square[3] = (i_board[13:12]== 2'b00) ? SP :
		     (i_board[13:12]== 2'b01) ? O  : X;
  assign square[4] = (i_board[11:10]== 2'b00) ? SP :
		     (i_board[11:10]== 2'b01) ? O  : X;
  assign square[5] = (i_board[9:8]== 2'b00) ? SP :
		     (i_board[9:8]== 2'b01) ? O  : X;
  assign square[6] = (i_board[7:6]== 2'b00) ? SP :
		     (i_board[7:6]== 2'b01) ? O  : X;
  assign square[7] = (i_board[5:4]== 2'b00) ? SP :
		     (i_board[5:4]== 2'b01) ? O  : X;
  assign square[8] = (i_board[3:2]== 2'b00) ? SP :
		     (i_board[3:2]== 2'b01) ? O  : X;
  assign square[9] = (i_board[1:0]== 2'b00) ? SP :
		     (i_board[1:0]== 2'b01) ? O  : X;

  // i_result values
  localparam NONE = 0;
  localparam XWIN = 1;
  localparam OWIN = 2;

  reg show_instructions;
  initial show_instructions=1;

  always @(posedge i_clk) begin
    // Show the instructions to the user
    if (show_instructions) begin
      $display("Enter a move (1 to 9), then Enter.");
      show_instructions <=0;
    end

    // Print the board out when we need input or there is a result
    if (i_result_stb || (i_needinput && !o_validmove_stb)) begin
      $display(" %c | %c | %c", square[1], square[2], square[3]);
      $display("---+---+---");
      $display(" %c | %c | %c", square[4], square[5], square[6]);
      $display("---+---+---");
      $display(" %c | %c | %c\n", square[7], square[8], square[9]);
    end

    if (i_needinput && !o_validmove_stb) begin
      // Get a character from the user. Need to hit Enter also.
      wide_char <= $fgetc(fh);
      o_move <= wide_char[3:0];
      o_validmove_stb <= 1;
    end

    // Drop the strobe on the next clock.
    // Because we are using $display in this version of user.v,
    // there is no real need for o_busy. However, Verilator 
    // complains if we don't use it. So we toggle it below.
    if (o_validmove_stb) begin
      o_validmove_stb <= 0;
      o_busy <= 1;
    end

    // Drop the busy on the next clock
    if (o_busy) begin
      o_busy <= 0;
    end

    // Announce a draw
    if (i_result_stb && i_isdraw) $display("The game is a draw.");

    // Announce a win
    if (i_result_stb && i_result == XWIN) $display("The FPGA wins.");

    // Announce a user win
    if (i_result_stb && i_result == OWIN) $display("Somehow, you won.");
  end
endmodule
