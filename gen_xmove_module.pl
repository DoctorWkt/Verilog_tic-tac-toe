#!/usr/bin/perl
use strict;
use warnings;

print<<"EOF1";
// Given a board state, return the move that X should make.
`default_nettype none
module xmove(i_board, o_move);
  input wire [17:0] i_board;
  output reg [3:0]  o_move;

  always @(*) 
    case (i_board)
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
    print("      18'b$board: begin o_move = 4'd$xmove; end\n");
  }
}
print("      default: begin o_move = 4'd0; end	// Bad move\n");
print("    endcase\n");
print("endmodule\n");
close($IN);
