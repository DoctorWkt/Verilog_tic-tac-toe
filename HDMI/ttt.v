// Tic-tac-toe in Verilog, player versus FPGA.
// Author: Warren Toomey
// (c) 2018, Warren Toomey, GPL3

`default_nettype none
`ifdef VERILATOR

module ttt(i_clk, o_setup, o_uart_tx, i_uart_rx, o_board);
  input wire i_clk;
  output wire [31:0] o_setup; // Tell UART co-sim about clocks per baud
  output wire o_uart_tx;    // UART transmit signal line
  input  wire i_uart_rx;    // UART receive signal line
  output wire [17:0] o_board;
`else

module ttt(i_clk, o_uart_tx, i_uart_rx, o_board);
  input wire i_clk;
  output wire o_uart_tx;    // UART transmit signal line
  input  wire i_uart_rx;    // UART receive signal line
  output wire [17:0] o_board;
`endif

  parameter CLOCK_RATE_HZ = 1000000;	// System clock rate in Hz
  parameter BAUD_RATE = 115_200;	// 115.2 KBaud
  parameter CLOCKS_PER_BAUD = CLOCK_RATE_HZ/BAUD_RATE;
`ifdef VERILATOR
  assign o_setup = CLOCKS_PER_BAUD;
`endif

  reg [17:0] board;			// Current board state
  initial board= 18'd0;			// and its initial value
					// Nine bitpairs. Each pair:
					// 00 is empty, 01 is O (user),
					// 11 is FPGA (X)
  assign o_board = board;

  localparam INITIALISE_STATE = 5'h0;	// List of state names
  localparam ASK_USER_MOVE    = 5'h1;
  localparam GET_USER_MOVE    = 5'h2;	
  localparam MAKE_USER_MOVE   = 5'h3;	
  localparam CHECK_USER_MOVE  = 5'h4;	
  localparam MAKE_X_MOVE      = 5'h5;	
  localparam CHECK_X_MOVE     = 5'h6;	
  localparam WAIT_FOR_USER    = 5'h1a;
  localparam WAIT_FOR_USER2   = 5'h1b;
  localparam WIN_STATE        = 5'h1c;	
  localparam LOSE_STATE       = 5'h1d;	
  localparam DRAW_STATE       = 5'h1e;	
  localparam ERROR_STATE      = 5'h1f;	

  reg [4:0] state;			// Game state, one of the above list
  initial state= INITIALISE_STATE;

  reg [17:0] oldboard;			// Previous board state, used
					// to see if user moved on an
					// existing square

  reg [1:0] result;			// Result of the game
  localparam NONE = 0;			
  localparam XWIN = 1;			
  localparam OWIN = 2;
  localparam DRAW = 3;

  reg result_stb;			// Strobe user.v when there is
  initial result_stb=0;			// a result (win, lose or draw)

  reg need_userinput;			// High when we need a user move
  initial need_userinput=0;

  wire user_busy;			// If true, can't do user I/O
  wire [3:0] user_move;			// Move made by the user
  wire usermove_stb;			// Strobe to indicate user move
					// is available from user.v

  wire [17:0] user_move_mask;		// 18-bit version of user move
  wire bad_user_move;			// Flag if user's move is bad

  wire [3:0] x_move;			// Move made by the FPGA
  wire [17:0] x_move_mask;		// 18-bit version of FPGA move
  wire bad_x_move;			// XXX: Should never get used!

  // Wire up the user interface module
  user #(CLOCKS_PER_BAUD[23:0])
       u1(i_clk, o_uart_tx, i_uart_rx, board, result, result_stb,
          need_userinput, user_busy, user_move, usermove_stb);

  // Wire up the X move module
  xmove g1(board, x_move);

  // Wire up the board result module
  result r1(board, result);

  // Wire up the decimal to bitmask user move logic
  movemask m1(user_move, 0, user_move_mask, bad_user_move);

  // Wire up the decimal to bitmask FPGA move logic
  movemask m2(x_move, 1, x_move_mask, bad_x_move);

  // Main FSM for the whole game
  always @(posedge i_clk)
    case (state)
      INITIALISE_STATE: begin
   	board <= 18'd0;			// Set up the board
	result_stb <= 0;		// No result yet
	state <= ASK_USER_MOVE;
      end

      ASK_USER_MOVE: begin
	need_userinput <= 1;		// We need user input
	state <= GET_USER_MOVE;
      end

      GET_USER_MOVE: begin
	if (!user_busy && usermove_stb) begin	// We've got user input
	  need_userinput <= 0;			// Stop asking for it
	  state <= MAKE_USER_MOVE;
	end
      end

      MAKE_USER_MOVE: begin
	if (bad_user_move)		// Move was out of range, go back
	  state <= ASK_USER_MOVE;
	else begin			// Otherwise update board with move
	  oldboard <= board;			// Take a copy of the board
	  board <= board | user_move_mask;	// Apply the user's move
	  state <= CHECK_USER_MOVE;
	end
      end
					// Note: if a user move (01) ORs
					// over the top of itself, or an
					// existing X (11) move, the board
					// won't change. Hence the
					// board == oldboard test will be true

      CHECK_USER_MOVE: begin
	if (board == oldboard)		// User's move didn't change the
	  state <= ASK_USER_MOVE;	// board, ask for a move again
	else if (result == DRAW)
	  state <= DRAW_STATE;		// It's a draw
	else if (result == OWIN)
	  state <= LOSE_STATE;		// User won, how did this happen??!
	else
	  state <= MAKE_X_MOVE;
      end

      MAKE_X_MOVE: begin
	if (bad_x_move)			// Could not find a move, this
	  state <= ERROR_STATE;		// should never happen
	else begin
	  board <= board | x_move_mask;	// Make the FPGA's move
	  state <= CHECK_X_MOVE;
	end
      end

      CHECK_X_MOVE: begin
	if (result == DRAW)
          state <= DRAW_STATE;          // It's a draw
	else if (result == XWIN)
	  state <= WIN_STATE;		// We wow, yay!
	else
	  state <= ASK_USER_MOVE;
      end

      WIN_STATE: begin
	result_stb <= 1;		// Signal a result
	state <= WAIT_FOR_USER;		// Start drawing the board
      end

      LOSE_STATE:			// XXX: Should never happen
	state <= INITIALISE_STATE;

      DRAW_STATE: begin
	result_stb <= 1;		// Signal a result
	state <= WAIT_FOR_USER;		// Start drawing the board
      end

      WAIT_FOR_USER: begin
	result_stb <= 0;
	state <= WAIT_FOR_USER2;	// Takes a tick for user_busy
      end

      WAIT_FOR_USER2:
	if (!user_busy)			// Wait for the display to be done
	  state <= INITIALISE_STATE;

      ERROR_STATE:			// XXX: Should never happen
        state <= INITIALISE_STATE;

      default:				// XXX: Should never happen
        state <= INITIALISE_STATE;
    endcase
endmodule
