module map_mem(clock, select, x, y, out);
//select -> number of the sprite -> 64 posibilities
//x -> w position of the pixel in the 16x16 array

input clock;
input [3:0] x, y;
input [5:0] select;

output reg [1:0] out;

wire [1:0] grass;
wire [1:0] ground;
//....continue to make sprites for more moving sprites

wire [7:0] address;
assign address = {x, y};

//first bit of the sprite pattern
	//pattern loaded in mif-file:  sprite1.mif
map_grass grassmap(.clock(clock), .address(address), .wren(1'b0), .data({2{1'b0}}), .q(grass));
	//pattern loaded in mif-file:  sprite1.mif
map_ground groundmap(.clock(clock), .address(address), .wren(1'b0), .data({2{1'b0}}), .q(ground));

//select the correct sprite
always @(select or grass or ground) begin
	case(select)
		0: out = grass;
		1: out = ground;
		default: out = 0;
	endcase 
end

endmodule 