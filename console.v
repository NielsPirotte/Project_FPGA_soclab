//A consol:e for playing games
//interface: leds for feedback, reset button, VGA interface, switches for settings 

module console(iCLK_50, iKEY, iSW, oVGA_R, oVGA_G, oVGA_B, oVGA_HS, oVGA_VS, oVGA_CLOCK, oVGA_SYNC_N, oVGA_BLANK_N);

//input and output values
	//clock, switches and buttons
	input iCLK_50;
	input [0:0] iKEY;
	input [17:0] iSW;
	
	//VGA
	output  oVGA_CLOCK; 
	output [9:0] oVGA_R, oVGA_G, oVGA_B;
	output oVGA_HS, oVGA_VS;
	output oVGA_SYNC_N; 
	output oVGA_BLANK_N;
	
//define interfaces
	//reset button
	assign reset = ~iKEY[0];

	//VGA with picture processing unit (ppsu)
	//attributes is used by the statemachine to ajust the moving sprites in the ppu
	//wire [] attributes;
	wire hsync, vsync;
	assign oVGA_CLOCK = clock;
	assign oVGA_SYNC_N = 1'b0;
	assign oVGA_HS = hsync; assign oVGA_VS = vsync;
	assign oVGA_BLANK_N = hsync & vsync;
	
	wire [9:0] red, green, blue;
	ppu ppu(clock, reset, red, green, blue, hsync, vsync, attributes);

	assign oVGA_R = red;
	assign oVGA_G = green;
	assign oVGA_B : blue;
	
	//the game statemachine
	statemachine sm(clock, reset, iSW, attributes);
	
	//rom
	//not yet implemented
	
	//databus
	//not yet implemented
	
	//clock signal with pll - 108Mhz
	wire clock;
	pll pll(reset, iCLK_50, clock);


endmodule 