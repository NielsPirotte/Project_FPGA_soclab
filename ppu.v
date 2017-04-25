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


module ppu(clock, reset, red, green, blue, hsync, vsync, update, sprites, statics, offset_x, offset_y); 

//input and output values
	input clock, reset;
	input update;		//When update becomes true, the sprite and static table are updated
	
	//Determined by the State Machine (CPU)
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	input [179:0] sprites;		//updated sprite table
	input [131:0] statics;		//updated static table
	
	//the current x-position top corner of the viewport
	input [11:0] offset_x;
	//the current y-position top corner of the viewport
	input [11:0] offset_y;
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	output reg [9:0] red, green, blue;
	output vsync, hsync;
	
	//define registers and buffers
	reg [11:0] offset_x_r;
	reg [11:0] offset_y_r;

	//calculate relative positions
	//the current x-position of pixel to write
		wire [11:0] display_col;
	//the current y-position of the pixel to write via VGA-protocol
		wire [10:0] display_row;
		
	//the absolute x-position of the write
		wire [11:0] abs_x;
	//the absolute y-position of the write
		wire [11:0] abs_y;
		
		//current tile collumn-position in the map absolute
		wire [6:0] collumn;
		//current tile row-position in the map absolute
		wire [6:0] row;
		
		//current relative x-position in a certain tile
		wire [3:0] rel_x;
		//current relative y-position in a certain tile
		wire [3:0] rel_y;
		
		assign abs_x = offset_x_r + display_col;
		assign abs_y = offset_y_r + display_row;
		assign collumn = abs_x[10:4];
		assign row = abs_y[10:4];
		assign rel_x = abs_x[3:0];
		assign rel_y = abs_y[3:0];
		
		//defining the sprite table
		//sprite: from least sig to heighest sig bits
		// xpos, ypos in world each 11 bits
		// char
		// attribute
		reg [29:0] sprite1, sprite2, sprite3, sprite4, sprite5, sprite6;
		
		//defining the static table
		//static: from least sig to heighest sig bits
		// collumn, row in 7 bits each
		// char
		// attribute
		reg [21:0] static1, static2, static3, static4, static5, static6;
		
		//schrijft nieuwe registers
		always @(posedge clock or posedge reset) begin
			if(reset) begin
				offset_x_r = 0;
				offset_y_r = 0;
				
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
			else begin
				if(update) begin
					offset_x_r = offset_x;
					offset_y_r = offset_y;
					
					sprite1 = sprites[29:0];
					sprite2 = sprites[59:30];
					sprite3 = sprites[89:60];
					sprite4 = sprites[119:90];
					sprite5 = sprites[149:120];
					sprite6 = sprites[179:150];
					
					static1 = statics[21:0];
					static2 = statics[43:22];
					static3 = statics[65:44];
					static4 = statics[87:66];
					static5 = statics[109:88];
					static6 = statics[131:110];
				end		
			end
		end
		
		//select the correct sprite or  ifo the current position
		reg [29:0] selSprite;
		reg sprite_en;
		always @(sprite1 or sprite2 or sprite3 or sprite4 or sprite5 or sprite6 or abs_x or abs_y) begin
			sprite_en = 0;
			selSprite = 0;
			if((sprite1[10:0]-abs_x)== 0 && (sprite1[21:11]-abs_y)==0) selSprite = sprite1;
			if((sprite2[10:0]-abs_x)== 0 && (sprite2[21:11]-abs_y)==0) selSprite = sprite2;
			if((sprite3[10:0]-abs_x)== 0 && (sprite3[21:11]-abs_y)==0) selSprite = sprite3;
			if((sprite4[10:0]-abs_x)== 0 && (sprite4[21:11]-abs_y)==0) selSprite = sprite4;
			if((sprite5[10:0]-abs_x)== 0 && (sprite5[21:11]-abs_y)==0) selSprite = sprite5;
			if((sprite6[10:0]-abs_x)== 0 && (sprite6[21:11]-abs_y)==0) selSprite = sprite6;
			
			if(selSprite != 0) sprite_en = 1;
		end
		
		//select the correct static ifo the current position
		//define the line buffer
		reg [21:0] selStatic;
		reg static_en;
		always @(static1 or static2 or static3 or static4 or static5 or static6 or collumn or row) begin
			static_en = 0;
			selStatic = 0;
			if((static1[6:0]-collumn)== 0 && (static1[13:7]-row)==0) selStatic = static1;
			if((static2[6:0]-collumn)== 0 && (static2[13:7]-row)==0) selStatic = static2;
			if((static3[6:0]-collumn)== 0 && (static3[13:7]-row)==0) selStatic = static3;
			if((static4[6:0]-collumn)== 0 && (static4[13:7]-row)==0) selStatic = static4;
			if((static5[6:0]-collumn)== 0 && (static5[13:7]-row)==0) selStatic = static5;
			if((static6[6:0]-collumn)== 0 && (static6[13:7]-row)==0) selStatic = static6;
			
			if(selStatic != 0) static_en = 1;
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
	//select = #sprite number
	wire [1:0] staticout;
	//this memory defines the different building block of the static sprites
	stat_sprite_mem ssm(.clock(clock), .select(selStatic[19:14]), .x(rel_x), .y(rel_y), .out(staticout)); //ok
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	//attribute table -> written each jump of hor line - row
	//select = #sprite number
	wire [1:0] spriteout;
	mov_sprite_mem msm(.clock(clock), .select(selSprite[27:22]), .x(rel_x), .y(rel_y), .out(spriteout));
	
	//determine what needs to be rendered on this pos
	reg [3:0] sel;
	always @(sprite_en or static_en or selSprite[29:28] or spriteout or selStatic[21:20] or staticout or selmap[1:0] or mapout) begin
		if(sprite_en) begin
			sel = {selSprite[29:28], spriteout};
		end
		else if(static_en) begin
			sel = {selStatic[21:20], staticout};
		end
		else begin
			sel = {{2{1'b0}}, mapout};
		end
	end 
	
	//colortable
	//the most sig bit of the selColor address selects if the map or the spirte colortable is used
	wire map_enable;
	assign map_enable = ~(sprite_en | static_en);
	wire [4:0] selColor; //first bit for select map colors or sprite colors
	assign selColor =  {map_enable, sel};
	//4 bits for selecting the colors // first 2 for pallete select // last 2 for pixeldata (dependent on x and y)
	wire [23:0] colors;
	ram_colortable ct(.address(selColor), .clock(clock), .data({24{1'b0}}), .wren(1'b0), .q(colors));
	
	//renderline // not yet implemented
	
	
	

//determine rgb values of the current pixel with coordinates x = display_col and y = display_row
		always @(posedge clock) begin 
			if (visible) begin
				//what color should the current pixel be?
				red = {colors[23:16], {2{1'b0}}};
				green = {colors[15:8], {2{1'b0}}};
				blue = {colors[7:0], {2{1'b0}}};
			end
			else begin
				red = {10{1'b0}};
				green = {10{1'b0}};
				blue = {10{1'b0}};
			end
		end
		
endmodule 