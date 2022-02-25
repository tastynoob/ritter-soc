module Reduction_and8bit(input [7:0] in,output out);
	wire w1,w2,w3,w4,w5,w6;
	and(w1,in[1],in[0]);
	and(w2,in[2],w1);
	and(w3,in[3],w2);
	and(w4,in[4],w3);
	and(w5,in[5],w4);
	and(w6,in[6],w5);
	and(out,in[7],w6);
endmodule

module Reduction_or8bit(input [7:0] in,output out);
	wire w1,w2,w3,w4,w5,w6;
	or(w1,in[1],in[0]);
	or(w2,in[2],w1);
	or(w3,in[3],w2);
	or(w4,in[4],w3);
	or(w5,in[5],w4);
	or(w6,in[6],w5);
	or(out,in[7],w6);
endmodule

module Reduction_or24bit(input [23:0] in,output out);
	Reduction_or8bit RO01(.in(in[7:0]),.out(o1));
	Reduction_or8bit RO02(.in(in[15:8]),.out(o2));
	Reduction_or8bit RO03(.in(in[23:16]),.out(o3));
	or(out,o1,o2,o3);
endmodule

module Reduction_nor31bit(input [30:0] in,output out);
	Reduction_or24bit RO01(.in(in[23:0]),.out(o1));
	Reduction_or8bit RO02(.in({1'b0,in[30:24]}),.out(o2));
	nor(out,o1,o2);
endmodule

module Complement8bit(input [7:0] in,output [7:0] out);
	not(out[0],in[0]);
	not(out[1],in[1]);
	not(out[2],in[2]);
	not(out[3],in[3]);
	not(out[4],in[4]);
	not(out[5],in[5]);
	not(out[6],in[6]);
	not(out[7],in[7]);
endmodule

module Complement24bit(input [23:0] in,output [23:0] out);
	Complement8bit C01(.in(in[7:0]),.out(out[7:0]));
	Complement8bit C02(.in(in[15:8]),.out(out[15:8]));
	Complement8bit C03(.in(in[23:16]),.out(out[23:16]));
endmodule

module Adder4bit(input [3:0] a,input [3:0] b,input cin,output [3:0]sum,output cout);
	wire g0,g1,g2,g3,p0,p1,p2,p3,c2,c1,c0;
	assign g0 = a[0]&b[0];
	assign g1 = a[1]&b[1];
	assign g2 = a[2]&b[2];
	assign g3 = a[3]&b[3];
	assign p0 = a[0]^b[0];
	assign p1 = a[1]^b[1];
	assign p2 = a[2]^b[2];
	assign p3 = a[3]^b[3];
	assign c0 = g0 |( p0 & cin);
	assign c1 = g1 | (p1&g0)| (p1&p0&cin);
	assign c2 = g2 | (p2&g1) | (p2&p1&g0) | (p2&p1&p0&cin);
	assign cout = g3 | (p3&g2) | (p3&p2&g1) | (p3&p2&p1&g0) | (p3&p2&p1&p0&cin);

	xor(sum[0],p0,cin);
	xor(sum[1],p1,c0);
	xor(sum[2],p2,c1);
	xor(sum[3],p3,c2);

endmodule

module Adder8bit(input [7:0] a,input [7:0] b,input cin,output [7:0]sum,output cout);
	Adder4bit ADD01(.a(a[3:0]),.b(b[3:0]),.cin(cin),.sum(sum[3:0]),.cout(ctemp));
	Adder4bit ADD02(.a(a[7:4]),.b(b[7:4]),.cin(ctemp),.sum(sum[7:4]),.cout(cout));
endmodule

module Adder9bit(input [8:0] a,input [8:0] b,input cin,output [8:0]sum,output cout);
	Adder8bit ADD01(.a(a[7:0]),.b(b[7:0]),.cin(cin),.sum(sum[7:0]),.cout(ctemp));
	xor(sum[8],a[8],b[8],ctemp);
	assign cout = a[8]&b[8] | a[8]&ctemp | ctemp&b[8];
endmodule

module Adder24bit(input [23:0] a,input [23:0] b,input cin,output [23:0]sum,output cout);
	Adder8bit ADD01(.a(a[7:0]),.b(b[7:0]),.cin(cin),.sum(sum[7:0]),.cout(ctemp1));
	Adder8bit ADD02(.a(a[15:8]),.b(b[15:8]),.cin(ctemp1),.sum(sum[15:8]),.cout(ctemp2));
	Adder8bit ADD03(.a(a[23:16]),.b(b[23:16]),.cin(ctemp2),.sum(sum[23:16]),.cout(cout));
endmodule

module Complement8bit_2s(input [7:0] in,output [7:0] out);
	wire [7:0] outtemp;
	Complement8bit C01(.in(in),.out(outtemp));
	Adder8bit ADD01(.a(outtemp),.b(8'b0000_0001),.cin(1'b0),.sum(out),.cout());
endmodule

module Complement24bit_2s(input [23:0] in,output [23:0] out);
	wire [23:0] outtemp;
	Complement24bit C01(.in(in),.out(outtemp));
	Adder24bit ADD01(.a(outtemp),.b(24'b0000_0000_0000_0000_0000_0001),.cin(1'b0),.sum(out),.cout());
endmodule

module Mux_1Bit(input in0,input in1 ,input sl,output out);
	wire w1,w2,invSL;
	not(invSL,sl);
	and(w1,in0,invSL);
	and(w2,in1,sl);
	or(out,w1,w2);
endmodule

module Mux_8Bit(input [7:0] in0,input [7:0] in1 ,input sl,output [7:0] out);
	Mux_1Bit M01(.in0(in0[0]),.in1(in1[0]) ,.sl(sl),.out(out[0]));
	Mux_1Bit M02(.in0(in0[1]),.in1(in1[1]) ,.sl(sl),.out(out[1]));
	Mux_1Bit M03(.in0(in0[2]),.in1(in1[2]) ,.sl(sl),.out(out[2]));
	Mux_1Bit M04(.in0(in0[3]),.in1(in1[3]) ,.sl(sl),.out(out[3]));
	Mux_1Bit M05(.in0(in0[4]),.in1(in1[4]) ,.sl(sl),.out(out[4]));
	Mux_1Bit M06(.in0(in0[5]),.in1(in1[5]) ,.sl(sl),.out(out[5]));
	Mux_1Bit M07(.in0(in0[6]),.in1(in1[6]) ,.sl(sl),.out(out[6]));
	Mux_1Bit M08(.in0(in0[7]),.in1(in1[7]) ,.sl(sl),.out(out[7]));
endmodule

module Mux_24Bit(input [23:0] in0,input [23:0] in1 ,input sl,output [23:0] out);
	Mux_8Bit M01(.in0(in0[7:0]),.in1(in1[7:0]) ,.sl(sl),.out(out[7:0]));
	Mux_8Bit M02(.in0(in0[15:8]),.in1(in1[15:8]) ,.sl(sl),.out(out[15:8]));
	Mux_8Bit M03(.in0(in0[23:16]),.in1(in1[23:16]) ,.sl(sl),.out(out[23:16]));
endmodule

module Mux_32Bit(input [31:0] in0,input [31:0] in1 ,input sl,output [31:0] out);
	Mux_24Bit M01(.in0(in0[23:0]),.in1(in1[23:0]),.sl(sl),.out(out[23:0]));
	Mux_8Bit M02(.in0(in0[31:24]),.in1(in1[31:24]),.sl(sl),.out(out[31:24]));
endmodule

module Multiplier24bit(input [23:0] a,input [23:0] b,output [47:0]mul);
	assign mul = a*b;
endmodule

module Divider24bit(input [47:0] a,input [23:0] b,output [24:0]div);
	wire [47:0] div_temp;
	assign div_temp = a/b;
	assign div = div_temp[24:0];
endmodule

module normalizeMandfindShift(
					input[23:0] M_result,
					input M_carry,
					input real_oper,
					output reg [22:0] normalized_M,
					output reg [4:0] shift
					);
			
reg [23:0] M_temp;
			
always @(*)
begin
	if(M_carry & !real_oper)
	begin
		normalized_M = M_result[23:1] + {22'b0,M_result[0]};
		shift = 5'd0;
	end
	else
	begin
		casex(M_result)
			24'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx:
			begin
				normalized_M = M_result[22:0];
				shift = 5'd0;
			end
			24'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx:
			begin
				M_temp = M_result << 1;
				normalized_M = M_temp[22:0];
				shift = 5'd1;
			end
			24'b001x_xxxx_xxxx_xxxx_xxxx_xxxx:
			begin
				M_temp = M_result << 2;
				normalized_M = M_temp[22:0];
				shift = 5'd2;
			end			
			24'b0001_xxxx_xxxx_xxxx_xxxx_xxxx:
			begin
				M_temp = M_result << 3;
				normalized_M = M_temp[22:0];
				shift = 5'd3;
			end			
			24'b0000_1xxx_xxxx_xxxx_xxxx_xxxx:
			begin
				M_temp = M_result << 4;
				normalized_M = M_temp[22:0];
				shift = 5'd4;
			end			
			24'b0000_01xx_xxxx_xxxx_xxxx_xxxx:
			begin
				M_temp = M_result << 5;
				normalized_M = M_temp[22:0];
				shift = 5'd5;
			end			
			24'b0000_001x_xxxx_xxxx_xxxx_xxxx:
			begin
				M_temp = M_result << 6;
				normalized_M = M_temp[22:0];
				shift = 5'd6;
			end			
			24'b0000_0001_xxxx_xxxx_xxxx_xxxx:
			begin
				M_temp = M_result << 7;
				normalized_M = M_temp[22:0];
				shift = 5'd7;
			end			
			24'b0000_0000_1xxx_xxxx_xxxx_xxxx:
			begin
				M_temp = M_result << 8;
				normalized_M = M_temp[22:0];
				shift = 5'd8;
			end			
			24'b0000_0000_01xx_xxxx_xxxx_xxxx:
			begin
				M_temp = M_result << 9;
				normalized_M = M_temp[22:0];
				shift = 5'd9;
			end			
			24'b0000_0000_001x_xxxx_xxxx_xxxx:
			begin
				M_temp = M_result << 10;
				normalized_M = M_temp[22:0];
				shift = 5'd10;
			end			
			24'b0000_0000_0001_xxxx_xxxx_xxxx:
			begin
				M_temp = M_result << 11;
				normalized_M = M_temp[22:0];
				shift = 5'd11;
			end			
			24'b0000_0000_0000_1xxx_xxxx_xxxx:
			begin
				M_temp = M_result << 12;
				normalized_M = M_temp[22:0];
				shift = 5'd12;
			end			
			24'b0000_0000_0000_01xx_xxxx_xxxx:
			begin
				M_temp = M_result << 13;
				normalized_M = M_temp[22:0];
				shift = 5'd13;
			end			
			24'b0000_0000_0000_001x_xxxx_xxxx:
			begin
				M_temp = M_result << 14;
				normalized_M = M_temp[22:0];
				shift = 5'd14;
			end			
			24'b0000_0000_0000_0001_xxxx_xxxx:
			begin
				M_temp = M_result << 15;
				normalized_M = M_temp[22:0];
				shift = 5'd15;
			end			
			24'b0000_0000_0000_0000_1xxx_xxxx:
			begin
				M_temp = M_result << 16;
				normalized_M = M_temp[22:0];
				shift = 5'd16;
			end			
			24'b0000_0000_0000_0000_01xx_xxxx:
			begin
				M_temp = M_result << 17;
				normalized_M = M_temp[22:0];
				shift = 5'd17;
			end			
			24'b0000_0000_0000_0000_001x_xxxx:
			begin
				M_temp = M_result << 18;
				normalized_M = M_temp[22:0];
				shift = 5'd18;
			end			
			24'b0000_0000_0000_0001_0001_xxxx:
			begin
				M_temp = M_result << 19;
				normalized_M = M_temp[22:0];
				shift = 5'd19;
			end			
			24'b0000_0000_0000_0000_0000_1xxx:
			begin
				M_temp = M_result << 20;
				normalized_M = M_temp[22:0];
				shift = 5'd20;
			end			
			24'b0000_0000_0000_0000_0000_01xx:
			begin
				M_temp = M_result << 21;
				normalized_M = M_temp[22:0];
				shift = 5'd21;
			end			
			24'b0000_0000_0000_0000_0000_001x:
			begin
				M_temp = M_result << 22;
				normalized_M = M_temp[22:0];
				shift = 5'd22;
			end			
			24'b0000_0000_0000_0000_0000_0001:
			begin
				M_temp = M_result << 23;
				normalized_M = M_temp[22:0];
				shift = 5'd23;
			end			
			default:
			begin
				normalized_M = 23'b0;
				shift = 5'd0;
			end			
		endcase	
	end
end										
											
endmodule