module mux4 #(parameter WIDTH = 8) (input	[WIDTH-1:0]	d0, d1, d2, d3, 
									input	[1:0]			s, 
									output	[WIDTH-1:0]	y );

	always @ (*) begin
		case(s)
			2'b00: y = d0;
			2'b01: y = d1;
			2'b10: y = d2;
			2'b11: y = d4;
			default: y = 0;
		endcase
	end 
endmodule

module en_reg #(parameter WIDTH = 8) (	input					clk, en,
										input		[WIDTH-1:0]	d,
										output	reg	[WIDTH-1:0]	q );
	always @ (posedge clk) begin
		if(en)
			q <= d;
	end
endmodule	

module gpio_dec (	input			we,
					input	[1:0] 	a,
					output			we1, we2,
					output	[1:0]	rd_sel);
					
	reg [3:0] controls;
	
	assign {we1, we2, [1:0] rd_sel} = controls;
	
	always @ (*) begin
		case(a)
			2'b00: controls <= 4'b0000;
			2'b01: controls <= 4'b0001;
			2'b10: begin
				if(we)
					controls <= 4'b1010;
				else
					controls <= 4'b0010;
			end
			2'b11: begin
				if(we)
					controls <= 4'b0111;
				else
					controls <= 4'b0011;
			end
			default: controls <= 4'bx;
		endcase
	end			
endmodule

module gpio_top(input			we, clk,
				input 	[1:0] 	a,
				input 	[31:0] 	gp_in1, gp_in2, wd,
				output 	[31:0] 	gp_out1, gp_out2, rd);

	wire 	[31:0]	gp_out1, gp_out2;
	wire			we1, we2;
	wire	[1:0] 	rd_sel;
	
gpio_dec 		dec(we, a, we1, we2, rd_sel);
en_reg 	#(32)	reg1(clk, we1, wd, gp_out1);
en_reg  #(32)	reg2(clk, we2, wd, gp_out2);
mux4 #(32)		mux(gp_in1, gp_in2, gp_out1, gp_out2, rd_sel, rd);

endmodule


				