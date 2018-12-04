module DVI_3x3
(
	input pixclk,  // 25MHz
	input shiftclk, // 250MHz
	input [8:0] in_red, in_green, in_blue, // 9-bit for 3x3 panel
	output [2:0] TMDSp, TMDSn,
	output TMDSp_clock, TMDSn_clock
);

assign clk_TMDS = shiftclk;

////////////////////////////////////////////////////////////////////////
reg [9:0] CounterX, CounterY;
reg hSync, vSync, DrawArea;
always @(posedge pixclk) DrawArea <= (CounterX<640) && (CounterY<480);

always @(posedge pixclk) CounterX <= (CounterX==799) ? 0 : CounterX+1;
always @(posedge pixclk) if(CounterX==799) CounterY <= (CounterY==524) ? 0 : CounterY+1;

always @(posedge pixclk) hSync <= (CounterX>=656) && (CounterX<752);
always @(posedge pixclk) vSync <= (CounterY>=490) && (CounterY<492);

reg [8:0] shift_disp_red, shift_disp_green, shift_disp_blue;
always @(posedge pixclk)
begin
  if(CounterY == 0 && CounterX == 0)
  begin
    shift_disp_red <= in_red;
    shift_disp_green <= in_green;
    shift_disp_blue <= in_blue;
  end
  if(CounterX == 213 || CounterX == 426 || CounterX == 640)
  begin
    shift_disp_red[2:0] <= {shift_disp_red[0], shift_disp_red[2:1]};
    shift_disp_green[2:0] <= {shift_disp_green[0], shift_disp_green[2:1]};
    shift_disp_blue[2:0] <= {shift_disp_blue[0], shift_disp_blue[2:1]};
  end
  if((CounterY == 160 || CounterY == 320) && CounterX == 0)
  begin
    shift_disp_red <= {3'b0, shift_disp_red[8:3]};
    shift_disp_green <= {3'b0, shift_disp_green[8:3]};
    shift_disp_blue <= {3'b0, shift_disp_blue[8:3]};
  end
end

////////////////
reg [7:0] red, green, blue;
always @(posedge pixclk) red <= {shift_disp_red[0] ? 8'hFF : 8'h00};
always @(posedge pixclk) green <= {shift_disp_green[0] ? 8'hFF : 8'h00};
always @(posedge pixclk) blue <= {shift_disp_blue[0] ? 8'hFF : 8'h00};

////////////////////////////////////////////////////////////////////////
wire [9:0] TMDS_red, TMDS_green, TMDS_blue;
TMDS_encoder encode_R(.clk(pixclk), .VD(red  ), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_red));
TMDS_encoder encode_G(.clk(pixclk), .VD(green), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_green));
TMDS_encoder encode_B(.clk(pixclk), .VD(blue ), .CD({vSync,hSync}), .VDE(DrawArea), .TMDS(TMDS_blue));

////////////////////////////////////////////////////////////////////////
reg [3:0] TMDS_mod10=0;  // modulus 10 counter
reg [9:0] TMDS_shift_red=0, TMDS_shift_green=0, TMDS_shift_blue=0;
reg TMDS_shift_load=0;
always @(posedge clk_TMDS) TMDS_shift_load <= (TMDS_mod10==4'd9);

always @(posedge clk_TMDS)
begin
	TMDS_shift_red   <= TMDS_shift_load ? TMDS_red   : TMDS_shift_red  [9:1];
	TMDS_shift_green <= TMDS_shift_load ? TMDS_green : TMDS_shift_green[9:1];
	TMDS_shift_blue  <= TMDS_shift_load ? TMDS_blue  : TMDS_shift_blue [9:1];	
	TMDS_mod10 <= (TMDS_mod10==4'd9) ? 4'd0 : TMDS_mod10+4'd1;
end

OBUFDS OBUFDS_red  (.I(TMDS_shift_red  [0]), .O(TMDSp[2]), .OB(TMDSn[2]));
OBUFDS OBUFDS_green(.I(TMDS_shift_green[0]), .O(TMDSp[1]), .OB(TMDSn[1]));
OBUFDS OBUFDS_blue (.I(TMDS_shift_blue [0]), .O(TMDSp[0]), .OB(TMDSn[0]));
OBUFDS OBUFDS_clock(.I(pixclk), .O(TMDSp_clock), .OB(TMDSn_clock));
endmodule
