module map(clock, x, y, out);
	input clock;
	input [9:0] x;
	input [9:0] y;
	
	output [11:0] out;

	wire [19:0] address;
	wire [7:0] mem_in_x, mem_in_y;
	assign mem_in_x = x[9:2];
	assign mem_in_y = y[9:2];
	assign address = {mem_in_y, mem_in_x};

	//the memory consist of 256 x 256 tiles (collumns and rows) of 12 bits (4 red, 4 green, 4 blue)
	//color tiles of 4x4 bits chuncked background
	background bt(.clock(clock), .address(address), .data({6{1'b0}}), .wren(1'b0), .q(out));
endmodule 