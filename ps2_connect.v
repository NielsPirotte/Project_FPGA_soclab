module ps2_connect(clock, reset, GPIO_0, c1, c2);
   
	input [4:0] GPIO_0;
	input clock;
	input reset;

	output [9:0] c1, c2;
	
	wire [3:0] arduinoInput;
	wire cSelect;
	
	reg [9:0] c1;
	reg [9:0] c2;
	
	reg [9:0] controller;
	reg [20:0] timer;
	reg fixed = 0;
	
	assign arduinoInput = GPIO_0[3:0];
	assign cSelect = GPIO_0[4];
	
	always @(posedge clock or posedge reset)
    begin
		if(reset) begin
			timer = 0;
		end
		else if(timer > 1000000) begin
			timer = 0;
		end
		else if(arduinoInput > 0) begin
			timer = timer + 1;
		end
	end
	
	
	always @(posedge clock or posedge reset)
	begin
		if(reset) begin
			c1 = 0;
			c2 = 0;
			fixed = 0;
		end
		else if(timer==1000000)begin
			if(cSelect) begin
				c2 = controller;
			end
			else begin
				c1 = controller;
			end
			fixed = 1;
		end
	end
  
  
	always @(posedge clock or posedge reset)
    begin
		if(reset) begin
			controller = 0;
		end
		else if(fixed == 0) begin
			case(arduinoInput)
				1 : begin controller = 10'b0000000001; end //CIRCLE
				2 : begin controller = 10'b0000000010; end //CROSS
				3 : begin controller = 10'b0000000100; end //SQUARE
				4 : begin controller = 10'b0000001000; end //TRIANGLE
				5 : begin controller = 10'b0000010000; end //LEFT
				6 : begin controller = 10'b0000100000; end //RIGHT
				7 : begin controller = 10'b0001000000; end //UP
				8 : begin controller = 10'b00100000000; end //DOWN
				9 : begin controller = 10'b01000000000; end //R1
				10 : begin controller = 10'b1000000000; end //START
				default : ; //NONE				
			endcase
		end
    end
    
endmodule
