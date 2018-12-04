// Top-Level Verilog Module for ULX3S board with ECP5 45F FPGA

`default_nettype none

module ULX3S_45F (
	input clk_25mhz,
	input ftdi_txd,
	output ftdi_rxd,
        output [3:0] gpdi_dp, gpdi_dn,
	output wifi_gpio0);

  // Tie gpio0 high, this keeps the board from rebooting
  assign wifi_gpio0 = 1'b1;

  wire [17:0] board;
  ttt   #(25_000_000, 115_200)
        dut(clk_25mhz, ftdi_rxd, ftdi_txd, board);

  wire clk_25MHz, clk_250MHz;
  clock
  clock_instance
  (
      .clkin_25MHz(clk_25mhz),
      .clk_25MHz(clk_25MHz),
      .clk_250MHz(clk_250MHz)
  );

  // mapping from board to video color
  // X = 2'b01 = green (player)
  // O = 2'b11 = red   (fpga)
  wire [8:0] red, green;
  always @(posedge clk_25MHz)
  begin
    // top left
    red[8]   <=  board[1] & board[0];
    green[8] <= ~board[1] & board[0];
    // top middle
    red[7]   <=  board[3] & board[2];
    green[7] <= ~board[3] & board[2];
    // top right
    red[6]   <=  board[5] & board[4];
    green[6] <= ~board[5] & board[4];

    // middle left
    red[5]   <=  board[7] & board[6];
    green[5] <= ~board[7] & board[6];
    // center
    red[4]   <=  board[9] & board[8];
    green[4] <= ~board[9] & board[8];
    // middle right
    red[3]   <=  board[11] & board[10];
    green[3] <= ~board[11] & board[10];

    // bottom left
    red[2]   <=  board[13] & board[12];
    green[2] <= ~board[13] & board[12];
    // bottom middle
    red[1]   <=  board[15] & board[14];
    green[1] <= ~board[15] & board[14];
    // bottom right
    red[0]   <=  board[17] & board[16];
    green[0] <= ~board[17] & board[16];
  end

  DVI_3x3
  DVI_3x3_instance
  (
      .pixclk(clk_25MHz),
      .shiftclk(clk_250MHz),
      .in_red(red),
      .in_green(green),
      .in_blue(9'b0),
      .TMDSp(gpdi_dp[2:0]),
      .TMDSn(gpdi_dn[2:0]),
      .TMDSp_clock(gpdi_dp[3]),
      .TMDSn_clock(gpdi_dn[3])
  );

endmodule
