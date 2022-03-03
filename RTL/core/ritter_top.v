

`include "defines.v"
`include "config.v"

module RITTER_TOP (
    input wire i_clk,
    input wire i_rstn,
    
    //ibus
    output wire[31:0] o_ribm_addr0,
    output wire o_ribm_wrcs0,//读写选择
    output wire[3:0] o_ribm_mask0, //写掩码
    output wire[31:0] o_ribm_wdata0, //写数据
    input wire[31:0] i_ribm_rdata0, //读数据
    output wire o_ribm_req0, //主机发出请求
    input wire i_ribm_gnt0, //总线授权
    input wire i_ribm_rsp0, //从机响应有效
    output wire o_ribm_rdy0, //主机响应正常
    //dbus
    output wire[31:0] o_ribm_addr1,
    output wire o_ribm_wrcs1,//读写选择
    output wire[3:0] o_ribm_mask1, //写掩码
    output wire[31:0] o_ribm_wdata1, //写数据
    input wire[31:0] i_ribm_rdata1, //读数据
    output wire o_ribm_req1, //主机发出请求
    input wire i_ribm_gnt1, //总线授权
    input wire i_ribm_rsp1, //从机响应有效
    output wire o_ribm_rdy1 //主机响应正常
);


    wire ctrl2bpu_rs1ren;
    wire[`rfidxlen_def] ctrl2bpu_rs1idx;
    wire ctrl2bpu_rs2ren;
    wire[`rfidxlen_def] ctrl2bpu_rs2idx;

    wire ctrl2exu_rdwen0;
    wire[`rfidxlen_def] ctrl2exu_rdidx0;

    wire ctrl2exu_rdwen1;
    wire[`rfidxlen_def] ctrl2exu_rdidx1;
    wire ctrl2exu_rdwen2;
    wire[`rfidxlen_def] ctrl2exu_rdidx2;

    wire ctrl2exu_resource_match;
    wire ctrl2wb_match;

    wire ctrl2ifu_wait;
    wire ctrl2bpu_wait;
    wire ctrl2dis_wait;
    wire ctrl2dis_flush;

    PIPE_CTRL u_PIPE_CTRL(
        .i_bpu_rs1ren         ( ctrl2bpu_rs1ren         ),
        .i_bpu_rs1idx         ( ctrl2bpu_rs1idx         ),
        .i_bpu_rs2ren         ( ctrl2bpu_rs2ren         ),
        .i_bpu_rs2idx         ( ctrl2bpu_rs2idx         ),

        .i_exu_rdwen0         ( ctrl2exu_rdwen0         ),
        .i_exu_rdidx0         ( ctrl2exu_rdidx0         ),
        .i_exu_rdwen1         ( ctrl2exu_rdwen1         ),
        .i_exu_rdidx1         ( ctrl2exu_rdidx1         ),
        .i_exu_rdwen2         ( ctrl2exu_rdwen2         ),
        .i_exu_rdidx2         ( ctrl2exu_rdidx2         ),

        .i_exu_resource_match ( ctrl2exu_resource_match ),
        .i_wb_match           ( ctrl2wb_match           ),

        .o_ifu_wait           ( ctrl2ifu_wait           ),
        .o_bpu_wait           ( ctrl2bpu_wait           ),
        .o_dis_wait           ( ctrl2dis_wait           ),
        .o_dis_flush          ( ctrl2dis_flush          )
    );



    wire bpu_taken_gen;
    wire[31:0] bpu_jaddr_gen;
    wire exu_taken_gen;
    wire[31:0] exu_jaddr_gen;
    wire ifu_data_vld;
    wire[31:0] ifu_iaddr;
    wire[31:0] ifu_data;

    wire bpu2ifu_vld;
    //发生跳转的同时发生流水线暂停
    wire ifu_fetch_vld = bpu_taken_gen|exu_taken_gen ? 1 : (bpu2ifu_vld);
    IFU u_IFU(
        .i_clk        ( i_clk        ),
        .i_rstn       ( i_rstn       ),

        .i_fetch_vld  ( ifu_fetch_vld  ),//todo

        .i_bpu_taken  ( bpu_taken_gen  ),
        .i_bpu_jaddr  ( bpu_jaddr_gen  ),
        .i_exu_taken  ( exu_taken_gen  ),
        .i_exu_jaddr  ( exu_jaddr_gen  ),

        .o_data_vld   ( ifu_data_vld   ),
        .o_iaddr      ( ifu_iaddr      ),
        .o_data       ( ifu_data       ),

        .o_ribm_addr  ( o_ribm_addr0  ),
        .o_ribm_wrcs  ( o_ribm_wrcs0  ),
        .o_ribm_mask  ( o_ribm_mask0  ),
        .o_ribm_wdata ( o_ribm_wdata0 ),
        .i_ribm_rdata ( i_ribm_rdata0 ),
        .o_ribm_req   ( o_ribm_req0   ),
        .i_ribm_gnt   ( i_ribm_gnt0   ),
        .i_ribm_rsp   ( i_ribm_rsp0   ),
        .o_ribm_rdy   ( o_ribm_rdy0   )
    );

    wire ifu2bpu_data_vld;
    wire[31:0] ifu2bpu_iaddr;
    wire[31:0] ifu2bpu_data;
    IFU2BPU u_IFU2BPU(
        .i_clk      ( i_clk      ),
        .i_rstn     ( i_rstn     ),

        .i_vld      ( ~ctrl2ifu_wait      ),//todo
        .o_ifu_vld  ( bpu2ifu_vld ),
        .i_flush    ( bpu_taken_gen | exu_taken_gen    ),

        .i_data_vld ( ifu_data_vld ),
        .i_iaddr    ( ifu_iaddr    ),
        .i_data     ( ifu_data     ),

        .o_data_vld ( ifu2bpu_data_vld ),
        .o_iaddr    ( ifu2bpu_iaddr    ),
        .o_data     ( ifu2bpu_data     )
    );

    //写回
    wire wb_rdwen;
    wire[`rfidxlen_def] wb_rdidx;
    wire[`xlen_def] wb_rdwdata;

    wire bpu_taken;
    wire[31:0] bpu_jaddr;
    wire bpu_inst_vld;
    wire[`xlen_def] bpu_exu_op1;
    wire[`xlen_def] bpu_exu_op2;
    wire[`xlen_def] bpu_rs2rdata;
    wire[`xlen_def] bpu_imm;
    wire bpu_rdwen;
    wire[`rfidxlen_def] bpu_rdidx;

    wire bpu_csrwren;
    wire[`csridxlen_def] bpu_csridx;

    wire[`xlen_def] bpu_csr_zimm;
    wire[`decinfo_grplen_def] bpu_decinfo_grp;
    wire[`decinfolen_def] bpu_decinfo;
    wire[`xlen_def] bpu_iaddr;
    //旁路
    wire exu_rdwen0;
    wire[`rfidxlen_def] exu_rdidx0;
    wire[`xlen_def] exu_rdwdata0;
    BPU u_BPU(
        .i_clk         ( i_clk         ),
        .i_rstn        ( i_rstn        ),

        .i_stop        ( ctrl2bpu_wait      ),//todo
        .i_flush       ( bpu_taken_gen | exu_taken_gen       ),

        .i_data_vld    ( ifu2bpu_data_vld    ),
        .i_iaddr       ( ifu2bpu_iaddr       ),
        .i_data        ( ifu2bpu_data        ),
        //这里主要用于检测数据冲突
        .o_bpu_rs1ren  ( ctrl2bpu_rs1ren  ),
        .o_bpu_rs1idx  ( ctrl2bpu_rs1idx  ),
        .o_bpu_rs2ren  ( ctrl2bpu_rs2ren  ),
        .o_bpu_rs2idx  ( ctrl2bpu_rs2idx  ),
        //这里主要是用于写回数据
        .i_rdwen       ( wb_rdwen       ),
        .i_rdidx       ( wb_rdidx       ),
        .i_rd_wdata    ( wb_rdwdata     ),

        //旁路写回
        .i_bypass_rdwen ( exu_rdwen0 ),
        .i_bypass_rdidx ( exu_rdidx0 ),
        .i_bypass_rd_wdata  ( exu_rdwdata0 ),


        //将跳转信号寄存一个周期
        .o_bpu_taken   ( bpu_taken   ),
        .o_bpu_jaddr   ( bpu_jaddr   ),
        //传递给下级
        .o_inst_vld    ( bpu_inst_vld    ),
        .o_exu_op1     ( bpu_exu_op1     ),
        .o_exu_op2     ( bpu_exu_op2     ),
        .o_rs2rdata    ( bpu_rs2rdata    ),
        .o_imm         ( bpu_imm         ),
        .o_rdwen       ( bpu_rdwen       ),
        .o_rdidx       ( bpu_rdidx       ),
        //
        .o_csr_ren     ( bpu_csrwren     ),
        .o_csridx      ( bpu_csridx      ),//todo
        .o_csr_zimm    ( bpu_csr_zimm    ),
        //
        .o_decinfo_grp ( bpu_decinfo_grp ),
        .o_decinfo     ( bpu_decinfo     ),
        .o_iaddr       ( bpu_iaddr       )
    );


    wire[`xlen_def] csr_rdata;

    wire wb_csr_wen;
    wire[`csridxlen_def] wb_csridx;
    wire[`xlen_def] wb_csr_wdata;
    //csr寄存器组
    CSR_REGFILE u_CSR_REGFILE(
        .i_clk       ( i_clk       ),
        .i_rstn      ( i_rstn      ),

        .i_csr_ren   ( bpu_csrwren   ),
        .i_csr_ridx  ( bpu_csridx  ),
        .o_csr_rdata ( csr_rdata ),

        .i_csr_wen   ( wb_csr_wen   ),
        .i_csr_widx  ( wb_csridx  ),
        .i_csr_wdata  ( wb_csr_wdata  )
    );




    wire[`xlen_def] dis_exu_op1;
    wire[`xlen_def] dis_exu_op2;
    wire[`xlen_def] dis_rs2rdata;
    wire[`xlen_def] dis_imm;
    wire dis_rdwen;
    wire[`rfidxlen_def] dis_rdidx;

    wire[`csridxlen_def] dis_csridx;
    wire[`xlen_def] dis_csr_rdata;
    wire[`xlen_def] dis_csr_zimm;

    wire[`decinfo_grplen_def] dis_decinfo_grp;
    wire[`decinfolen_def] dis_decinfo;
    wire[`xlen_def] dis_iaddr;

    DISPATCH u_DISPATCH(
        .i_clk         ( i_clk         ),
        .i_rstn        ( i_rstn        ),

        .i_dis_vld     ( (~ctrl2dis_wait)    ),//todo
        //假如bpu发生跳转,同时wb发出wait请求,不需要冲刷dis
        .i_flush       ( (ctrl2dis_wait&(~ctrl2exu_resource_match) ? 0 :bpu_taken_gen)|exu_taken_gen|ctrl2dis_flush ),

        //寄存一次跳转信号
        .i_bpu_taken   ( bpu_taken   ),
        .i_bpu_jaddr   ( bpu_jaddr   ),
        .o_bpu_taken   ( bpu_taken_gen   ),
        .o_bpu_jaddr   ( bpu_jaddr_gen   ),

        .i_inst_vld    ( bpu_inst_vld    ),
        .i_exu_op1     ( bpu_exu_op1     ),
        .i_exu_op2     ( bpu_exu_op2     ),
        .i_rs2rdata    ( bpu_rs2rdata    ),
        .i_imm         ( bpu_imm         ),
        .i_rdwen       ( bpu_rdwen       ),
        .i_rdidx       ( bpu_rdidx       ),

        .i_csridx      ( bpu_csridx      ),
        .i_csr_rdata   ( csr_rdata      ),
        .i_csr_zimm    ( bpu_csr_zimm    ),

        .i_decinfo_grp ( bpu_decinfo_grp ),
        .i_decinfo     ( bpu_decinfo     ),
        .i_iaddr       ( bpu_iaddr       ),

        .o_exu_op1     ( dis_exu_op1     ),
        .o_exu_op2     ( dis_exu_op2     ),
        .o_rs2rdata    ( dis_rs2rdata    ),
        .o_imm         ( dis_imm         ),
        .o_rdwen       ( dis_rdwen       ),
        .o_rdidx       ( dis_rdidx       ),

        .o_csridx      ( dis_csridx      ),
        .o_csr_rdata   ( dis_csr_rdata      ),//todo
        .o_csr_zimm    ( dis_csr_zimm    ),

        .o_decinfo_grp ( dis_decinfo_grp ),
        .o_decinfo     ( dis_decinfo     ),
        .o_iaddr       ( dis_iaddr       )
    );


    
    wire exu_mdu_working;
    wire exu_rdwen1;
    wire[`rfidxlen_def] exu_rdidx1;
    wire[`xlen_def] exu_rdwdata1;   
    wire exu_lsu_working;
    wire exu_rdwen2;
    wire[`rfidxlen_def] exu_rdidx2;
    wire[`xlen_def] exu_rdwdata2;

    wire exu_taken;
    wire[`xlen_def] exu_jaddr;
    EXU u_EXU(
        .i_clk         ( i_clk         ),
        .i_rstn        ( i_rstn        ),

        .i_vld       ( (~(exu_taken_gen | ctrl2dis_wait)) ), //发生跳转时,同时也要防止执行段的lsu与mdu接受到错误的指令
        //译码信息
        .i_exu_op1     ( dis_exu_op1     ),
        .i_exu_op2     ( dis_exu_op2     ),
        .i_rs2rdata    ( dis_rs2rdata    ),
        .i_imm         ( dis_imm         ),
        .i_rdwen       ( dis_rdwen       ),
        .i_rdidx       ( dis_rdidx       ),

        .i_csridx      ( dis_csridx      ),
        .i_csr_rdata   ( dis_csr_rdata      ),//todo
        .i_csr_zimm    ( dis_csr_zimm    ),

        .i_decinfo_grp ( dis_decinfo_grp ),
        .i_decinfo     ( dis_decinfo     ),
        .i_iaddr       ( dis_iaddr       ),


        //读写控制信息
        //注意：此处不是写回信息，而是exu各个模块的写寄存器信息，主要用于读写冲突判断
        .o_exu_rdwen0           ( ctrl2exu_rdwen0 ),
        .o_exu_rdidx0           ( ctrl2exu_rdidx0 ),
        .o_exu_rdwen1           ( ctrl2exu_rdwen1 ),
        .o_exu_rdidx1           ( ctrl2exu_rdidx1 ),
        .o_exu_rdwen2           ( ctrl2exu_rdwen2 ),
        .o_exu_rdidx2           ( ctrl2exu_rdidx2 ),
        .o_exu_resource_match   ( ctrl2exu_resource_match ),
        //
        .o_rdwen0      ( exu_rdwen0      ),
        .o_rdidx0      ( exu_rdidx0      ),
        .o_rdwdata0    ( exu_rdwdata0    ),
        .o_mdu_working ( exu_mdu_working ),
        .o_rdwen1      ( exu_rdwen1      ),
        .o_rdidx1      ( exu_rdidx1      ),
        .o_rdwdata1    ( exu_rdwdata1    ),
        .o_lsu_working ( exu_lsu_working ),
        .o_rdwen2      ( exu_rdwen2      ),
        .o_rdidx2      ( exu_rdidx2      ),
        .o_rdwdata2    ( exu_rdwdata2    ),
        //csr写回
        .o_csr_wen     ( wb_csr_wen   ),
        .o_csridx      ( wb_csridx    ),
        .o_csr_wdata   ( wb_csr_wdata ),
        
        //分支预测错误
        .o_exu_taken   ( exu_taken   ),
        .o_exu_jaddr   ( exu_jaddr   ),
        //rib总线主机
        .o_ribm_addr  ( o_ribm_addr1  ),
        .o_ribm_wrcs  ( o_ribm_wrcs1  ),
        .o_ribm_mask  ( o_ribm_mask1  ),
        .o_ribm_wdata ( o_ribm_wdata1 ),
        .i_ribm_rdata ( i_ribm_rdata1 ),
        .o_ribm_req   ( o_ribm_req1   ),
        .i_ribm_gnt   ( i_ribm_gnt1   ),
        .i_ribm_rsp   ( i_ribm_rsp1   ),
        .o_ribm_rdy   ( o_ribm_rdy1   )

    );


    WB u_WB(
        .i_clk       ( i_clk       ),
        .i_rstn      ( i_rstn      ),

        .i_flush     ( exu_taken_gen   ),

        .i_rdwen0    ( exu_rdwen0    ),
        .i_rdidx0    ( exu_rdidx0    ),
        .i_rdwdata0  ( exu_rdwdata0  ),

        .i_mdu_working ( exu_mdu_working ),
        .i_rdwen1    ( exu_rdwen1    ),
        .i_rdidx1    ( exu_rdidx1    ),
        .i_rdwdata1  ( exu_rdwdata1  ),

        .i_lsu_working ( exu_lsu_working ),
        .i_rdwen2    ( exu_rdwen2    ),
        .i_rdidx2    ( exu_rdidx2    ),
        .i_rdwdata2  ( exu_rdwdata2  ),

        .i_exu_taken ( exu_taken     ),
        .i_exu_jaddr ( exu_jaddr     ),
        .o_exu_taken ( exu_taken_gen     ),
        .o_exu_jaddr ( exu_jaddr_gen     ),

        .o_wait      ( ctrl2wb_match     ),

        .o_wb_rdwen     ( wb_rdwen      ),
        .o_wb_rdidx     ( wb_rdidx      ),
        .o_wb_rdwdata   ( wb_rdwdata  )
    );





endmodule