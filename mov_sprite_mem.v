module mov_sprite_mem(clock, select, x, y, out);
//select -> number of the sprite -> 64 posibilities
//x -> w position of the pixel in the 16x16 array

input clock;
input [3:0] x, y;
input [5:0] select;

output reg [1:0] out;

wire [1:0] sprite1;
wire [1:0] sprite2;
//....continue to make sprites for more moving sprites

wire [7:0] address;
assign address = {x, y};

//first bit of the sprite pattern
	//pattern loaded in mif-file:  sprite1.mif
ram_mov_sprite1 rms1(.clock(clock), .address(address), .wren(1'b0), .data({2{1'b0}}), .q(sprite1));
	//pattern loaded in mif-file:  sprite1.mif
ram_mov_sprite2 rms2(.clock(clock), .address(address), .wren(1'b0), .data({2{1'b0}}), .q(sprite2));

//select the correct sprite
always @(select or sprite1 or sprite2) begin
	case(select)
		0: out = sprite1;
		1: out = sprite2;
		default: begin out = 0; end
	endcase 
end

endmodule 