
// This module determines and show the winner of the game on the HEX 7 segment display. The HEX will
// display a 2 for player2 (left player) or 1 for player1 (right player).
// Inputs: Clock, 1-bit reset, 2-bit signal from user left(L) and user right(R),
//         the LEDs on both ends of the playing feild.
// Outputs: 7-bit segment display.
module victory (clk, reset, L, R, L_endLED, R_endLED, HEX);

	input logic clk, reset, L, R, L_endLED, R_endLED;
	output logic [6:0] HEX;
	
	enum {Anything, Lwins, Rwins} ps, ns;

	// Combinational logic that determines who wins.	
	always_comb begin
		case (ps)
		
			Anything:   if (L & ~R & L_endLED & ~R_endLED) ns = Lwins;
							
							else if (~L & R & ~L_endLED & R_endLED) ns = Rwins;	
								
							else ns = Anything;
			
			Lwins: ns = Lwins;
					 
			Rwins: ns = Rwins;
			
		endcase
	end 
	
	// Combinational logic that determines what should be displayed on the HEX display.
	always_comb begin
		case (HEX)
		
			HEX:	if (ps == Lwins) HEX = 7'b0100100;
				
					else if (ps == Rwins) HEX = 7'b1111001;
						
					else HEX = 7'b1000000;
		
		endcase
	end 
	
	// sequential logic that determines what should happen if reset is set hight or low.
	always_ff @(posedge clk) begin
		if (reset)
			ps <= Anything;
		else
			ps <= ns;
	end
	
endmodule

// Testbench for the victory module. Tests winning cases for both player2 (left) and player1 (right) 
// with 2-bit inputs of L and R. Further tests the case in which no one wins.
// Allows one to check that the correct output is displayed on LEDR HEX0.
module victory_testbench();

	logic clk, reset, L, R, L_endLED, R_endLED;
	logic [6:0] HEX;
	
	// Instatiates the victory module.	
	victory dut (.clk, .reset, .L, .R, .L_endLED, .R_endLED, .HEX);
			
	parameter clock_period = 100;
		
	initial begin
		clk <= 0;
		forever #(clock_period /2) clk <= ~clk;
					
	end 
	
	initial begin
	
																				@(posedge clk); 
			reset<=0; L<=1; R<=0; L_endLED<=1; R_endLED<=0;		@(posedge clk); 
			reset<=1; L<=0; R<=0; L_endLED<=0; R_endLED<=0;		@(posedge clk); 	
			reset<=0; L<=0; R<=1; L_endLED<=0; R_endLED<=1;		@(posedge clk); 
			reset<=1; L<=0; R<=0; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
			reset<=0; L<=1; R<=0; L_endLED<=1; R_endLED<=0;		@(posedge clk); 
			reset<=1; L<=0; R<=0; L_endLED<=0; R_endLED<=0;		@(posedge clk); 	
			reset<=0; L<=0; R<=1; L_endLED<=0; R_endLED<=1;		@(posedge clk); 
			reset<=0; L<=0; R<=0; L_endLED<=0; R_endLED<=0;		@(posedge clk);	
			reset<=1;            							         @(posedge clk); 
			reset<=0; L<=0; R<=0; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=0; L_endLED<=0; R_endLED<=1;		@(posedge clk); 
						 L<=0; R<=0; L_endLED<=1; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=0; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
						 L<=0; R<=1; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=1; L_endLED<=1; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=1; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=0; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=1; R<=0; L_endLED<=0; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=0; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=1; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=1; R<=1; L_endLED<=0; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=1; L_endLED<=1; R_endLED<=0;		@(posedge clk); 
						 L<=1; R<=1; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
			
						 L<=0; R<=1; L_endLED<=0; R_endLED<=1;		@(posedge clk); // right wins
						 L<=0; R<=0; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=0; L_endLED<=0; R_endLED<=1;		@(posedge clk); 
						 L<=0; R<=0; L_endLED<=1; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=0; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
						 L<=0; R<=1; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=1; L_endLED<=1; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=1; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=0; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=1; R<=0; L_endLED<=0; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=0; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=1; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=1; R<=1; L_endLED<=0; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=1; L_endLED<=1; R_endLED<=0;		@(posedge clk); 
			reset<=1; L<=1; R<=1; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
			
			reset<=0; L<=1; R<=0; L_endLED<=1; R_endLED<=0;		@(posedge clk); // left wins
						 L<=0; R<=0; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=0; L_endLED<=0; R_endLED<=1;		@(posedge clk); 
						 L<=0; R<=0; L_endLED<=1; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=0; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
						 L<=0; R<=1; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=1; L_endLED<=1; R_endLED<=0;		@(posedge clk); 
						 L<=0; R<=1; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=0; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=1; R<=0; L_endLED<=0; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=0; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=1; L_endLED<=0; R_endLED<=0;		@(posedge clk); 
						 L<=1; R<=1; L_endLED<=0; R_endLED<=1;		@(posedge clk); 
						 L<=1; R<=1; L_endLED<=1; R_endLED<=0;		@(posedge clk); 
			reset<=1; L<=1; R<=1; L_endLED<=1; R_endLED<=1;		@(posedge clk); 
																				@(posedge clk); 
																				@(posedge clk); 													
			$stop;
			
		end			
endmodule		

