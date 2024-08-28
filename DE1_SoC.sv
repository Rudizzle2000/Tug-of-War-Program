

// This top-level module allows two players (player2 (left side), and player1 (right side)) to compete in a tug of war
// game on the FPGA board. The inputs are SW[9] as the inverted reset switch, KEY[3] for player2, and KEY[0] for player1.
// The playing field will be outputs LEDR[9:1] for which one key press results in one LEDR moving one spot either to the 
// left (KEY[3]) or to the right (KEY[0]). The result/winner of the game will be shown on the HEX0 output display as either
// a 2 for player2 or 1 for player1. 

// Overall inputs and outputs to the DE1_SoC module are listed below:
// Inputs: 10-bit SWs, 4-bit KEYs
// Outputs: 6 7-bit HEXs, 10-bit LEDRs
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	
	input logic CLOCK_50;
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY; 
	input logic [9:0] SW;
	logic reset; 

	assign reset = ~SW[9];
	
	// Connects the output of the meta module m1 to the input of the keypress module kp1.
	wire rightMeta;
	
 	// Connects the output of the meta module m2 to the input of the keypress module kp2.
	wire leftMeta;
	
	// Connects the output of the keypress module kp1 to the inputs of the .R() field in 
	// all eight of the normallight modules and the single centerlight module.
	wire user_R;
	
	// Connects the output of the keypress module kp2 to the inputs of the .L() field in 
	// all eight of the normallight modules and the single centerlight module.
	wire user_L; 	
	
   // Instantiates the meta module to terminate the possibility of metastability occuring 
   // within our system with inputs KEY[0] and KEY[3]. The output .q2() is a non-ambigous clean/clear 
	// signal of either logic 1 or 0.
	// Inputs: 50 MHz clock, 1-bit reset SW[9], 2-bit KEYs -> KEY[3] & KEY[0].
	// Outputs: 1-bit logic signal.
	meta m1 (.clk(CLOCK_50),  .reset(reset), .d1(~KEY[0]), .q2(rightMeta));
	meta m2 (.clk(CLOCK_50),  .reset(reset), .d1(~KEY[3]), .q2(leftMeta));
	
	// Instantiates the keypress module to ensure that one logic high on either KEY[3] or KEY[0] 
	// is read by the system as one keypress rather than multiple keypresses given the frequency of 
	// the clock (50MHz). The keypress module takes the ouput of the meta module as it's input, and 
	// outputs a signal that is both non-ambigous and properly read for every individual keypress given.
	// One keypress module:
	// Inputs: 50 MHz clock, 1-bit reset SW[9], 1-bit signal from meta module.
	// Outputs: 1-bit logic signal.
	keypress kp1 (.clk(CLOCK_50), .reset(reset), .in(rightMeta), .out(user_R));
	keypress kp2 (.clk(CLOCK_50), .reset(reset), .in(leftMeta), .out(user_L));
	
	// Instantiates four normallight modules to respresnt 4-1 individual LEDs on the FPGA board.
	// One normallight module:
	// Inputs: 50 MHz clock, 1-bit reset SW[9], 2-bit signal from both keypress modules (kp2 & kp1),
	//         the LED on both the left and right side of the current LED.
	// Outputs: 1-bit logic displayed on an individual LED on the FPGA.
   normallight LED1 (.clk(CLOCK_50), .reset(reset), .L(user_L), .R(user_R), .NL(LEDR[2]), .NR(), .lightOn(LEDR[1]));
   normallight LED2 (.clk(CLOCK_50), .reset(reset), .L(user_L), .R(user_R), .NL(LEDR[3]), .NR(LEDR[1]), .lightOn(LEDR[2]));
   normallight LED3 (.clk(CLOCK_50), .reset(reset), .L(user_L), .R(user_R), .NL(LEDR[4]), .NR(LEDR[2]), .lightOn(LEDR[3]));
   normallight LED4 (.clk(CLOCK_50), .reset(reset), .L(user_L), .R(user_R), .NL(LEDR[5]), .NR(LEDR[3]), .lightOn(LEDR[4]));
	
	// Instantiates four centerlight modules to respresnt the center LED (LED[5]) on the FPGA board.
	// One centerlight module:
	// Inputs: 50 MHz clock, 1-bit reset SW[9], 2-bit signal from both keypress modules (kp2 & kp1),
	//         the LED on both the left and right side of the center LED.
	// Outputs: 1-bit logic displayed on LED[5] on the FPGA.
	centerlight clight (.clk(CLOCK_50), .reset(reset), .L(user_L), .R(user_R), .NL(LEDR[6]), .NR(LEDR[4]), .lightOn(LEDR[5]));

	// Instantiates four normallight modules to respresnt 9-6 individual LEDs on the FPGA board.
	// One normallight module:
	// Inputs: 50 MHz clock, 1-bit reset SW[9], 2-bit signal from both keypress modules (kp2 & kp1),
	//         the LED on both the left and right side of the current LED.
	// Outputs: 1-bit logic displayed on an individual LED on the FPGA.
   normallight LED6 (.clk(CLOCK_50), .reset(reset), .L(user_L), .R(user_R), .NL(LEDR[7]), .NR(LEDR[5]), .lightOn(LEDR[6]));
   normallight LED7 (.clk(CLOCK_50), .reset(reset), .L(user_L), .R(user_R), .NL(LEDR[8]), .NR(LEDR[6]), .lightOn(LEDR[7]));
	normallight LED8 (.clk(CLOCK_50), .reset(reset), .L(user_L), .R(user_R), .NL(LEDR[9]), .NR(LEDR[7]), .lightOn(LEDR[8]));
	normallight LED9 (.clk(CLOCK_50), .reset(reset), .L(user_L), .R(user_R), .NL(), .NR(LEDR[8]), .lightOn(LEDR[9]));
	
	// Instantiates the victory module to show the winner of the game on the HEX0 7 segment display. The HEX will
	// display a 2 for player2 (left player) or 1 for player1 (right player).
	// Inputs: 50 MHz clock, 1-bit reset SW[9], 2-bit signal from both keypress modules (kp2 & kp1),
	//         the LED on both ends of the playing feild (LED[9] & LED[1]).
	// Outputs: 7-bit segment display.
	victory vcy (.clk(CLOCK_50), .reset(reset), .L(user_L), .R(user_R), .L_endLED(LEDR[9]), .R_endLED(LEDR[1]), .HEX(HEX0));
	

endmodule

// Testbench for DE1_SoC module. Tests winning cases for both player2 and player1 
// with 2-bit inputs of KEY[3] and KEY[0]. Further tests the case in which no one wins.
// Allows one to check that the correct output is displayed on LEDR HEX0.
module DE1_SoC_testbench();

	logic CLOCK_50; 
	logic [6:0] HEX0;
	logic [9:0] LEDR;
	logic [3:0] KEY; 
	logic [9:0] SW;
	
	// Instantiates DE1_SoC module
	DE1_SoC dut (.CLOCK_50, .SW, .KEY, .LEDR, .HEX0);
		
	parameter clock_period = 100;
		
	initial begin
		CLOCK_50 <= 0;
		forever #(clock_period /2) CLOCK_50 <= ~CLOCK_50;
					
	end
	
	initial begin
		
														@(posedge CLOCK_50);
		SW[9]<= 1;	KEY[3]<=0; KEY[0]<=1; 	@(posedge CLOCK_50);
														@(posedge CLOCK_50);
						KEY[3]<=1; KEY[0]<=1; 	@(posedge CLOCK_50);
									            	@(posedge CLOCK_50);
						KEY[3]<=0; KEY[0]<=1; 	@(posedge CLOCK_50);
														@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=1; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=0; KEY[0]<=1; 	@(posedge CLOCK_50); 
									            	@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=1; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 													
						KEY[3]<=0; KEY[0]<=1; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=1; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=0; KEY[0]<=1; 	@(posedge CLOCK_50); 
									            	@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=1; 	@(posedge CLOCK_50); // PLAYER 2 (LEFT) WINS
						
														@(posedge CLOCK_50); 
														@(posedge CLOCK_50);  
														@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 						
								  						@(posedge CLOCK_50);	
								  						@(posedge CLOCK_50);
								  						@(posedge CLOCK_50);											
		SW[9]<= 0;	                        @(posedge CLOCK_50); 
								  						@(posedge CLOCK_50);
		SW[9]<= 1;	                        @(posedge CLOCK_50); 
								  						@(posedge CLOCK_50);	
						KEY[3]<=1; KEY[0]<=0; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=1; 	@(posedge CLOCK_50); 
									            	@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=0; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=1; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=0; 	@(posedge CLOCK_50); 
									            	@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=1; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 													
						KEY[3]<=1; KEY[0]<=0; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=1; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=0; 	@(posedge CLOCK_50); 
									            	@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=1; 	@(posedge CLOCK_50); // PLAYER 1 (RIGHT) WINS																	
														
														@(posedge CLOCK_50);  
														@(posedge CLOCK_50); 
														@(posedge CLOCK_50);
		SW[9]<= 0;	                        @(posedge CLOCK_50); 
								  						@(posedge CLOCK_50);
		SW[9]<= 1;	                        @(posedge CLOCK_50); 
								  						@(posedge CLOCK_50);	
						KEY[3]<=1; KEY[0]<=0; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=0; KEY[0]<=1; 	@(posedge CLOCK_50); 
									            	@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=0; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=0; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=0; KEY[0]<=1; 	@(posedge CLOCK_50); 
									            	@(posedge CLOCK_50); 
						KEY[3]<=0; KEY[0]<=1; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 													
						KEY[3]<=1; KEY[0]<=0; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=0; KEY[0]<=1; 	@(posedge CLOCK_50); 
														@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=0; 	@(posedge CLOCK_50); 
									            	@(posedge CLOCK_50); 
						KEY[3]<=1; KEY[0]<=1; 	@(posedge CLOCK_50); 														
														@(posedge CLOCK_50); 													
														@(posedge CLOCK_50); // NO ONE WINS!	
														
			$stop;	
			
		end		
endmodule
