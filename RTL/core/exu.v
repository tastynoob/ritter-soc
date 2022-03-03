




`include "defines.v"
`include "config.v"


//不可能出现连续的mdu单元写或者lsu单元写



module EXU (
    input wire i_clk,
    input wire i_rstn,

    input wire i_vld,

    //译码信息
    input wire[`xlen_def] i_exu_op1,
    input wire[`xlen_def] i_exu_op2,
    input wire[`xlen_def] i_rs2rdata,
    input wire[`xlen_def] i_imm,
    input wire i_rdwen,
    input wire[`rfidxlen_def] i_rdidx,

    input wire[`csridxlen_def] i_csridx,
    input wire[`xlen_def] i_csr_rdata,
    input wire[`xlen_def] i_csr_zimm,

    input wire[`decinfo_grplen_def] i_decinfo_grp,
    input wire[`decinfolen_def] i_decinfo,
    input wire[`xlen_def] i_iaddr,

    //读写控制信息
    //注意：此处不是写回信息，而是exu各个模块的写寄存器信息，主要用于读写冲突判断
    output wire o_exu_rdwen0,
    output wire[`rfidxlen_def] o_exu_rdidx0,
    output wire o_exu_rdwen1,
    output wire[`rfidxlen_def] o_exu_rdidx1,
    output wire o_exu_rdwen2,
    output wire[`rfidxlen_def] o_exu_rdidx2,
    output wire o_exu_resource_match,
    //

    //传递给写回
    output wire o_rdwen0,
    output wire[`rfidxlen_def] o_rdidx0,
    output wire[`xlen_def] o_rdwdata0,
    output wire o_mdu_working,
    output wire o_rdwen1,
    output wire[`rfidxlen_def] o_rdidx1,
    output wire[`xlen_def] o_rdwdata1,
    output wire o_lsu_working,
    output wire o_rdwen2,
    output wire[`rfidxlen_def] o_rdidx2,
    output wire[`xlen_def] o_rdwdata2,
    //csr写回
    output wire o_csr_wen,
    output wire[`csridxlen_def] o_csridx,
    output wire[`xlen_def] o_csr_wdata,

    //跳转
    output wire o_exu_taken,
    output wire[`xlen_def] o_exu_jaddr,


    //RIB总线主机
    output wire[31:0] o_ribm_addr,
    output wire o_ribm_wrcs,//读写选择
    output wire[3:0] o_ribm_mask, //写掩码
    output wire[31:0] o_ribm_wdata, //写数据
    input wire[31:0] i_ribm_rdata, //读数据
    output wire o_ribm_req, //主机发出请求
    input wire i_ribm_gnt, //总线授权
    input wire i_ribm_rsp, //从机响应有效
    output wire o_ribm_rdy

);


/******************************************************************************
 * 单周期指令区块
 ******************************************************************************/


wire alu_rdwen;
wire[`xlen_def] alu_rdwdata;
wire[`xlen_def] alu2lsu_result;
EXU_ALU u_EXU_ALU(
    .i_clk         ( i_clk         ),
    .i_rstn        ( i_rstn        ),

    .i_alu_rdidx   ( i_rdidx   ),
    .i_decinfo_grp ( i_decinfo_grp ),
    .i_aluinfo     ( i_decinfo     ),
    .i_alu_op1     ( i_exu_op1     ),
    .i_alu_op2     ( i_exu_op2     ),

    .o_alu_rdwen   ( alu_rdwen   ),
    .o_alu_rdidx   (    ),//没必要使用
    .o_alu_rdwdata ( alu_rdwdata ),

    .o_lsu_result  ( alu2lsu_result  )
);

wire bju_rdwen;
wire[`xlen_def] bju_rdwdata;
EXU_BJU u_EXU_BJU(
    .i_clk         ( i_clk         ),
    .i_rstn        ( i_rstn        ),

    .i_bju_rdidx   ( i_rdidx   ),
    .i_decinfo_grp ( i_decinfo_grp ),
    .i_bjuinfo     ( i_decinfo     ),
    .i_iaddr       ( i_iaddr       ),
    .i_imm         ( i_imm         ),
    .i_bju_op1     ( i_exu_op1     ),
    .i_bju_op2     ( i_exu_op2     ),

    .o_bju_taken   ( o_exu_taken   ),
    .o_bju_jaddr   ( o_exu_jaddr   ),

    .o_bju_rdwen   ( bju_rdwen   ),
    .o_bju_rdidx   (    ),//没必要使用
    .o_bju_rdwdata  ( bju_rdwdata  )
);


wire scu_rdwen;
wire[`xlen_def] scu_rdwdata;
EXU_SCU u_EXU_SCU(
    .i_clk         ( i_clk         ),
    .i_rstn        ( i_rstn        ),

    .i_decinfo_grp ( i_decinfo_grp ),
    .i_scuinfo     ( i_decinfo     ),

    .i_scu_op1     ( i_exu_op1     ),
    .i_csr_rdata   ( i_csr_rdata   ),
    .i_csr_zimm    ( i_csr_zimm    ),
    

    .o_scu_rdwen   ( scu_rdwen   ),
    .o_scu_wdata   ( scu_rdwdata   ),

    .o_csr_wen     ( o_csr_wen     ),
    .o_csr_wdata   ( o_csr_wdata   )
);
assign o_csridx = i_csridx;



assign o_rdwen0 = (alu_rdwen | bju_rdwen | scu_rdwen) & i_rdwen;
assign o_rdidx0 = i_rdidx;
assign o_rdwdata0 = alu_rdwen ? alu_rdwdata : 
                    bju_rdwen ? bju_rdwdata : 
                    scu_rdwdata;

//读写检测
assign o_exu_rdwen0 = (i_decinfo_grp[`decinfo_grp_lsu] | i_decinfo_grp[`decinfo_grp_mdu]) & i_rdwen;
assign o_exu_rdidx0 = i_rdidx;

/******************************************************************************
 * mdu指令区块
 ******************************************************************************/

wire mdu_will_rdwen;
wire[`rfidxlen_def] mdu_will_rdidx;

//假如发生了mdu的 写后写冲突
//需要设置mdu的rdwen为0
//当前的单周期指令与mdu的指令写入同一个寄存器
wire mdu_flush = (i_rdwen & mdu_will_rdwen) ? (i_rdidx == mdu_will_rdidx) : 0;

wire mdu_working;
EXU_MDU u_EXU_MDU(
    .i_clk         ( i_clk         ),
    .i_rstn        ( i_rstn        ),

    .i_vld          ( i_vld        ),
    .i_flush        ( mdu_flush    ),   

    .i_decinfo_grp ( i_decinfo_grp ),
    .i_mduinfo     ( i_decinfo     ),
    .i_mdu_rdwen   ( i_rdwen   ),
    .i_mdu_rdidx   ( i_rdidx   ),
    .i_mdu_op1     ( i_exu_op1     ),
    .i_mdu_op2     ( i_exu_op2     ),

    .o_working     ( mdu_working     ),
    .o_will_rdwen  ( mdu_will_rdwen  ),
    .o_will_rdidx  ( mdu_will_rdidx  ),

    .o_mdu_rdwen   ( o_rdwen1   ),
    .o_mdu_rdidx   ( o_rdidx1   ),
    .o_mdu_rdwdata  ( o_rdwdata1  )
);

//mdu读写检测
assign o_exu_rdwen1 = mdu_will_rdwen ;
assign o_exu_rdidx1 = mdu_will_rdidx;

assign o_mdu_working = mdu_working;





/******************************************************************************
 * lsu指令区块
 ******************************************************************************/

wire lsu_will_rdwen;
wire[`rfidxlen_def] lsu_will_rdidx;

wire lsu_flush = (i_rdwen&lsu_will_rdwen) ? (i_rdidx == lsu_will_rdidx) : 0;
wire lsu_working;
EXU_LSU u_EXU_LSU(
    .i_clk          ( i_clk          ),
    .i_rstn         ( i_rstn         ),

    .i_vld          ( i_vld        ),
    .i_flush        ( lsu_flush    ),

    .i_decinfo_grp  ( i_decinfo_grp  ),
    .i_lsuinfo      ( i_decinfo      ),
    .i_lsu_rdwen    ( i_rdwen       ),
    .i_lsu_rdidx    ( i_rdidx         ),
    .i_lsu_rs2rdata ( i_rs2rdata     ),
    .i_lsu_addr     ( alu2lsu_result     ),

    .o_working      ( lsu_working      ),
    .o_will_rdwen   ( lsu_will_rdwen   ),
    .o_will_rdidx   ( lsu_will_rdidx   ),

    .o_lsu_rdwen    ( o_rdwen2     ),
    .o_lsu_rdidx    ( o_rdidx2    ),
    .o_lsu_rdata    ( o_rdwdata2    ),

    .o_ribm_addr    ( o_ribm_addr    ),
    .o_ribm_wrcs    ( o_ribm_wrcs    ),
    .o_ribm_mask    ( o_ribm_mask    ),
    .o_ribm_wdata   ( o_ribm_wdata   ),
    .i_ribm_rdata   ( i_ribm_rdata   ),
    .o_ribm_req     ( o_ribm_req     ),
    .i_ribm_gnt     ( i_ribm_gnt     ),
    .i_ribm_rsp     ( i_ribm_rsp     ),
    .o_ribm_rdy     ( o_ribm_rdy     )
);

assign o_exu_rdwen2 = lsu_will_rdwen;
assign o_exu_rdidx2 = lsu_will_rdidx;

assign o_lsu_working = lsu_working;


assign o_exu_resource_match = (i_decinfo_grp[`decinfo_grp_mdu] & mdu_working) |
                              (i_decinfo_grp[`decinfo_grp_lsu] & lsu_working);









    
endmodule