


`include "config.v"
`include "defines.v"




/*
单周期运算指令执行单元


*/

module EXU_ALU (
    input wire i_clk,
    input wire i_rstn,

    input wire[`rfidxlen_def] i_alu_rdidx,
    input wire[`decinfo_grplen_def] i_decinfo_grp,
    input wire[`decinfolen_def] i_aluinfo,

    //参数1
    input wire[`xlen_def] i_alu_op1,
    //参数2
    input wire[`xlen_def] i_alu_op2,


    //派遣指令，需要写入的rd寄存器 
    output wire o_alu_rdwen,
    output wire[`rfidxlen_def] o_alu_rdidx,
    output wire[`xlen_def] o_alu_rdwdata,//alu计算结果

    //传递给lsu的加法结果，addr = rs1 + imm
    output wire[`xlen_def] o_lsu_result
);

    wire[`xlen_def] alu_add = {`xlen{i_decinfo_grp[`decinfo_grp_add]}} & (i_alu_op1 + i_alu_op2);

    wire[`xlen_def] alu_sub = {`xlen{i_aluinfo[`aluinfo_sub]}} & (i_alu_op1 - i_alu_op2);

    wire[`xlen_def] alu_sll = {`xlen{i_aluinfo[`aluinfo_sll]}} & (i_alu_op1 << i_alu_op2);

    wire[`xlen_def] alu_srl = {`xlen{i_aluinfo[`aluinfo_srl]}} & (i_alu_op1 >> i_alu_op2);

    wire[`xlen_def] alu_sra = {`xlen{i_aluinfo[`aluinfo_sra]}} & (( { {31{i_alu_op1[31]}}, 1'b0 } << (~i_alu_op2) ) | ( i_alu_op1 >> i_alu_op2));

    wire[`xlen_def] alu_xor = {`xlen{i_aluinfo[`aluinfo_xor]}} & (i_alu_op1 ^ i_alu_op2);

    wire[`xlen_def] alu_and = {`xlen{i_aluinfo[`aluinfo_and]}} & (i_alu_op1 & i_alu_op2);

    wire[`xlen_def] alu_or = {`xlen{i_aluinfo[`aluinfo_or]}} & (i_alu_op1 | i_alu_op2);

    wire[`xlen_def] alu_slt = {`xlen{i_aluinfo[`aluinfo_slt]}} & (($signed(i_alu_op1)) < ($signed(i_alu_op2)));

    wire[`xlen_def] alu_sltu = {`xlen{i_aluinfo[`aluinfo_sltu]}} & (i_alu_op1 < i_alu_op2);


    assign o_lsu_result = alu_add;

    assign o_alu_rdwen = i_decinfo_grp[`decinfo_grp_alu];

    assign o_alu_rdidx = i_alu_rdidx;
    
    assign o_alu_rdwdata =  alu_add |
                            alu_sub |
                            alu_sll |
                            alu_srl |
                            alu_sra |
                            alu_xor |
                            alu_and |
                            alu_or  |
                            alu_slt |
                            alu_sltu;




    
endmodule