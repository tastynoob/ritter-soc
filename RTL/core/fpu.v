


`include "defines.v"
`include "config.v"

module FPU32(
    input wire i_clk,
    input wire i_rsn,

    input wire[31:0] i_op1,
    input wire[31:0] i_op2,

    
    output wire[31:0] o_addres,
    output wire[31:0] o_subres,
    output wire[31:0] o_mulres,
    output wire[31:0] o_divres
);


wire[31:0] addres, subres, mulres, divres;
add_sub u_add(
    .n1        ( i_op1        ),
    .n2        ( i_op2        ),
    .result    ( addres    ),
    .sub       ( 0       ),
    .Overflow  (   ),
    .Underflow (  ),
    .Exception  (   )
);

add_sub u_sub(
    .n1        ( i_op1        ),
    .n2        ( i_op2        ),
    .result    ( subres    ),
    .sub       ( 1       ),
    .Overflow  (   ),
    .Underflow (  ),
    .Exception  (   )
);


div u_div(
    .n1        ( i_op1        ),
    .n2        ( i_op2        ),
    .result    ( divres    ),
    .Overflow  (   ),
    .Underflow (  ),
    .Exception  (   )
);

mul u_mul(
    .n1        ( i_op1     ),
    .n2        ( i_op2     ),
    .result    ( mulres    ),
    .Overflow  (   ),
    .Underflow (  ),
    .Exception  (   )
);


assign o_addres = addres;
assign o_subres = subres;
assign o_mulres = mulres;
assign o_divres = divres;












endmodule



module add_sub(
    input [31:0] n1,
    input [31:0] n2,
    output [31:0] result,
    input sub,
    output Overflow,
    output Underflow,
    output Exception
    );
	 
wire real_oper,real_sign,M_carry;
wire isElLessThanE2,reduced_and_E1,reduced_and_E2,reduced_or_E1,reduced_or_E2;
wire [7:0] temp_exp_diff,One_Added_E,new_E,complemented_temp_exp_diff,exp_diff,E,complemented_E2,complemented_shift_E;
wire [8:0] final_E;
wire [23:0] M1,M2,complemented_M2,complemented_M_result,M_result,M_result2,new_M2;
wire w1,w2,w3,final_sign;
wire [22:0] final_M;
wire[4:0] shift_E;

// If the bits of E1, E2 are 1 ==> Then the number will be either infinity or NAN ( i.e. an Exception ) 
Reduction_and8bit RA01(.in(n1[30:23]),.out(reduced_and_E1));
Reduction_and8bit RA02(.in(n2[30:23]),.out(reduced_and_E2));

// If any of E1 or E2 has all btis 1 then we have an Exception( high ) 
or(Exception,reduced_and_E1,reduced_and_E2);

// If all the bits of E1 or E2 are 0  ===> Number is denormalized and implied bit of the corresponding mantissa is set as 0.
Reduction_or8bit RO01(.in(n1[30:23]),.out(reduced_or_E1));
Reduction_or8bit RO02(.in(n1[30:23]),.out(reduced_or_E2));

// Performing E1 - E2
// Before subtraction, complementing E2 bcoz of 2's complement subtraction
Complement8bit C01(.in(n2[30:23]),.out(complemented_E2));
Adder8bit ADD01(.a(n1[30:23]),.b(complemented_E2),.cin(1'b1),.sum(temp_exp_diff),.cout(isE1GreaterThanE2));

// If exp_diff comes out to be -ve ===> Found it's 2's complement
// Original or 2's complement version is selected according to isE1GreaterThanE2
Complement8bit_2s C023(.in(temp_exp_diff),.out(complemented_temp_exp_diff));
Mux_8Bit M011(.in0(complemented_temp_exp_diff),.in1(temp_exp_diff),.sl(isE1GreaterThanE2),.out(exp_diff));

// Selecting the larger exponent
Mux_8Bit M03(.in0(n2[30:23]),.in1(n1[30:23]),.sl(isE1GreaterThanE2),.out(E));

// shifting either mantissa of n1 or n2 a/c to isE1GreaterThanE2
assign M1 = isE1GreaterThanE2? {reduced_or_E1,n1[22:0]}:{reduced_or_E1,n1[22:0]} >> exp_diff;
assign M2 = isE1GreaterThanE2?{reduced_or_E2,n2[22:0]} >> exp_diff:{reduced_or_E2,n2[22:0]};

// assuming real_oper and real_sign
xor(real_oper,sub,n1[31],n2[31]);
buf(real_sign,n1[31]);

// M2 is added to or subtracted from M1 a/c to real_oper
Complement24bit C02(.in(M2),.out(complemented_M2));
Mux_24Bit M04(.in0(M2),.in1(complemented_M2),.sl(real_oper),.out(new_M2));
Adder24bit ADD02(.a(M1),.b(new_M2),.cin(real_oper),.sum(M_result),.cout(M_carry));

// correction in the sign of the final result
and(w1,~real_sign,real_oper,~M_carry);
and(w2,~real_oper,real_sign);
and(w3,M_carry,real_sign);
or(final_sign,w1,w2,w3);

// 1 is added to E if Addtion is performed b/w mantissae and carry is generated
Adder8bit ADD0212(.a(E),.b(8'd1),.cin(1'b0),.sum(One_Added_E),.cout());
Mux_8Bit M031(.in0(E),.in1(One_Added_E),.sl(M_carry&!real_oper),.out(new_E));

// if M_result is negative then 2's complement of M_result is to be calculated
Complement24bit_2s C03(.in(M_result),.out(complemented_M_result));
Mux_24Bit M05(.in0(M_result),.in1(complemented_M_result),.sl(real_oper&!M_carry),.out(M_result2));

// Normalization step ( See Utils.v )
normalizeMandfindShift NM(.M_result(M_result2),.M_carry(M_carry),.real_oper(real_oper),.normalized_M(final_M),.shift(shift_E));
Complement8bit C04(.in({3'b000,shift_E}),.out(complemented_shift_E));

// finally shift is subtracted from E ( 2's complement subtraction )
Adder8bit ADD03(.a(new_E),.b(complemented_shift_E),.cin(1'b1),.sum(final_E[7:0]),.cout(final_E[8]));

// final ans
assign result = {final_sign,final_E[7:0],final_M};

// if (Carry) final_E[8] = 0 ===> final_E is -ve ( Underflow )
not(Underflow,final_E[8]);

// if All bits of of One_Added_E are 1 ( 255 ) and shift_E are 0 ( 0 ), then final_E is 255 ( Out of bound,i.e, Overflow )  
and(Overflow,&One_Added_E,~|shift_E);

endmodule



module div(
			input [31:0] n1,
			input [31:0] n2,
			output [31:0] result,
			output Overflow,
			output Underflow,
			output Exception
         );

wire is_n2_zero,reduced_and_E1,reduced_and_E2,reduced_or_E1,reduced_or_E2,Overflow1,Underflow1,Overflow2,Underflow2;
wire [24:0] M_div_result;
wire [8:0] temp_E1,temp_E2,temp_E3;
wire [7:0] complemented_E2,complemented_shift_E1,sub_E,bias_added_E,final_E;
wire [4:0] shift_E1,shift_E2;
wire [22:0] normalized_M1,normalized_M2,final_M;

//if all the bits of E1 or E2 are 1 or if n2 is zero ===> Exception 
Reduction_and8bit RA01(.in(n1[30:23]),.out(reduced_and_E1));
Reduction_and8bit RA02(.in(n2[30:23]),.out(reduced_and_E2));
Reduction_nor31bit RN01(.in(n2[30:0]),.out(is_n2_zero));
or(Exception,reduced_and_E1,reduced_and_E2,is_n2_zero);

// final sign of the result
xor(final_sign,n1[31],n2[31]);

// if all the bits of E1 or E2 are 0  ===> Number is denormalized and the implied bit of the corresponding mantissa is to be set as 0.
Reduction_or8bit RO01(.in(n1[30:23]),.out(reduced_or_E1));
Reduction_or8bit RO02(.in(n1[30:23]),.out(reduced_or_E2));

// Subtracting E2 from E1 ===> 2's complement Subtraction
Complement8bit C01(.in(n2[30:23]),.out(complemented_E2));
Adder8bit ADD01(.a(n1[30:23]),.b(complemented_E2),.cin(1'b1),.sum(sub_E),.cout());

// Adding 127(BIAS) to sub_E
Adder8bit ADD02(.a(sub_E),.b(8'b01111111),.cin(1'b0),.sum(bias_added_E),.cout());

// Used to make all mantissae normalized if any of the them is firstly denormalized 
normalizeMandfindShift NM1(.M_result({reduced_or_E1,n1[22:0]}),.M_carry(1'b0),.real_oper(1'b0),.normalized_M(normalized_M1),.shift(shift_E1));
normalizeMandfindShift NM2(.M_result({reduced_or_E2,n2[22:0]}),.M_carry(1'b0),.real_oper(1'b0),.normalized_M(normalized_M2),.shift(shift_E2));

// dividing M1 by M2
Divider24bit DIV01(.a({1'b1,normalized_M1,24'b0}),.b({1'b1,normalized_M2}),.div(M_div_result));

// if M_div_result[24] = 0 ===> take ans from 22 pos to 0 pos, i.e, final_M = M_div_result[22:0]
// if M_div_result[24] = 1 ===> take ans from 23 pos to 1 pos, i.e, final_M = M_div_result[23:1]
Mux_24Bit M02(.in0({1'b0,M_div_result[22:0]}),.in1({1'b0,M_div_result[23:1]}),.sl(M_div_result[24]),.out({temp,final_M}));

// Subtracting shift_E1 from bias_added_E  ===> we get temp_E1
Complement8bit C02(.in({3'b000,shift_E1}),.out(complemented_shift_E1));
Adder8bit ADD03(.a(bias_added_E),.b(complemented_shift_E1),.cin(1'b1),.sum(temp_E1),.cout());

// Adding shift_E2 to temp_E1 ===> we get temp_E2
Adder8bit ADD04(.a(temp_E1),.b({3'b000,shift_E2}),.cin(1'b0),.sum(temp_E2[7:0]),.cout(temp_E2[8]));
and(Overflow1,temp_E1[8],temp_E2[8]);
nor(Underflow1,temp_E1[8],temp_E2[8]);

// Subtracting 1 from temp_E2[7:0] to get temp_E3
Adder8bit ADD05(.a(temp_E2[7:0]),.b(8'b11111111),.cin(1'b0),.sum(temp_E3[7:0]),.cout(temp_E3[8]));
and(Overflow2,temp_E2[8],temp_E3[8]);
nor(Underflow2,temp_E2[8],temp_E3[8]);

// Based on M_div_result[24] bit ===> we will select temp_E2 or temp_E3  
Mux_8Bit M03(.in0(temp_E3[7:0]),.in1(temp_E2[7:0]),.sl(M_div_result[24]),.out(final_E));
Mux_1Bit M04(.in0(Overflow2),.in1(Overflow1),.sl(M_div_result[24]),.out(Overflow));
Mux_1Bit M05(.in0(Underflow2),.in1(Underflow1),.sl(M_div_result[24]),.out(Underflow));

assign result = {final_sign,final_E[7:0],final_M};

endmodule

module mul( 
				input [31:0] n1,
				input [31:0] n2,
				output [31:0] result,
				output Overflow,
				output Underflow,
				output Exception
			);

wire [8:0] sum_E,final_E;
wire [47:0] M_mul_result;
wire [23:0] normalized_M_mul_result;
wire [22:0] final_M;
wire final_sign,reduced_and_E1,reduced_and_E2,reduced_or_E1,reduced_or_E2,carry_E;

// Checking whether all the bits of E1, E2 are 1 ==> Then the number will be either infinity or NAN ( i.e. an Exception ) 
Reduction_and8bit RA01(.in(n1[30:23]),.out(reduced_and_E1));
Reduction_and8bit RA02(.in(n2[30:23]),.out(reduced_and_E2));

// If any of E1 or E2 has all btis 1 then we have an Exception( high ) 
or(Exception,reduced_and_E1,reduced_and_E2);

// final sign of the result
xor(final_sign,n1[31],n2[31]);

// if all the bits of E1 or E2 are 0  ===> Number is denormalized and implied bit of the corresponding mantissa is set as 0.
Reduction_or8bit RO01(.in(n1[30:23]),.out(reduced_or_E1));
Reduction_or8bit RO02(.in(n1[30:23]),.out(reduced_or_E2));

// Multiplying M1 and M2 ( here we have firstly concatenate the implied bit with the corresponding mantissa )
Multiplier24bit MUL01(.a({reduced_or_E1,n1[22:0]}),.b({reduced_or_E2,n2[22:0]}),.mul(M_mul_result));

// MSB of the product is used as select line
// finding the rounding bit ( finally we will or with the LSB of the final product to include rounding )
// if M_mul_result[47] is 1 ===> product is normalized and we will round off the last 24 bits else last 23 bits
Reduction_or24bit RO03(.in({1'b0,M_mul_result[22:0]}),.out(mul_round1));
Reduction_or24bit RO04(.in(M_mul_result[23:0]),.out(mul_round2));
Mux_1Bit M01(.in0(mul_round1),.in1(mul_round2),.sl(M_mul_result[47]),.out(final_product_round));

// normalization
// if MSB of M_mul_result is 1 ===> product is already normalized and next 23 bits after MSB is taken
// if MSB of M_mul_result is 0 ===> The next bit is always 1, so starting from next to next bit, next 23 bits are taken
// here we do not require to shift any bit
Mux_24Bit M02(.in0({1'b0,M_mul_result[45:23]}),.in1({1'b0,M_mul_result[46:24]}),.sl(M_mul_result[47]),.out(normalized_M_mul_result));

Adder24bit ADD23(.a({1'b0,normalized_M_mul_result[22:0]}),.b({23'b0,final_product_round}),.cin(1'b0),.sum({temp,final_M}),.cout());

// Adding E1 and E2
Adder8bit ADD01(.a(n1[30:23]),.b(n2[30:23]),.cin(1'b0),.sum(sum_E[7:0]),.cout(sum_E[8]));

// Subtracting 127(BIAS) from sum_E = E1 + E2
// if M_mul_result[47] = 1 ===> product is of the form 11.(something) and we need to shift the decimal point to left to make the product normalized and therefore we add 1 to resultant E
// if M_mul_result[47] = 0 ===> product is of the form 01.(something) and the product is already normalized and nothing is added or subtracted to E
Adder9bit ADD02(.a(sum_E),.b(9'b110000001),.cin(M_mul_result[47]),.sum(final_E),.cout(carry_E));

// In 2's complement subtraction : 
// if carry_E = 0 ===> result is negative and it the case of Underflow
// if carry_E = 1 and MSB of sum(final_E) is 8 (that means sum is atleast 256 ) ===> it is the case of Overflow 
not(Underflow,carry_E);
and(Overflow,carry_E,final_E[8]);

assign result = {final_sign,final_E[7:0],final_M};

endmodule