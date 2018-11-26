#!/usr/bin/perl
use strict;
use warnings;

print<<"EOF1";
`default_nettype none
module gen_xmove(i_board, o_move, o_result, o_isdraw);
  input wire [17:0] i_board;
  output reg [3:0]  o_move;
  output reg [1:0]  o_result;
  output reg o_isdraw;

  localparam NONE = 0;
  localparam XWIN = 1;
  localparam OWIN = 2;
  localparam DRAW = 3;

  // Draw detection logic. No draw if any square is empty
  always @(*) 
    casez (i_board)
      18'b00????????????????: o_isdraw = 0;
      18'b??00??????????????: o_isdraw = 0;
      18'b????00????????????: o_isdraw = 0;
      18'b??????00??????????: o_isdraw = 0;
      18'b????????00????????: o_isdraw = 0;
      18'b??????????00??????: o_isdraw = 0;
      18'b????????????00????: o_isdraw = 0;
      18'b??????????????00??: o_isdraw = 0;
      18'b????????????????00: o_isdraw = 0;
      default:                o_isdraw = 1;
    endcase

  // Win, lose and next X move logic
  always @(*) 
    casez (i_board)
EOF1


# Read in moves.txt
open(my $IN, "<", "moves.txt") || die("moves.txt: $!\n");
while (<$IN>) {
  chomp;
  # [     XO   ] X move 5
  if (m{.*\[(.*)\] X move (\d)}) {
    my $board= $1; my $xmove= $2;
    
    # Convert board to a binary constant
    $board=~ s{ }{00}g;
    $board=~ s{X}{11}g;
    $board=~ s{O}{01}g;
    print("      18'b$board: begin o_move = 4'd$xmove; o_result = NONE; end\n");
  }

  if (m{.*\[(.*)\] X wins}) {
    my $board= $1;
    $board=~ s{\?}{??}g;
    $board=~ s{X}{11}g;
    $board=~ s{O}{01}g;
    print("      18'b$board: begin o_move = 4'd0; o_result = XWIN; end\n");
  }

  if (m{.*\[(.*)\] O wins}) {
    my $board= $1;
    $board=~ s{\?}{??}g;
    $board=~ s{X}{11}g;
    $board=~ s{O}{01}g;
    print("      18'b$board: begin o_move = 4'd0; o_result = OWIN; end\n");
  }

}
print("      default: begin o_move = 4'd0; o_result = NONE; end	// Bad move\n");
print("    endcase\n");
print("endmodule\n");
close($IN);
