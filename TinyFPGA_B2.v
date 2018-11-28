// Top-Level Verilog Module for TinyFPGA B2.
// Only include the pins that the design is actually using.  Make sure that
// the pin is given the correct direction: input vs. output vs. inout

`include "ttt.v"
`default_nettype none

module TinyFPGA_B2 (
  //output pin1_usb_dp,
  //inout pin2_usb_dn,
  input pin3_clk_16mhz,
  //output pin4,
  //output pin5,
  //output pin6,
  //output pin7,
  //output pin8,
  //output pin9,
  //output pin10,
  //output pin11,
  //output pin12,
  //output pin13,
  //inout pin14_sdo,
  //inout pin15_sdi,
  //inout pin16_sck,
  //inout pin17_ss,
  inout pin18,			// Rx from the computer
  inout pin19,			// Tx to the computer
  //inout pin20,
  //inout pin21,
  //inout pin22,
  //inout pin23,
  //inout pin24

);

  ttt	#(16_000_000, 115_200)
	dut(pin3_clk_16mhz, pin19, pin18);

endmodule
