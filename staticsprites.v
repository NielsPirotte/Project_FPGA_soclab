module staticsprites(clock, reset, collumn, row, men, out) 
	input clock;
	input reset;
	input [6:0] collumn;
	input [6:0] row;
	
	output men;
	output [7:0] out;
	
	reg
	wire address
	
	//this memory contains max 64 different static sprites
	//each sprite is described with 8 bits -> 2 for the color palette and 6 for the character selection
	static_sprite_table spt(.clock(clock), .address(address), .data(0), .wren(1'b0), q(out));
	
	
	//counter checks all addresses
	wire [5:0] counter;
	always @(posedge clock or posedge reset) begin
		if(reset) counter = 0;
		else begin
			if
			counter = counter + 1;
		end
	end

endmodule 