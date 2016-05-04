module cmp #(parameter WIDTH = 4)(	input	[WIDTH-1:0]	a, b, 
									output 				gt);

	wire gt;

	assign gt = (a > b) ? 1 : 0;

endmodule

module cnt #(parameter WIDTH = 4)(	input	[WIDTH-1:0]	D,
									input 				ld, en, clk,
									output 	[WIDTH-1:0] Q);

	reg [WIDTH-1:0] mem;

	assign Q = mem;

	always @ (posedge clk) begin
		if(en) begin
			if(ld) mem <= D;
			else mem <= mem - 1;
		end
	end
endmodule

module mul #(parameter 	IN_WIDTH = 4,
						OUT_WIDTH = 32)
			(	input 	[OUT_WIDTH-1:0]	x, 
				input	[IN_WIDTH-1:0]	y,
				output 	[OUT_WIDTH-1:0]	z);

	assign z = x * y;

endmodule

module mux #(parameter WIDTH = 32)(	input	[WIDTH-1:0]	in_0, in_1,
									input 				sel,
									output 	[WIDTH-1:0] out);

	wire [WIDTH-1:0] out;

	assign out = sel ? in_1 : in_0;

endmodule 

module register #(parameter WIDTH = 32)(input 	[WIDTH-1: 0] 	D,
										input 					clk, ld,
										output 	[WIDTH-1:0] 	Q);

	reg [WIDTH-1:0] mem;

	assign Q = mem;

	initial begin
		mem <= 0;
	end

	always @ (posedge clk) begin
		if(ld) 
			mem <= D;
		else 
			mem <= mem;
	end
endmodule

module tri_buff #(parameter WIDTH = 32)(input	[WIDTH-1:0]	in,
										input 				oe,
										output 	[WIDTH-1:0] out);

	wire [WIDTH-1:0] out;

	assign out = oe ? in : {WIDTH{1'bz}};

endmodule

module CU(	input 				clk, go, rst, gt,
			output	reg			dn,
			output	reg	[4:0] 	CW);

	reg [2:0] CS;
	reg [2:0] NS;

	parameter	s0 = 3'b000, 
				s1 = 3'b001,  
				s2 = 3'b010; 
				//s3 = 3'b011;

	always@(go, gt, CS)  
		begin
		case(CS)
			s0: begin
				NS <= go ? s1 : s0;
				end
			s1: NS <= s2;
			s2: begin
				NS <= gt ? s2 : s0;
				end
			//s3: NS <= s0;
			default: NS <= s0;
		endcase
		end
		
	always@(posedge clk, posedge rst)
		begin
			CS <= rst ? s0 : NS;		
		end

/*
CW <=> cnt_en---cnt_ld---reg_sel---reg_ld---out_en
*/
	
always@(CS, gt, go)
	begin
	CW = 5'b0;
	case(CS)
		s0: begin 
			CW = go ? 5'b11010 : 5'b0;
			dn = 1'b0;
			end
		s1: begin
			CW = 5'b00100;
			end
		s2: begin
			CW = gt ? 5'b10110 : 5'b00111;
			dn = gt ? 1'b0 : 1'b1;
			end
		/*s3: begin 
			cs = s3;
			CW = 5'b00001;
			dn = 1'b1;
			end*/
	endcase
	end
	
endmodule

module DP #(parameter WIDTH = 32)(	input 				clk,
									input 	[3:0] 		n,
									input 	[4:0] 		CW,
									output 	[WIDTH-1:0] out,
									output 				gt);

	wire cnt_ld, cnt_en, reg_sel, reg_ld, out_en, gt;
	wire [3:0] cnt_out,
	wire [WIDTH-1:0] mux_out, mul_out, reg_out, out;

	/*
	CW <=> cnt_en---cnt_ld---reg_sel---reg_ld---out_en
	*/

	assign {cnt_en, cnt_ld, reg_sel, reg_ld, out_en} = CW; 

	// instantiate the building blocks
	//{{WIDTH-1{1'b0}},1'b1} = 32'b1 if WIDTH = 32

	mux #(WIDTH) U0(.in_0(1),
					.in_1(mul_out),
					.sel(reg_sel),
					.out(mux_out));

	cmp #(4) 	U1(	.a(cnt_out),
					.b(1),
					.gt(gt));

	mul #(4, WIDTH) U2(	.x(reg_out), 
						.y(cnt_out),
						.z(mul_out));

	register #(WIDTH) U3(	.D(mux_out),
							.Q(reg_out),
							.clk(clk),
							.ld(reg_ld));

	cnt #(4) 	U4(.ld(cnt_ld),
					.en(cnt_en),
					.clk(clk),
					.D(n),
					.Q(cnt_out));

	tri_buff #(WIDTH) U5(	.in(reg_out),
							.out(out),
							.oe(out_en));

endmodule //DP

module factorial_mod #(parameter WIDTH = 32) (	input 				go, clk, rst,
												input	[3:0]		n,
												output 	[WIDTH-1:0] out,
												output 				dn);

	wire [4:0] CW;
	wire gt;

	CU K1
	(	
		.clk 	(clk), 
		.go 	(go), 
		.rst 	(rst), 
		.gt 	(gt),
		.dn 	(dn), 
		.CW 	(CW)
	);

	DP #(WIDTH) K2
	(	
		.clk 	(clk), 
		.n 		(n), 
		.gt 	(gt), 
		.out 	(out), 
		.CW 	(CW)
	);
		
endmodule

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

module d_reg #(parameter WIDTH = 8) (	input					clk,
										input		[WIDTH-1:0]	d,
										output	reg	[WIDTH-1:0]	q );
	always @ (posedge clk) begin
			q <= d;
	end
endmodule	

module sr_reg(	input		clk, s, r,
				output	reg	q );
				
	always @ (posedge clk) begin
		if(s)
			q <= 1'b1;
		else if(r)
			q <= 1'b0;
	end
endmodule	

module fact_dec (	input			we,
					input	[1:0] 	a,
					output			we1, we2,
					output	[1:0]	rd_sel);
					
	reg [3:0] controls;
	
	assign {we1, we2, [1:0] rd_sel} = controls;
	
	always @ (*) begin
		case(a)
			2'b00: begin
				if(we)
					controls <= 4'b1000;
				else
					controls <= 4'b0000;
			end
			2'b01: begin
				if(we)
					controls <= 4'b0101;
				else
					controls <= 4'b0001;
			end
			2'b10: 	controls <= 4'b0010;
			2'b11: 	controls <= 4'b0011;
			default: controls <= 4'bx;
		endcase
	end			
endmodule

module fact_top(input			we, clk, rst,
				input 	[1:0] 	a,
				input 	[3:0] 	wd,
				output 	[31:0] 	rd);

	wire	[3:0]	n;
	wire			we1, we2, go, go_pulse_cmb, go_pulse, done, rs_done;
	wire	[1:0] 	rd_sel;
	wire	[31:0]	nf, result;

	assign pulse = wd[0] & we2;
	
	fact_dec dec
	(	
		.we 	(we), 
		.a 		(a), 
		.we1 	(we1), 
		.we2 	(we2), 
		.rd_sel (rd_sel)	
	);
	en_reg #(4) nreg
	(	
		.clk 	(clk), 
		.en		(we1), 
		.d 		(wd), 
		.q 		(n)	
	);
	en_reg #(1) goreg
	(
		.clk	(clk),
		.en		(we2), 
		.d 		(wd[0]), 
		.q		(go)
	);
	d_reg #(1) pulsereg
	(
		.clk	(clk),
		.d 		(go_pulse_cmb),
		.q 		(go_pulse)	
	);
	factorial_mod #(32) fact_mod
	(	
		.go 	(go_pulse), 
		.clk 	(clk), 
		.rst 	(rst),
		.n 		(n),
		.out 	(nf),
		.dn 	(done)
	);
	sr_reg donereg
	(
		.clk 	(clk),
		.s 		(done),
		.r 		(go_pulse_cmb),
		.q 		(rs_done)	
	);
	en_reg #(32) resultreg
	(
		.clk 	(clk),
		.en 	(done),
		.d 		(nf),
		.q 		(result)	
	);
	mux4 #(32) mux
	(
		.d0 ({28'b0, n}), 
		.d1 ({31'b0, go}), 
		.d2 ({31'b0, rs_done}), 
		.d3 (result), 
		.s 	(rd_sel), 
		.y 	(rd)
	);

endmodule		