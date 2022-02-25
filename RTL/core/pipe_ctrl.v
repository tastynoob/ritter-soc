



`include "config.v"



module PIPE_CTRL (

/* ------------------------------ */
    //译码段的读寄存器索引
    input wire i_bpu_rs1ren,
    input wire[`rfidxlen_def] i_bpu_rs1idx,
    input wire i_bpu_rs2ren,
    input wire[`rfidxlen_def] i_bpu_rs2idx,
    //执行段的写寄存器索引
    input wire i_exu_rdwen0,
    input wire[`rfidxlen_def] i_exu_rdidx0,
    input wire i_exu_rdwen1,
    input wire[`rfidxlen_def] i_exu_rdidx1,
    input wire i_exu_rdwen2,
    input wire[`rfidxlen_def] i_exu_rdidx2,
/* ------------------------------ */
    //执行段资源冲突
    input wire i_exu_resource_match,
    //写回冲突
    input wire i_wb_match,

    output wire o_ifu_wait,
    output wire o_bpu_wait,
    output wire o_dis_wait,

    output wire o_dis_flush
    //发生任意冲突时,写回不需要冲刷
);


//同时发生读写冲突与写回冲突

    wire rs1_match =    i_bpu_rs1ren ? 
                        ((i_exu_rdwen0 & (i_bpu_rs1idx == i_exu_rdidx0)) |
                        (i_exu_rdwen1 & (i_bpu_rs1idx == i_exu_rdidx1)) |
                        (i_exu_rdwen2 & (i_bpu_rs1idx == i_exu_rdidx2))) : 0;
    wire rs2_match =   i_bpu_rs2ren ? 
                        ((i_exu_rdwen0 & (i_bpu_rs2idx == i_exu_rdidx0)) |
                        (i_exu_rdwen1 & (i_bpu_rs2idx == i_exu_rdidx1)) |
                        (i_exu_rdwen2 & (i_bpu_rs2idx == i_exu_rdidx2))) : 0;

    //写后读冲突
    wire read_after_write = rs1_match | rs2_match;


    assign o_ifu_wait = i_exu_resource_match | read_after_write | i_wb_match;
    assign o_bpu_wait = i_exu_resource_match | read_after_write | i_wb_match;

    assign o_dis_wait = i_exu_resource_match | i_wb_match;
    //假如exu发生资源冲突,并且bpu发生读写冲突,不需要冲刷dis
    //假如只发生bpu读写冲突,则需要冲刷dis
    //假如发生写回冲突,并且发生读写冲突，不需要冲刷dis
    assign o_dis_flush = (i_exu_resource_match | i_wb_match) ? 0 : read_after_write;










    
endmodule