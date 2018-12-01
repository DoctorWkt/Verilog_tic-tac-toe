// Top-Level Verilog Module for ULX3S board with ECP5 45F FPGA

`include "ttt.v"
`default_nettype none

module ULX3S_45F (
	input clk_25mhz,
	input ftdi_txd,
	output ftdi_rxd,
	output wifi_gpio0);

  // Tie gpio0 high, this keeps the board from rebooting
  assign wifi_gpio0 = 1'b1;

  ttt   #(25_000_000, 115_200)
        dut(clk_25mhz, ftdi_rxd, ftdi_txd);
endmodule
