// Code to communicate board state and game
// state to user, and to get their moves.
// Author: Warren Toomey
// (c) 2018, Warren Toomey, GPL3

`default_nettype none

`ifndef	VERILATOR
`include "txuartlite.v"
`include "rxuartlite.v"
`endif


module user(i_clk, o_uart_tx, i_uart_rx,
	i_board, i_result, i_result_stb, i_needinput,
	o_busy, o_move, o_validmove_stb
);

  parameter CLOCKS_PER_BAUD = 24'd868;	// # of clocks per UART baud clock

  input wire i_clk;             // Global clock
  input wire [17:0] i_board;    // State of the game board
  input wire [1:0] i_result;    // If non-zero, game result (win/lose/draw)
  input wire  i_result_stb;     // If non-zero, above 2 are valid
  input wire  i_needinput;      // If non-zero, top level needs input
  output reg o_busy;            // If non-zero, we are busy, ignore i_needinput
  output reg [3:0] o_move;      // Move made by user, when o_validmove_stb
  output reg o_validmove_stb;   // If high, the move is valid
  output  wire    o_uart_tx;	// UART transmit signal line
  input   wire    i_uart_rx;	// UART receive signal line

  initial o_busy=1;		// We are busy to start with and
  initial o_validmove_stb=0;	// We don't have a valid move

  /* verilator lint_off UNUSED */
  wire [7:0] rx_data;          	// Each char typed by user, not all bits used
  /* verilator lint_on UNUSED */
  wire rx_avail;		// If true, user data is available

  reg [3:0] keymap [0:15];

  initial begin
      $readmemh("keymap.mem", keymap);
  end

  // List of available strings
  reg[7:0] Str[0:154];
  initial Str[0] = "E";		// Instructions string
  initial Str[1] = "n";
  initial Str[2] = "t";
  initial Str[3] = "e";
  initial Str[4] = "r";
  initial Str[5] = " ";
  initial Str[6] = "a";
  initial Str[7] = " ";
  initial Str[8] = "m";
  initial Str[9] = "o";
  initial Str[10] = "v";
  initial Str[11] = "e";
  initial Str[12] = " ";
  initial Str[13] = "(";
  initial Str[14] = "1";
  initial Str[15] = " ";
  initial Str[16] = "t";
  initial Str[17] = "o";
  initial Str[18] = " ";
  initial Str[19] = "9";
  initial Str[20] = ")";
  initial Str[21] = ",";
  initial Str[22] = " ";
  initial Str[23] = "t";
  initial Str[24] = "h";
  initial Str[25] = "e";
  initial Str[26] = "n";
  initial Str[27] = " ";
  initial Str[28] = "E";
  initial Str[29] = "n";
  initial Str[30] = "t";
  initial Str[31] = "e";
  initial Str[32] = "r";
  initial Str[33] = ".";
  initial Str[34] = 10;
  initial Str[35] = 10;
  initial Str[36] = 0;
  initial Str[37] = " ";		// Board string
  initial Str[38] = "#";
  initial Str[39] = " ";
  initial Str[40] = "|";
  initial Str[41] = " ";
  initial Str[42] = "#";
  initial Str[43] = " ";
  initial Str[44] = "|";
  initial Str[45] = " ";
  initial Str[46] = "#";
  initial Str[47] = 10;
  initial Str[48] = "-";
  initial Str[49] = "-";
  initial Str[50] = "-";
  initial Str[51] = "+";
  initial Str[52] = "-";
  initial Str[53] = "-";
  initial Str[54] = "-";
  initial Str[55] = "+";
  initial Str[56] = "-";
  initial Str[57] = "-";
  initial Str[58] = "-";
  initial Str[59] = 10;
  initial Str[60] = " ";
  initial Str[61] = "#";
  initial Str[62] = " ";
  initial Str[63] = "|";
  initial Str[64] = " ";
  initial Str[65] = "#";
  initial Str[66] = " ";
  initial Str[67] = "|";
  initial Str[68] = " ";
  initial Str[69] = "#";
  initial Str[70] = 10;
  initial Str[71] = "-";
  initial Str[72] = "-";
  initial Str[73] = "-";
  initial Str[74] = "+";
  initial Str[75] = "-";
  initial Str[76] = "-";
  initial Str[77] = "-";
  initial Str[78] = "+";
  initial Str[79] = "-";
  initial Str[80] = "-";
  initial Str[81] = "-";
  initial Str[82] = 10;
  initial Str[83] = " ";
  initial Str[84] = "#";
  initial Str[85] = " ";
  initial Str[86] = "|";
  initial Str[87] = " ";
  initial Str[88] = "#";
  initial Str[89] = " ";
  initial Str[90] = "|";
  initial Str[91] = " ";
  initial Str[92] = "#";
  initial Str[93] = 10;
  initial Str[94] = 10;
  initial Str[95] = 0;
  initial Str[96] = "T";		// Draw string
  initial Str[97] = "h";
  initial Str[98] = "e";
  initial Str[99] = " ";
  initial Str[100] = "g";
  initial Str[101] = "a";
  initial Str[102] = "m";
  initial Str[103] = "e";
  initial Str[104] = " ";
  initial Str[105] = "i";
  initial Str[106] = "s";
  initial Str[107] = " ";
  initial Str[108] = "a";
  initial Str[109] = " ";
  initial Str[110] = "d";
  initial Str[111] = "r";
  initial Str[112] = "a";
  initial Str[113] = "w";
  initial Str[114] = ".";
  initial Str[115] = 10;
  initial Str[116] = 10;
  initial Str[117] = 0;
  initial Str[118] = "T";		// Win string
  initial Str[119] = "h";
  initial Str[120] = "e";
  initial Str[121] = " ";
  initial Str[122] = "F";
  initial Str[123] = "P";
  initial Str[124] = "G";
  initial Str[125] = "A";
  initial Str[126] = " ";
  initial Str[127] = "w";
  initial Str[128] = "i";
  initial Str[129] = "n";
  initial Str[130] = "s";
  initial Str[131] = ".";
  initial Str[132] = 10;
  initial Str[133] = 10;
  initial Str[134] = 0;
  initial Str[135] = "S";		// Lose string
  initial Str[136] = "o";
  initial Str[137] = "m";
  initial Str[138] = "e";
  initial Str[139] = "h";
  initial Str[140] = "o";
  initial Str[141] = "w";
  initial Str[142] = ",";
  initial Str[143] = " ";
  initial Str[144] = "y";
  initial Str[145] = "o";
  initial Str[146] = "u";
  initial Str[147] = " ";
  initial Str[148] = "w";
  initial Str[149] = "o";
  initial Str[150] = "n";
  initial Str[151] = ".";
  initial Str[152] = 10;
  initial Str[153] = 10;
  initial Str[154] = 0;

  // Convert each board bitpair into ASCII characters
  wire [7:0] square[1:9];

  assign square[1] = (i_board[17:16]== 2'b00) ? " " :
                     (i_board[17:16]== 2'b01) ? "O" : "X";
  assign square[2] = (i_board[15:14]== 2'b00) ? " " :
                     (i_board[15:14]== 2'b01) ? "O" : "X";
  assign square[3] = (i_board[13:12]== 2'b00) ? " " :
                     (i_board[13:12]== 2'b01) ? "O" : "X";
  assign square[4] = (i_board[11:10]== 2'b00) ? " " :
                     (i_board[11:10]== 2'b01) ? "O" : "X";
  assign square[5] = (i_board[9:8]== 2'b00)   ? " " :
                     (i_board[9:8]== 2'b01)   ? "O" : "X";
  assign square[6] = (i_board[7:6]== 2'b00)   ? " " :
                     (i_board[7:6]== 2'b01)   ? "O" : "X";
  assign square[7] = (i_board[5:4]== 2'b00)   ? " " :
                     (i_board[5:4]== 2'b01)   ? "O" : "X";
  assign square[8] = (i_board[3:2]== 2'b00)   ? " " :
                     (i_board[3:2]== 2'b01)   ? "O" : "X";
  assign square[9] = (i_board[1:0]== 2'b00)   ? " " :
                     (i_board[1:0]== 2'b01)   ? "O" : "X";

  localparam NONE = 0;		// Meaning of the i_result value
  localparam XWIN = 1;
  localparam OWIN = 2;
  localparam DRAW = 3;

  reg [7:0] state;		// Current state of the main FSM here
  initial   state = 26;
  reg 	    print_stb;		// Tell the second FSM to start printing
  initial   print_stb = 0;

  // When we are asked to, print out a string
  reg [7:0] tx_index;		// Current char posn being printed
  reg [2:0] printstate;		// State of the printing FSM below
  initial   printstate = 0;

  always @(posedge i_clk) begin // Update the strings with the board moves
    Str[38] <= square[1];
    Str[42] <= square[2];
    Str[46] <= square[3];
    Str[61] <= square[4];
    Str[65] <= square[5];
    Str[69] <= square[6];
    Str[84] <= square[7];
    Str[88] <= square[8];
    Str[92] <= square[9];
  end

  always @(posedge i_clk) begin
    case (state)			// The main FSM
      0: if (i_result_stb) begin	// We have a result, print it out
	   o_busy <= 1;
	   if (i_result==DRAW)
	     state <= 1;
	   else if (i_result==XWIN)
	     state <= 7;
	   else if (i_result==OWIN)
	     state <= 13;
         end else if (i_needinput && !o_validmove_stb) begin
	   state <= 19;			// Print board, get char from user
    	 end

      1: begin  // Draw
	   tx_index <= 37;		// Print the board
	   print_stb <= 1;
	   state <= 2;
         end

      2: begin
	   print_stb <= 0; state <= 3;
         end

      3: if (printstate==0)		// Wait until it is printed
	   state <= 4;

      4: begin
	   tx_index <= 96;		// Print the draw string
	   print_stb <= 1;
	   state <= 5;
         end

      5: begin
	   print_stb <= 0; state <= 6;
         end

      6: if (printstate==0) begin	// Wait until it is printed
	   state <= 0;			// We are no longer busy
	   o_busy <= 0;
         end

      7: begin // Win
	   tx_index <= 37;		// Print the board
	   print_stb <= 1;
	   state <= 8;
         end

      8: begin
	   print_stb <= 0; state <= 9;
         end

      9: if (printstate==0)		// Wait until it is printed
	   state <= 10;

      10: begin
	   tx_index <= 118;		// Print the win string
	   print_stb <= 1;
	   state <= 11;
         end

      11: begin
	   print_stb <= 0; state <= 12;
         end

      12: if (printstate==0) begin	// Wait until it is printed
	   state <= 0;			// We are no longer busy
	   o_busy <= 0;
         end

      13: begin // Lose
	   tx_index <= 37;		// Print the board
	   print_stb <= 1;
	   state <= 14;
         end

      14: begin
	   print_stb <= 0; state <= 15;
         end

      15: if (printstate==0)		// Wait until it is printed
	   state <= 16;

      16: begin
	   tx_index <= 135;		// Print the lose string
	   print_stb <= 1;
	   state <= 17;
         end

      17: begin
	   print_stb <= 0; state <= 18;
         end

      18: if (printstate==0) begin	// Wait until it is printed
	   state <= 0;			// We are no longer busy
	   o_busy <= 0;
         end

      19: begin // Get user input
	   tx_index <= 37;		// Print the board
	   print_stb <= 1;
	   state <= 20;
         end

      20: begin
	   print_stb <= 0; state <= 21;
         end

      21: if (printstate==0) begin	// Wait until it is printed
	   state <= 22;
           o_busy <= 1;
	  end

      22: if (rx_avail)			// Wait for user data
	   state <= 23;

      23: begin
      	   o_move <= keymap[rx_data[3:0]];
      	   o_validmove_stb <= 1;
	   o_busy <= 0;
	   state <= 24;
         end

      24: begin
           o_validmove_stb <= 0;
	   state <= 25;
         end

      25: begin
	   state <= 0;
         end

      26: begin // Show the game instructions
	    o_busy <= 1;
	    tx_index <= 0;		// Print the board
	    print_stb <= 1;
	    state <= 27;
          end

      27: begin
	    print_stb <= 0; state <= 28;
          end

      28: if (printstate==0) begin	// Wait until it is printed
	    o_busy <= 0;
	    state <= 0;			// and start the main logic loop
          end

    endcase

    case (printstate)			// The printing FSM
      // Start printing out a string. Someone else has
      // initialised the tx_index.
      0: if (print_stb) begin
	   printstate <= 1;
         end

      // No chars left to print, go back to state 0.
      // If the UART isn't busy, send one char to be
      // printed and move up to the next char
      1: if (Str[tx_index]==0)
	    printstate <= 0;
	 else if (!tx_busy) begin
	    tx_data <= Str[tx_index];
	    tx_stb <= 1;
	    tx_index <= tx_index + 1;
	    printstate <= 2;
         end

      // Drop the tx_stb strobe and go back to print
      // another character
      2:  begin
	    tx_stb <= 0;
	    printstate <= 1;
	  end
    endcase
  end

  // Interface to the TX UART
  reg  [7:0] tx_data;		// Data to send to the UART
  wire	     tx_busy;		// Is it busy?
  reg	     tx_stb;		// Strobe to ask to send data
  initial    tx_stb= 0;

  // Wire up the transmit and receive serial port modules
  txuartlite #(CLOCKS_PER_BAUD)
  	transmitter(i_clk, tx_stb, tx_data, o_uart_tx, tx_busy);
  rxuartlite #(CLOCKS_PER_BAUD)
	receiver(i_clk, i_uart_rx, rx_avail, rx_data);

endmodule
