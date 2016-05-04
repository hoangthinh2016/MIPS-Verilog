module addr_dec	(
					input	[31:0]	a,
					input			we,
					output			we1, we2, we_mem,
					output	[1:0]	rd_sel	
				);

	always @ (*) begin
		case ([15:8]a)
			8'h0: begin
				if(we) begin
					we_mem = 1'b1;
					rd_sel = 2'b01;
				end
				else begin
					we_mem = 1'b0;
					rd_sel = 2'b01;
				end
			end
			8'h8: begin
				if(we) begin
					we1 = 1'b1;
					rd_sel = 2'b10;
				end
				else begin
					we1 = 1'b0;
					rd_sel = 2'b10;
				end
			end
			8'h9: begin
				if(we) begin
					we2 = 1'b1;
					rd_sel = 2'b11;
				end
				else begin
					we2 = 1'b0;
					rd_sel = 2'b11;
				end
			end
			default: rd_sel = 2'b00;
	end

endmodule