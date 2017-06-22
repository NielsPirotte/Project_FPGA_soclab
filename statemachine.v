module statemachine(clock, reset, controller1, controller2, sprites, statics);

input clock, reset;
input [9:0] controller1, controller2;

output [63:0] sprites;
output [0:0] statics;
//output [] offset_x, offset_y;

//Test values
assign statics = 0;


//declaration of the statemachine
//Startmenu--> Init mode --> input mode --> end of game
reg [3:0] gamestate;

//Player status
//status = what is the character doing:
	//attack (3bit)
	//defend
	//duck
	//jump
	//health (5bit)
	//(posx (8bit), posy (8bit))
	//different animations 16 --> 4bit
	//different animation frames 64 --> 6bit

//reg [8:0] p1_posx, p1_posy;
//reg [5:0] p1_health;
//reg p1_left;
//reg [3:0] p1_animation;
//reg [1:0] p1_animationframe;
//reg color;
reg [31:0] player1, player2;

//sets players and sprites
assign sprites = {player1, player2};

//counter for timing
reg [21:0] state_counter;
reg update_gamestate; //each 25ms --> 2.701.000 counts is +-25ms
reg [20:0] frame_counter; 
reg update_frame; //60fps -->1.800.500 counts is +- 16.6ms

//implementation of the game counter and the frame counter
always @(posedge clock or posedge reset) begin
	if(reset) begin
		state_counter = 0;
		frame_counter = 0;
		update_gamestate = 0;
		update_frame = 0;
	end
	else begin
		//state pulse
		if(state_counter < 2701000) begin
			state_counter = state_counter + 1;
			update_gamestate = 0;
		end
		else begin
			state_counter = 0;
			update_gamestate = 1;
			
		end
		
		//frame pulse
		if(frame_counter<1800500) begin
			frame_counter = frame_counter + 1;
			update_frame = 0;
		end
		else begin
			frame_counter = 0;
			update_frame = 1;
		end
	end
end

//in game pulse counter -> 4 pulses = 1s
reg [3:0] delay;

//controller buffers
reg [9:0] controller1buffer, controller2buffer;

//Gameflow state machine
always @(posedge clock or posedge reset) begin
	if(reset) begin
		gamestate = 0;
		delay = 0;
		controller1buffer = 0;
		controller2buffer = 0;
	end
	else begin
		case (gamestate)
			0:
			//Start menu - select character
			//pause game
			//if startbutton is het continue
				if(/*startbutton*/1) gamestate = 1;
			1: 
			//initialize game
				if(update_gamestate) begin
					if(delay < 12) delay = delay + 1;
					else begin
						delay = 0;
						gamestate = 3;
					end
				end 
			2:	
			//Pause menu
				if(/*startbutton*/0) gamestate = 3;
			3:
			//check for inputs
			if(p1_dead || p2_dead) gamestate = 4;
			else begin
				if(/*startbutton*/0) gamestate = 2;
				else begin
					if(update_gamestate) begin
						controller1buffer = controller1;
						controller2buffer = controller2;
						//refresh
					end
				end
			end
			4:
			//end of game
			if(update_gamestate) begin
				if(delay < 12) delay = delay + 1;
				else begin
					delay = 0;
					//Back to begin of the game
					gamestate = 0;
				end
			end 
		endcase
	end
end

//processing of controller input player 1
//Set player 1 status based on the input of controller 1

//for processing game mechanics, we need the distance between the characters
reg close;
wire [8:0] distance; //abs value
assign distance = (p1_posx>p2_posx)?(p1_posx-p2_posx):(p2_posx-p1_posx);
always @(p1_posx or p2_posx or distance) begin
	p1_left = 0;
	p2_left = 1;
	close = 0;
	if(distance < 56) close = 1;
	if(p1_posx < p2_posx) begin
		p1_left = 1;
		p2_left = 0;
	end
end

//PLAYER1
//status: {block, jump, duck, attack, down}
//health
reg p1_left;
reg p1_dead;
reg [5:0] p1_status;
reg [5:0] p1_health;
reg [8:0] p1_posx, p1_posy;

//check if player 1 is dead
always @(p1_health) begin
	p1_dead = 0;
	if(p1_health<0) p1_dead = 1;
end

always @(posedge clock or posedge reset) begin
	if(reset) begin
		p1_status = 0;
		p1_health = {1'b0,{5{1'b1}}};
		p1_posx = -10;
		p2_posy = 0;
	end
	else begin
		if(animation_ended_p1) p1_status = 0;
		else begin
			if(close) begin
				case(p2_status[2:1])
					//0: does not attack
					1://p2 attacks low
					if(!(p1_status[5] && p1_status[3])) begin	//does not duck and block
						p1_health = p1_health - 10; //kan problemen geven
						p1_status[0] = 1;
					end
					2://p2 attacks mid
					if(p1_status == 6'b000xx0) begin
						p1_health = p1_health - 10;
						p1_status[0] = 1;
					end
					3://p2 attack high
					if(p1_status == 6'b0x0xx0) begin
						p1_health = p1_health - 10;
						p1_status[0] = 1;
					end
				endcase
			end
			if(!p1_status[0]) begin
				case(controller1buffer)
					//add attacks and move options
					default:
					p1_status[1]= 1;
				endcase
			end
		end
	end
end
//processing of controller input player 2
//copy of the previous block
//test
wire p2_dead;
assign p2_dead=0;
reg [8:0] p2_posx, p2_posy;
wire [5:0] p2_status;
assign p2_status =0;
reg p2_left;


//controlling animations
//Setting animation
reg [3:0] p1_animation;
reg [5:0] prev_p1_status;
always @(posedge clock or posedge reset) begin
	if(reset) prev_p1_status = 0;
	else prev_p1_status = p1_status;
end
always @(posedge clock or posedge reset) begin
	if(reset) begin
		p1_animation = 0;
	end
	else begin
		if(prev_p1_status != p1_status) begin
			case(p1_status)
				default:
				p1_animation = 0;
			endcase
		end
	end
end

reg [1:0] p1_animationframe;
reg animation_ended_p1;
always @(posedge clock or posedge reset) begin
	if(reset) begin
		p1_animationframe = 0;
		animation_ended_p1 = 0;
	end
	else begin
		if(update_frame) begin
			if(p1_animationframe<3) begin
				p1_animationframe = p1_animationframe + 1;
				animation_ended_p1 = 0;
			end
			else begin
				p1_animationframe = 0;
				animation_ended_p1 = 1;
			end
		end
	end
end

always @(posedge clock or posedge reset) begin
	if(reset) begin
		player1 = 0;
	end
	else begin
		player1 = {p1_posx, p1_posy, p1_health, p1_left, p1_animation, p1_animationframe, 1'b0};
	end
end
endmodule 