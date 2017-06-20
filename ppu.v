//picture processing unit PPU
//statemachine writes the new absolute positions of the dynamic sprites, which the the ppu can store in his sprite table
//statemachine determines changes for static sprites
//Here only absolute positions are used

//ppu determines the relative positions i.f.o. the screen
//depentend off the display_col and display_row new positions are calculated

//first note: the game has 3 kinds of objects -> 1.Moving sprite	2.Background or stationary sprite	3.Map or scenary
//second note: a object has a 256x256 bit pattern

//Video RAM
	//Attribute Table: stores the the Moving sprites which needs to be rendered in the next frame [sprite 1 and 2 details]
	//Motion Pattern gen: stores the Patterns of the Moving sprites
	//Stationaty Pattern gen: stores the Patterns of the stationary sprites
	//map --> scenary is stored in a 156x156 word memory which outputs the colors of a 4x4 tile
	//Color table sprites: Stores the color patterns of the moving or stationary sprites



module ppu(clock, reset, hsync, vsync, red, green, blue, update, sprites, statics, offset_x, offset_y); 

//input and output values
	input clock, reset;
	input update;		//When update becomes true, the sprite and static table are updated by the cpu
	
	//Determined by the State Machine (CPU)
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	input [57:0] sprites;		//updated sprite table
	input [0:0] statics;		//updated static table
	
	//the current x-position top corner of the viewport
	input [11:0] offset_x;
	//the current y-position top corner of the viewport
	input [11:0] offset_y;
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	output vsync, hsync;
	output reg [9:0] red, green, blue;
	
	//define offset of the map
	reg [11:0] offset_x_r;
	reg [11:0] offset_y_r;

	//calculate relative positions
	//the current x-position of pixel to write (screencoord)
		wire [11:0] display_x;
	//the current y-position of the pixel to write (screencoord)
		wire [10:0] display_y;
		
	//the absolute x-position of the write
		wire [11:0] abs_x;
	//the absolute y-position of the write
		wire [11:0] abs_y;
		
		//current tile collumn-position in the map absolute
		wire [2:0] collumn;
		//current tile row-position in the map absolute
		wire [2:0] row;
		
		//current relative x-position in a certain tile
		wire [7:0] rel_x;
		//current relative y-position in a certain tile
		wire [7:0] rel_y;
		
		assign abs_x = offset_x_r + display_x;
		assign abs_y = offset_y_r + display_y;
		assign collumn = abs_x[10:4];
		assign row = abs_y[10:8];
		assign rel_x = abs_x[7:0];
		assign rel_y = abs_y[7:0];
		
		//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		//DATABUS
		//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		//defining the sprite table
		//sprite: from least sig to heighest sig bits
		// xpos, ypos in world each 11 bits
		// char
		// attribute -> color
		reg [27:0] sprite1, sprite2;
		wire [11:0] display_x_sp1, display_x_sp2;
		wire [10:0] display_y_sp1, display_y_sp2;
		
		assign display_x_sp1 = {sprite1[27:19],{2{1'b0}}}+{16{1'b1}};
		assign display_x_sp2 = {sprite2[27:19],{2{1'b0}}}+{16{1'b1}};
		
		assign display_y_sp1 = {1'b0,{11{1'b1}}-{sprite1[18:10],{2{1'b0}}}};
		assign display_y_sp2 = {1'b0,{11{1'b1}}-{sprite2[18:10],{2{1'b0}}}};
		
		
		
		//defining the static table
		//static: from least sig to heighest sig bits
		// collumn, row in 7 bits each
		// char
		// attribute -> color
		reg [0:0] static1, static2, static3, static4, static5, static6; //test
		
		//schrijft nieuwe registers
		always @(posedge clock or posedge reset) begin
			if(reset) begin
				offset_x_r = 0;
				offset_y_r = 0;
				
				sprite1 = 0;
				sprite2 = 0;
				
				static1 = 0;
				static2 = 0;
				static3 = 0;
				static4 = 0;
				static5 = 0;
				static6 = 0;
			end
			else begin
				if(update && hsync) begin
					offset_x_r = offset_x;
					offset_y_r = offset_y;
					
					sprite1 = sprites[57:32];
					sprite2 = sprites[31:0];
				end
				if(update && vsync) begin
					static1 = statics[0:0];
					static2 = statics[0:0];
					static3 = statics[0:0];
					static4 = statics[0:0];
					static5 = statics[0:0];
					static6 = statics[0:0];
				end		
			end
		end
		
		//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		//END DATABUS
		//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		//select the correct sprite or  ifo the current position
		reg [4:0] selSprite;
		reg [7:0] relx_s1, relx_s2;
		reg negx_s1, negx_s2;
		reg [7:0] rely_s1, rely_s2;
		reg negy_s1, negy_s2;
		always @(display_x_sp1 or abs_x) begin
			if(display_x_sp1<abs_x) begin
				relx_s1 = abs_x-display_x_sp1;
				negx_s1 = 0;	
			end
			else begin
				relx_s1 = display_x_sp1 - abs_x;
				negx_s1 = 1;
			end
		end
		
		always @(display_x_sp2 or abs_x) begin
			if(display_x_sp2<abs_x) begin
				relx_s2 = abs_x-display_x_sp2;
				negx_s2 = 0;
			end
			else begin
				relx_s2 = display_x_sp2 - abs_x;
				negx_s2 = 1;
			end
		end
		
		always @(display_y_sp1 or abs_y) begin
			if(display_y_sp1<abs_y) begin
				rely_s1 = abs_y-display_y_sp1;
				negy_s1 = 0;
			end
			else begin
				negy_s1 = 1;
			end
		end
		
		always @(display_y_sp2 or abs_y) begin
			if(display_y_sp2<abs_y) begin
				rely_s2 = abs_y-display_y_sp2;
				negy_s2 = 0;
			end
			else begin
				negy_s2 = 1;
			end
		end
		
		reg negx, negy;
		reg relxs, relys;
		reg sprite_en;
		always @(sprite1 or sprite2 or abs_x or abs_y) begin
			sprite_en = 0;
			selSprite = 0;
			negx = 0;
			negy = 0;
			relxs = 0;
			relys = 0;
			
			if((relx_s1 < 127) && (rely_s1<127) && !negy_s1) begin 
				selSprite = sprite1[7:0];
				negx = negx_s1;
				relxs = relx_s1;
				relys = rely_s1;
			end
			if((relx_s2 < 127) && (rely_s2<127) && !negy_s2) begin
				selSprite = sprite2[7:0];
				negx = negx_s2;
				relxs = relx_s2;
				relys = rely_s2;
			end
			if(selSprite != 0) sprite_en = 1;
		end
		
		//select the correct static i.f.o. the current position
		//define the line buffer
		wire [21:0] selStatic; 
		assign selStatic = 0;
		
//		reg static_en;
//			test
		wire static_en;
		assign static_en = 0;
//		always @(static1 or static2 or static3 or static4 or static5 or static6 or collumn or row) begin
//			static_en = 0;
//			selStatic = 0;
//			if((static1[6:0]-collumn)== 0 && (static1[13:7]-row)==0) selStatic = static1;
//			if((static2[6:0]-collumn)== 0 && (static2[13:7]-row)==0) selStatic = static2;
//			if((static3[6:0]-collumn)== 0 && (static3[13:7]-row)==0) selStatic = static3;
//			if((static4[6:0]-collumn)== 0 && (static4[13:7]-row)==0) selStatic = static4;
//			if((static5[6:0]-collumn)== 0 && (static5[13:7]-row)==0) selStatic = static5;
//			if((static6[6:0]-collumn)== 0 && (static6[13:7]-row)==0) selStatic = static6;
//			
//			if(selStatic != 0) static_en = 1;
//		end	
	
//define interfaces
	//vga controller for communicating via VGA-protocol
		wire visible;
		//declaration of the display controller 
		vga_controller #(.HOR_FIELD (1279), .HOR_STR_SYNC(1327), .HOR_STP_SYNC(1439), .HOR_TOTAL (1687), .VER_FIELD (1023), .VER_STR_SYNC (1024), .VER_STP_SYNC (1027), .VER_TOTAL (1065))
		controller (.clock(clock), .reset(reset), .display_col(display_x), .display_row(display_y), .visible(visible), .hsync(hsync), .vsync(vsync));
	
	//videoRAM
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	//implementation of the background
	//Use just a picture as background
	
	wire [11:0] mapcolors;
	//Direct memory access
	//background table:
	//1024x1024 pixels
	//each pixel has a color value of 12 bit (4 red, 4 green, 4 blue)
	map map(.clock(clock), .x(display_x-10), .y(display_y), .out(mapcolors));
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	//attribute table for static sprites
	//64 different static sprites
	//each tile described with 6 bits (->character on this position) and 2 bits attribute (-> color pallete)
	//select = #sprite number
	wire [1:0] staticout;
	//this memory defines the different building block of the static sprites
	//stat_sprite_mem ssm(.clock(clock), .select(selStatic[19:14]), .x(rel_x), .y(rel_y), .out(staticout));
	assign staticout = 0;
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	//attribute table -> written each jump of hor line - row
	//select = #sprite number
	wire [1:0] spriteout;
	mov_sprite_mem msm(.clock(clock), .char(selSprite[3:0]), .x(rel_xs), .y(rel_ys), .nx(neg_y), .out(spriteout), .mirror(!selSprite[4]));
	
	//determine what needs to be rendered on this pos
	//sprite has priority over static
	reg [3:0] spritebuf;
	always @(posedge clock or posedge reset) begin
		if(reset) spritebuf =0;
		else begin
			if(sprite_en) begin
				spritebuf = {/*sel kleur*/{2{1'b0}}, spriteout};
			end
			else if(static_en) begin
				spritebuf = {/*sel kleur*/{2{1'b0}}, staticout};
			end
			else begin
				spritebuf = 0;
			end
		end
	end 
	
	//colortable
	//the most sig bit of the selColor address selects if the map or the spirte colortable is used
	wire map_enable;
	assign map_enable = ~(sprite_en | static_en);
	//4 bits for selecting the colors // first 2 for pallete select // last 2 for pixeldata (dependent on x and y)
	wire [23:0] scolors;
	ram_colortable ct(.address(spritebuf), .clock(clock), .data({24{1'b0}}), .wren(1'b0), .q(scolors));
	
	//synthesise colors of map and colors of sprites
	reg [23:0] colors;
	always @(map_enable or scolors) begin
		if(map_enable) colors = {mapcolors[11:8], {4{1'b0}}, mapcolors[7:4], {4{1'b0}}, mapcolors[3:0], {4{1'b0}}};
		else colors = scolors;
	end

//determine rgb values of the current pixel with coordinates x = display_col and y = display_row
		always @(posedge clock) begin
			if (visible) begin
				//what color should the current pixel be?
				if(display_x < 128 || display_x >1152) begin
					//Standard values
					red = {10{1'b0}};
					green = {10{1'b0}};
					blue = {10{1'b1}};
				end
				else begin
					red = {colors[23:16], {2{1'b0}}};
					green = {colors[15:8], {2{1'b0}}};
					blue = {colors[7:0], {2{1'b0}}};
				end
			end
			else begin
				red = {10{1'b0}};
				green = {10{1'b0}};
				blue = {10{1'b0}};
			end
		end
		
endmodule 