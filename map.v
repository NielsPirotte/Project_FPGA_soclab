module map(clock, x, y, out);
	input clock;
	input [11:0] x;
	input [10:0] y;
	
	output [11:0] out;

	wire [15:0] address;
	wire [6:0] mem_in_x;
	wire [8:0] mem_in_y;
	assign mem_in_x = x[8:2];
	assign mem_in_y = y[10:2];
	assign address = {mem_in_y, mem_in_x};

	//the memory consist of 256 x 256 tiles (collumns and rows) of 12 bits (4 red, 4 green, 4 blue)
	//color tiles of 4x4 bits chuncked background
	background bt(.clock(clock), .address(address), .data({12{1'b0}}), .wren(1'b0), .q(out));
endmodule 