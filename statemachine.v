module statemachine(clock, reset, controls, sprites, statics, offset_x, offset_y, update);

input clock, reset;
input [17:0] controls;

output reg update;

output [179:0] sprites;
output [131:0] statics;
output [11:0] offset_x, offset_y;

assign sprites = 0;
assign statics = 0;
assign offset_x = 0;
assign offset_y = 0;

//declaration of the statemachine
reg [3:0] gamestate;

//declaration of the players
reg [] player1, player2;

//counter for timing
reg [21:0] counter;
reg pulse;

//implementation of the game counter
//2.701.000 counts is +-25ms
always @(posedge clock or posedge reset) begin
	if(reset) begin
		counter = 0;
		pulse = 0;
	end
	else begin
		if(counter < 2701000) begin
			counter = counter + 1;
			pulse = 0;
		end
		else begin
			counter = 0;
			pulse = 1;
		end
	end
end

//in game pulse counter -> 4 pulses = 1s
reg [3:0] delay;

//controller buffers
reg [] controller1buffer, controller2buffer;

//state machine control
always @(posedge clock or posedge reset) begin
	if(reset) begin
		gamestate = 0
		delay = 0;
		update = 0;
		controller1buffer = 0;
		controller2buffer = 2;
	end
	else begin
		case (gamestate)
			0:
			//Start menu - select character
			//pause game
			//if startbutton is het continue
				if(/*startbutton*/) gamestate = 1;
			1: 
			//initialize game
				if(pulse) begin
					if(counter < 12) delay = delay + 1;
					else begin
						delay = 0;
						gamestate = 3;
					end
				end 
			2:	
			//Pause menu
				if(/*startbutton*/) gamestate = 3;
			3:
			update = 0;
			//check for inputs
			controller1buffer = controller1;
			controller2buffer = controller2;
			gamestate = 4;
			4:
			//move character
			
			if(pulse) begin
				update = 1;
				gamestate = 3;
			end		
			
		endcase
	end
end

//output function
always @(gamestate) begin
	case (gamestate)
	0:
	
	endcase

end
endmodule 