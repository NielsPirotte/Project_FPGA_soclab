//picture processing unit
//statemachine writes the new relative positions of the dynamic sprites, which the the ppu can store in his sprite table
//statemachine determines changes for static sprites
//Here only absolute positions are used

//ppu determines the relative positions ifo the screen
//depentend off the display_col and display_row new positions are calculated

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
	input update;		//When update becomes true, the sprite and static table are updated
	
	//Determined by the State Machine (CPU)
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	input [] offset_pos
	input [] sprites;		//updated sprite table
	input [] statics;		//updated static table
	
	//the current x-position top corner of the viewport
	input [11:0] offset_x;
	//the current y-position top corner of the viewport
	input [11:0] offset_y;
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	output [9:0] red, green, blue;
	output vsync, hsync;
	
	//define registers and buffers
	reg [11:0] offset_x_r;
	reg [11:0] offset_y_r;

	//calculate relative positions
	//the current x-position of pixel to write
		wire [11:0] display_col;
		//the current y-position of the pixel to write via VGA-protocol
		wire [10:0] display_row;
		
		//current tile collumn-position in the map absolute
		wire [6:0] collumn;
		//current tile row-position in the map absolute
		wire [6:0] row;
		
		//current relative x-position in a certain tile
		wire [3:0] rel_x;
		//current relative y-position in a certain tile
		wire [3:0] rel_y;

		assign collumn = (offset_x + display_col)[10:4];
		assign row = (offset_y + display_row)[10:4];
		assign rel_x = (offset_x + display_col)[3:0];
		assign rel_y = (offset_y + display_row)[3:0];
		
		//defining the sprite table
		//sprite:
		// xpos, ypos in world each 11 bits
		// char
		// attribute
		reg [29:0] sprite1, sprite2, sprite3, sprite4, sprite5 sprite6;
		
		//defining the static table
		reg [21:0] static1, static2, static3, static4, static5, static6;
		
		//schrijft nieuwe registers
		always @(posedge clock or posedge reset) begin
			if(reset) begin 
				sprite1 = sprites[29:0];
				sprite2 = sprites[59:30];
				sprite3 = sprites[89:60];
				sprite4 = sprites[119:90];
				sprite5 = sprites[149:120];
				sprite6 = sprites[179:150];
				
				static1 = statics[29:0];
				static2 = statics[59:30];
				static3 = statics[89:60];
				static4 = statics[119:90];
				static5 = statics[149:120];
				static6 = statics[179:150];
			end
			else begin
				sprite1 = 0;
				sprite2 = 0;
				sprite3 = 0;
				sprite4 = 0;
				sprite5 = 0;
				sprite6 = 0;
				
				static1 = 0;
				static2 = 0;
				static3 = 0;
				static4 = 0;
				static5 = 0;
				static6 = 0;
		
		
			end
		end
	
//define interfaces
	//vga controller for communicating via VGA-protocol
		wire visible;
		//declaration of the display controller 
		vga_controller #(.HOR_FIELD (1279), .HOR_STR_SYNC(1327), .HOR_STP_SYNC(1439), .HOR_TOTAL (1687), .VER_FIELD (1023), .VER_STR_SYNC (1024), .VER_STP_SYNC (1027), .VER_TOTAL (1065))
		controller (.clock(clock), .reset(reset), .display_col(display_col), .display_row(display_row), .visible(visible), .hsync(hsync), .vsync(vsync));
	
	//videoRAM
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	//implementation of the background
	wire [5:0] selmap;
	
	//background table:
	//128*128 tiles
	//each tile described with 6 bits (->character on this position)
	map map(.clock(clock), .collumn(collumn), .row(row), .out(selmap));
	
	//the map memory
	//this memory defines the different building blocks of the memory
	//each tile consist of 16x16 pixels
	wire [1:0] mapout;
	map_mem mm(.clock(clock), .select(selmap), .x(rel_x), .y(rel_y), .out(mapout));
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	//attribute table for static sprites
	//64 different static sprites
	//each tile described with 6 bits (->character on this position) and 2 bits attribute (-> color pallete)
	wire [5:0] selstatic;
	wire stat_enable;
	
	//select = #sprite number
	//note: a sprite is 16x16x2 bits = 64bits
	wire [1:0] staticout;
	//this memory defines the different building block of the static sprites
	stat_sprite_mem ssm(.clock(clock), .select(selstatic), .x(rel_x), .y(rel_y), .out(staticout)); //ok
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	//attribute table -> written each jump of hor line - row
	wire [5:0] selSprite;
	//select = #sprite number
		//note: a sprite is 16x16x2 bits = 64bits
	wire [1:0] spriteout;
	wire sprite_enable;
	mov_sprite_mem msm(.clock(clock), .select(selSprite), .x(selRelX), .y(selRelY), .out(spriteout));

	
	//colortable
	//the most sig bit of the selColor address selects if the map or the spirte colortable is used
	wire map_enable;
	assign map_enable = ~(sprite_enable | stat_enable);
	wire [4:0] selcolor; //first bit for select map colors or sprite colors
	assign selcolor =  {map_enable, sel};
	//4 bits for selecting the colors // first 2 for pallete select // last 2 for pixeldata (dependent on x and y)
	ram_colortable ct(.address(selColor), .clock(clock), .data(0), .wren(1'b0), .q(colors));
	
	wire [3:0] sel;
	always @(sprite_enable or stat_enable or selsprite[1:0] or spriteout or selstatic[1:0] or staticout or selmap[1:0] or mapout) begin
		if(sprite_enable) begin
			sel = {selsprite[1:0], spriteout};
		end
		else if(stat_enable) begin
			sel = {selstatic[1:0], staticout};
		end
		else begin
			sel = {{2{1'b0}}, mapout};
		end
	end 

//determine rgb values of the current pixel with coordinates x = display_col and y = display_row
		always @(posedge clock) begin 
			if (visible) begin
				//what color should the current pixel be?
				red = colors[23:16];
				green = colors[15:8];
				blue = colors[7:0];
			end
			else begin
				red = 0;
				green = 0;
				blue = 0;
			end
		end
		
endmodule 