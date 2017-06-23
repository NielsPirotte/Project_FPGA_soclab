module map(clock, x, y, out);
	input clock;
	input [11:0] x;
	input [10:0] y;
	
	output reg [11:0] out;

	wire [14:0] address;
	wire [5:0] mem_in_x;
	wire [8:0] mem_in_y;
	
	wire [1:0] out_sprite;
	
	assign mem_in_x = x[4:1];
	assign mem_in_y = y[9:1];
	assign address = {mem_in_y, mem_in_x};

	//the memory consist of 256 x 256 tiles (collumns and rows) of 12 bits (4 red, 4 green, 4 blue)
	//color tiles of 4x4 bits chuncked background
	//ram_background bg(.clock(clock), .address(address), .data(2'b00), .wren(1'b0), .q(out_sprite));
	//ram_color_back rcb(.clock(clock), .address(out_sprite), .data(2'b00), .wren(1'b0), .q(out));
	
	always @(y) begin
		if(y > 700) out = 12'b011010000001;
		else out = 12'b000000000000;
	end
	
endmodule 