





`include "defines.v"
`include "config.v"


// 


module BPU (
    input wire i_clk,
    input wire i_rstn,

    input wire i_stop,
    input wire i_flush,

    //取指传入
    input wire i_data_vld,
    input wire[`xlen_def] i_iaddr,
    input wire[`ilen_def] i_data,

    //rs1,rs2读冲突检测
    output wire o_bpu_rs1ren,
    output wire[`rfidxlen_def] o_bpu_rs1idx,
    output wire o_bpu_rs2ren,
    output wire[`rfidxlen_def] o_bpu_rs2idx,

    //写回
    input wire i_rdwen,
    input wire[`rfidxlen_def] i_rdidx,
    input wire[`xlen_def] i_rd_wdata,

    //分支预测的结果
    output wire o_bpu_taken,//分支预测跳转,同时冲刷流水线
    output wire[`xlen_def] o_bpu_jaddr,//预测地址

    //传递给下级流水线
    output wire o_inst_vld,
    output wire[`xlen_def] o_exu_op1,
    output wire[`xlen_def] o_exu_op2,
    output wire[`xlen_def] o_rs2rdata,
    output wire[`xlen_def] o_imm,
    output wire o_rdwen,
    output wire[`rfidxlen_def] o_rdidx,
    //csr寄存器组放在外面
    output wire o_csr_ren,
    output wire[`csridxlen_def] o_csridx,
    output wire[`xlen_def] o_csr_zimm,
    /********/
    output wire[`decinfo_grplen_def] o_decinfo_grp,
    output wire[`decinfolen_def] o_decinfo,
    output wire[`xlen_def] o_iaddr
);


wire inst_vld;
wire[`xlen_def] inst_pc;
wire[`ilen_def] inst;

`ifdef USE_AP
//对齐处理
BPU_AP u_BPU_AP(
    .i_clk      ( i_clk      ),
    .i_rstn     ( i_rstn     ),

    //要保持正确的指令输出
    .i_stop     ( i_stop ),
    .i_flush    ( i_flush   ),

    .i_data_vld ( i_data_vld ),
    .i_iaddr    ( i_iaddr    ),
    .i_data     ( i_data     ),

    .o_inst_vld ( inst_vld ),
    .o_inst_pc  ( inst_pc    ),
    .o_inst     ( inst       )
);

`else

assign inst_vld = i_data_vld;
assign inst_pc  = i_iaddr;
assign inst     = i_data;


`endif 





assign o_inst_vld = inst_vld & (~i_stop);
assign o_iaddr = inst_pc;
assign o_inst = inst;

wire bpu_bflag;
wire inst_jal;
wire inst_jalr;
wire inst_bxx;
wire[`rfidxlen_def] inst_rs1idx;
wire[`xlen_def] bp_imm;

wire rs1ren;
wire[`rfidxlen_def] rs1idx;
wire[`xlen_def] rs1_rdata;
wire rs2ren;
wire[`rfidxlen_def] rs2idx;
wire[`xlen_def] rs2_rdata;
wire[`xlen_def] imm;
wire rs1topc;
wire rs2toimm;
//译码
DECODE u_DECODE(
    .i_clk         ( i_clk         ),
    .i_rstn        ( i_rstn        ),

    .i_inst_vld    ( inst_vld    ),
    .i_inst        ( inst        ),
    .i_bpu_bflag   ( bpu_bflag   ),

    .o_inst_jal    ( inst_jal    ),
    .o_inst_jalr   ( inst_jalr   ),
    .o_inst_bxx    ( inst_bxx    ),
    .o_inst_rs1idx ( inst_rs1idx ),
    .o_bp_imm      ( bp_imm     ),

    .o_rdwen       ( o_rdwen       ),
    .o_rdidx       ( o_rdidx       ),

    .o_rs1ren      ( rs1ren      ),
    .o_rs1idx      ( rs1idx      ),

    .o_rs2ren      ( rs2ren      ),
    .o_rs2idx      ( rs2idx      ),

    .o_csr_ren     ( o_csr_ren    ),
    .o_csridx      ( o_csridx      ),

    .o_imm         ( imm           ),
    .o_zimm        ( o_csr_zimm    ),

    .o_decinfo_grp ( o_decinfo_grp ),
    .o_decinfo     ( o_decinfo     ),
    .o_rs1topc     ( rs1topc     ),
    .o_rs2toimm    ( rs2toimm    )
);

assign o_exu_op1 = rs1topc ? inst_pc : rs1_rdata;
assign o_exu_op2 = rs2toimm ?  imm : rs2_rdata;
assign o_rs2rdata = rs2_rdata;
assign o_imm = imm;

assign o_bpu_rs1ren = inst_vld&rs1ren;
assign o_bpu_rs1idx = rs1idx;
assign o_bpu_rs2ren = inst_vld&rs2ren;
assign o_bpu_rs2idx = rs2idx;
//读寄存器的条件:指令为jalr,rs1idx!=0
wire jalr_rs1ren = inst_jalr & (inst_rs1idx!=0);

wire[`xlen_def] bp_rs1rdata; 
//分支预测
BPU_BP u_BPU_BP(
    .i_clk           ( i_clk           ),
    .i_rstn          ( i_rstn          ),
    
    .i_pc            ( inst_pc         ),
    //译码输入
    .i_inst_jal      ( inst_jal      ),
    .i_inst_jalr     ( inst_jalr     ),
    .i_inst_rs1ren   ( jalr_rs1ren   ),
    .i_inst_bxx      ( inst_bxx      ),
    .i_imm           ( bp_imm        ),
    //
    .i_jalr_rs1rdata ( rs1_rdata ),
    //分支预测输出
    .o_prdt_taken    ( o_bpu_taken    ),
    .o_prdt_pc       ( o_bpu_jaddr       )
);
//有问题,bpu_bflag应只收bxx控制
assign bpu_bflag = inst_bxx & o_bpu_taken;

REGFILE u_REGFILE(
    .i_clk       ( i_clk       ),
    .i_rstn      ( i_rstn      ),
    
    .i_rdwen     ( i_rdwen     ),
    .i_rdidx     ( i_rdidx     ),
    .i_rd_wdata  ( i_rd_wdata  ),

    .i_rs1ren    ( rs1ren    ),
    .i_rs1idx    ( rs1idx    ),
    .o_rs1_rdata ( rs1_rdata ),
    .i_rs2ren    ( rs2ren    ),
    .i_rs2idx    ( rs2idx    ),
    .o_rs2_rdata  ( rs2_rdata  )
);







endmodule