//------------------------------------------------
// mipstest.v
// David_Harris@hmc.edu 23 October 2005
// Testbench for MIPS processor
//------------------------------------------------

module testbench();

  reg         	clk;
  reg         	reset;
  reg 	[4:0] 	dispSel;

  wire 	[31:0] 	dispDat, writedata;
  wire          memwrite;

  // instantiate device to be tested
  top dut(clk, reset, memwrite, writedata, dispSel, dispDat);
  
  // initialize test
  initial
    begin
      reset <= 1;
      dispSel <= 16;
      #22;
      reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5; clk <= 0; # 5;
    end

  // check that 24 (4!) is in reg $s0 (16d == 10000b)
  always@(negedge clk)
    begin
    	if(memwrite) begin
    		if(writedata !== 0)
    			$display("%d is being pushed onto stack!", writedata);
    	end
    	if(dispDat === 24) begin
          $display("Simulation succeeded");
          $stop;
        end
    end
endmodule



