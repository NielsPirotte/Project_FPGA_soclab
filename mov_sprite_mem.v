module mov_sprite_mem(clock, selanim, selframe, x, y, nx, out, mirror);

//There are 3 different animation types:
//1 frame: 50x105 => 13 bit address
//4 frames: 50x105 each => 15 bit address
//4 frames: 64x105 each => 15 bit address

//Each has a different way for a addressing the ram
wire [12:0] address_single; 
wire [14:0] address_frame;
wire [14:0] address_normal;

input clock;
//positioning
input [6:0] x;
input [7:0] y;
//for selecting correct animation and frame
input [3:0] selanim;
input [1:0] selframe;
//for picturing on coordinates
input nx;
input mirror;

output reg [3:0] out;

//determine the type of attack used
reg [1:0] type_attack; 
//0 => address_normal
//1 => address_single
//2 => address_attack
always @(selanim) begin
	case(selanim)
		0: type_attack = 0;
		1: type_attack = 0;
		2: type_attack = 0;
		3: type_attack = 0;
		4: type_attack = 2;
		5: type_attack = 2;
		6: type_attack = 2;
		7: type_attack = 1;
		8: type_attack = 1;
		9: type_attack = 1;
		default: type_attack = 0;
	endcase
end

//for picturing on coordinates
//calculate the correct x position for input in the ram module depending on the animation type
reg [6:0] picx;
reg no_out;
always @(x or nx or mirror or selanim or type_attack) begin
	no_out = 0;
	if(type_attack == 2) begin
		if(nx ^ mirror) begin
			picx = 63 - x;
		end
		else begin
			picx = x + 63;
		end
	end
	else begin //0 or 1
			if(x > 49) begin 
				picx = 0;
				no_out = 1;
			end
			else begin
				if(nx ^ mirror) begin
					picx = 49 - x;
				end
				else begin
					picx = x + 49;
				end
			end
	end
end

//calculate correct y, because reversed
wire [7:0] picy;
assign picy = 210 - y;

//calculate the correct x position for input in the ram module
reg [7:0] framex;
always @(selframe or type_attack or picx) begin
	case(type_attack)
		0: begin //normal
			case(selframe)
				0: framex = picx[6:1];
				1: framex = 50 + picx[6:1];
				2: framex = 100 + picx[6:1];
				3: framex = 150 + picx[6:1];
			endcase 
		end
		2: begin //attacks
			case(selframe)
				0: framex = picx[6:1];
				1: framex = 64 + picx[6:1];
				2: framex = 128 + picx[6:1];
				3: framex = 192 + picx[6:1];
			endcase 
		end
		default: framex = 0;
	endcase
end

assign address_single = picx[6:1] + 50*picy[7:1];//{picy[7:1], picx[6:1]};
assign address_normal =  framex + 200*picy[7:1];
assign address_frame = {picy[7:1], framex};


wire [3:0] idle_out, walking_out, hit_out, jump_out, mid_punch_out, high_kick_out, 
		 low_punch_out, block_high_out, block_low_out, crouch_out;
	//pattern for idle state
ram_idle_sprite idle(.clock(clock), .address(address_normal), .wren(1'b0), .data({4{1'b0}}), .q(idle_out));
	//pattern for walking
ram_walking_sprite walking(.clock(clock), .address(address_normal), .wren(1'b0), .data({4{1'b0}}), .q(walking_out));
	//pattern for hit
ram_hit_sprite hit(.clock(clock), .address(address_normal), .wren(1'b0), .data({4{1'b0}}), .q(hit_out));
	//pattern for jump
ram_jump_sprite jump(.clock(clock), .address(address_normal), .wren(1'b0), .data({4{1'b0}}), .q(jump_out));
	//pattern for mid punch
ram_mid_punch_sprite mid_punch(.clock(clock), .address(address_frame), .wren(1'b0), .data({4{1'b0}}), .q(mid_punch_out));
	//pattern for high kick
ram_high_kick_sprite high_kick(.clock(clock), .address(address_frame), .wren(1'b0), .data({4{1'b0}}), .q(high_kick_out));
	//pattern for crouch punch
ram_low_punch_sprite low_punch(.clock(clock), .address(address_frame), .wren(1'b0), .data({4{1'b0}}), .q(low_punch_out));
	//pattern for block high
ram_block_high_sprite block_high(.clock(clock), .address(address_single), .wren(1'b0), .data({4{1'b0}}), .q(block_high_out));
	//pattern for block low
ram_block_low_sprite block_low(.clock(clock), .address(address_single), .wren(1'b0), .data({4{1'b0}}), .q(block_low_out));
	//pattern for crouch
ram_crouch_sprite crouch(.clock(clock), .address(address_single), .wren(1'b0), .data({4{1'b0}}), .q(crouch_out));

//select the correct sprite (Output multiplexer)
always @(selanim or idle_out or walking_out or hit_out or jump_out or mid_punch_out or high_kick_out or
		 low_punch_out or block_high_out or block_low_out or crouch_out or no_out) begin
	if(no_out) out = 0;
	else begin
		case(selanim)
			0: out = idle_out;
			1: out = walking_out;
			2: out = hit_out;
			3: out = jump_out;
			4: out = low_punch_out;
			5: out = mid_punch_out;
			6: out = high_kick_out;
			7: out = crouch_out;
			8: out = block_low_out;
			9: out = block_high_out;
			default: out = idle_out;
		endcase
	end
end

endmodule 