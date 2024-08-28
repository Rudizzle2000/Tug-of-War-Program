

// This module respresnts the center LED (LED[5]) on the FPGA board.
// One centerlight module:
// Inputs: Clock, 1-bit reset, 2-bit signal from user left(L) and user right(R),
//         the LED on both the left(NL) and right(NR) side of the center LED.
// Outputs: 1-bit logic displayed on LED[5] on the FPGA.
module centerlight (clk, reset, L, R, NL, NR, lightOn);

	input logic clk, reset, L, R, NL, NR;
	output logic lightOn;
	
	enum {on, off} ps, ns;
	
	// Combinational logic that determines when the center LED should be on or off.
	always_comb begin
		case (ps)
			
			on:	if (L & R || ~L & ~R) ns = on;
					else if (~L & R || L & ~R) ns = off;					
					else ns = on;                         
					
			off: if (NR & L & ~R || NL & R & ~L) ns = on;
			
					else ns = off;
					
		endcase
	end
		
	assign lightOn = (ps == on); 

		// sequential logic that determines what should happen if reset is set hight or low.
		always_ff @(posedge clk) begin
			if (reset)
				ps <= on;
			else
				ps <= ns;
		end
endmodule
	
// Testbench for the centerlight module. Tests all conditions of input (rest 1-bit, L 1-bit, 
// R 1-bit NL 1-bit, NR 1-bit) that allows the centerlight module to 
// change states, and a few arbitrary conditions to see if the system can respond correctly.
// Allows one to check that the correct output is being given.
module centerlight_testbench();

	logic clk, reset, L, R, NL, NR, lightOn;
	
	// Instantiates the centerlight module.	
	centerlight dut (.clk, .reset, .L, .R, .NL, .NR, .lightOn);
		
		
	parameter clock_period = 100;
		
	initial begin
		clk <= 0;
		forever #(clock_period /2) clk <= ~clk;
					
	end 
	
	initial begin
		
			reset<= 1;            	@(posedge clk); //ON
			reset<= 0; L<=1; R<=1; 	@(posedge clk); 
											@(posedge clk); 
			reset<= 1;            	@(posedge clk); 
											@(posedge clk); 
			reset<= 0; L<=0; R<=0; 	@(posedge clk); 
											@(posedge clk); 											
						  L<=1; R<=0; 	@(posedge clk); 
							
											@(posedge clk); //OFF
	NL<= 0; NR<=0; L<=0; R<=0; 	@(posedge clk); 
											@(posedge clk); 	
	NL<= 0; NR<=0; L<=1; R<=1; 	@(posedge clk); 
											@(posedge clk); 
	NL<= 1; NR<=1; L<=0; R<=0; 	@(posedge clk); 
											@(posedge clk); 
	NL<= 0; NR<=1; L<=0; R<=0; 	@(posedge clk); 
											@(posedge clk); 
	NL<= 1; NR<=0; L<=0; R<=0; 	@(posedge clk); 
											@(posedge clk); 									
	NL<= 1; NR<=0; L<=0; R<=1; 	@(posedge clk); //ON 
											@(posedge clk); // OFF										
	NL<= 0; NR<=1; L<=1; R<=0; 	@(posedge clk); // ON
										
	NL<= 0; NR<=0; L<=0; R<=1; 	@(posedge clk); 
			reset<= 1;            	@(posedge clk); 	
											@(posedge clk); 		

	
			$stop;										
		end			
endmodule		