//------------------------------------------------
// top.v
// David_Harris@hmc.edu 9 November 2005
// Top level system including MIPS and memories
//------------------------------------------------
`timescale 1ns/1ns

module top(	input         	clk, reset,
			output			memwrite,
			output	[31:0]	writedata,
           	input 	[4:0]	dispSel,
           	output	[31:0]	dispDat);

  wire [31:0] pc, instr, readdata, dataadr;
  
  // instantiate processor and memories
  mips mips(clk, reset, pc, instr, memwrite, dataadr, writedata, readdata, dispSel, dispDat);
  imem imem(pc[7:2], instr);
  dmem dmem(clk, memwrite, dataadr, writedata, readdata);

endmodule
