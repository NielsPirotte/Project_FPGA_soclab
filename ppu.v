//picture processing unit
//statemachine can put data on the databus, which the the ppu can store in his RAM
//the video ram has a mem mapping with different kinds of memory

//first note: the game has 3 kinds of objects -> 1.Moving sprite	2.Background or stationary sprite	3.Map or scenary
//second note: a object has a 16x16 bit pattern

//Video RAM
	//Attribute Table: stores the the Moving sprites which needs to be rendered in the next horizontal line -- 256Byte
	//Motion Pattern gen: stores the Patterns of the Moving sprites -- 4kByte
	//Stationaty Pattern gen: stores the Patterns of the stationary sprites -- 4kByte
	//Map gen: stores the Patterns of the Map tiles -- 512 kByte
	//Color table sprites: Stores the color patterns of the moving or stationary sprites -- 16 Byte
	//Color table map: Stores the color patterns of the map -- 16 Byte


module ppu(clock, reset, red, green, blue, hsync, vsync, attributes); 

//input and output values
	input clock, reset;
	input [] attributes; //not yet implemented
	
	output [9:0] red, green, blue;
	output vsync, hsync;
	
//define interfaces
	//vga controller for communicating via VGA-protocol
		wire visible;
		
		//the current x-position of pixel to write
		wire [11:0] display_col;
		//the current y-position of the pixel to write via VGA-protocol
		wire [10:0] display_row;
		
		vga_controller #(.HOR_FIELD (1279), .HOR_STR_SYNC(1327), .HOR_STP_SYNC(1439), .HOR_TOTAL (1687), .VER_FIELD (1023), .VER_STR_SYNC (1024), .VER_STP_SYNC (1027), .VER_TOTAL (1065))
		controller (.clock(clock), .reset(reset), .display_col(display_col), .display_row(display_row), .visible(visible), .hsync(hsync), .vsync(vsync));
		
	//videoRAM
	//attribute table -> written each jump of hor line - row
	
	//pattern generators
		//select = #sprite number
		//note: a sprite is 16x16x2 bits = 64bits
	mov_sprite_mem msm(.clock(clock), .select(), .x(), .y(), .out());
		//select = #sprite number
		//note: a sprite is 16x16x2 bits = 64bits
	stat_sprite_mem ssm(.clock(clock), .select(), .x(), .y(), .out());
		
	//map_mem //not yet implemented same principle as previous
	
	//colortable
	//the most sig bit of the selColor address selects if the map or the spirte colortable is used
	ram_colortable ct(.address(selColor), .clock(clock), .data(0), .wren(1'b0), .q());


//determine rgb values of the current pixel with coordinates x = display_col and y = display_row
		always @(posedge clock) begin 
			if (visible) begin
				//what color should the current pixel be?
				red = ?;
				green = ?;
				blue = ?;
			end
			else begin
				red = 0;
				green = 0;
				blue = 0;
			end
		end
		
endmodule 