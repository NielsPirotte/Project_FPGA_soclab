module map(clock, collumn, row, out)
	input clock;
	input [6:0] collumn;
	input [6:0] row;
	
	output [1:0] out;

	wire [13:0] address;
	assign address = {collumn, row};

	//the memory consist of 128 x 128 tiles (collumns and rows) of 6 bits
	//the 6 bits describe the character on the tile
	background_table bt(.clock(clock), .address(address), .data(0), .wren(1'b0), q(out));
endmodule 