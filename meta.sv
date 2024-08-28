

// This module terminates the possibility of metastability occuring 
// within our system with input d1. The output q2 is a non-ambigous clean/clear 
// signal of either logic 1 or 0.
// Inputs: clock, 1-bit reset, 1-bit logic signal.
// Outputs: 1-bit logic signal.
module meta (clk, reset, d1, q2);
	
	input logic clk, d1, reset;
	output logic q2;	
	logic q1;
	
	// sequential logic that determines when metastability treatment should be given.
	always_ff @ (posedge clk)
		
		if (reset)
			begin
				q1<=0;
				q2<=0;
			end
			
		else 
			begin
			q1<=d1;
			q2<=q1;
			end			
endmodule

// Testbench for meta module. Tests all combinations of input (rest 1-bit, and d1 1-bit) for
// variying spacing to showcase output in weird conditions.
// Allows one to check that the correct output is being given.
module meta_testbench();

		logic clk, reset, d1, q2;
		
		// Instantiates the meta module.
		meta dut (.clk, .reset, .d1, .q2);
		
		parameter clock_period = 100;
		
		initial begin
			clk <= 0;
			forever #(clock_period /2) clk <= ~clk;
					
		end 
		
		initial begin
		
			                    @(posedge clk);		
			reset <= 1;         @(posedge clk);	
			reset <= 0; d1<=0;  @(posedge clk);
			reset <= 0; d1<=1;  @(posedge clk);
			reset <= 1; d1<=0;  @(posedge clk);
			reset <= 1; d1<=1;  @(posedge clk);
			
			reset <= 0; d1<=0;  @(posedge clk);
					              @(posedge clk);
			reset <= 0; d1<=1;  @(posedge clk);
					              @(posedge clk);
			reset <= 1; d1<=0;  @(posedge clk);
					              @(posedge clk);
			reset <= 1; d1<=1;  @(posedge clk);
					              @(posedge clk);
									  
			reset <= 0; d1<=0;  @(posedge clk);
					              @(posedge clk);
					              @(posedge clk);
			reset <= 0; d1<=1;  @(posedge clk);
					              @(posedge clk);
					              @(posedge clk);
			reset <= 1; d1<=0;  @(posedge clk);
					              @(posedge clk);
					              @(posedge clk);
			reset <= 1; d1<=1;  @(posedge clk);
					              @(posedge clk);
					              @(posedge clk);
					              @(posedge clk);
									  
			$stop;						
							
		end 		
endmodule


