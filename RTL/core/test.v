

//延迟测试

`include "config.v"
`include "defines.v"

module TEST0 (
    
);


reg[4:2] llll;
reg[4:2] llll2;

always  begin
    {llll,llll2}=0;
end








    
endmodule



module TEST (
    input wire i_clk,
    input wire i_rstn,
    input wire[4:0] i_alu_rdidx,
    input wire[5:0] i_decinfo_grp,
    input wire[9:0] i_aluinfo,
    input wire[31:0] i_alu_op1,
    input wire[31:0] i_alu_op2,
    output reg o_alu_rdwen,
    output reg[4:0] o_alu_rdidx,
    output reg[31:0] o_alu_rdwdata
);


reg[4:0] r_alu_rdidx;
reg[5:0] r_decinfo_grp;
reg[9:0] r_aluinfo;
reg[31:0] r_alu_op1;
reg[31:0] r_alu_op2;


always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn)begin
        r_alu_rdidx <= 0;
        r_decinfo_grp <= 0;
        r_aluinfo <= 0;
        r_alu_op1 <= 0;
        r_alu_op2 <= 0;
    end else begin
        r_alu_rdidx <= i_alu_rdidx;
        r_decinfo_grp <= i_decinfo_grp;
        r_aluinfo <= i_aluinfo;
        r_alu_op1 <= i_alu_op1;
        r_alu_op2 <= i_alu_op2;
    end
end

wire alu_rdwen;
wire[4:0] alu_rdidx;
wire[31:0] alu_rdwdata;
EXU_ALU u_EXU_ALU(
    .i_clk         ( i_clk         ),
    .i_rstn        ( i_rstn        ),

    .i_alu_rdidx   ( r_alu_rdidx   ),
    .i_decinfo_grp ( r_decinfo_grp ),
    .i_aluinfo     ( r_aluinfo     ),

    .i_alu_op1     ( r_alu_op1     ),
    .i_alu_op2     ( r_alu_op2     ),

    .o_alu_rdwen   ( alu_rdwen   ),
    .o_alu_rdidx   ( alu_rdidx   ),
    .o_alu_rdwdata ( alu_rdwdata )
);

always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn)begin
        o_alu_rdwen <= 0;
        o_alu_rdidx <= 0;
        o_alu_rdwdata <= 0;
    end else begin
        o_alu_rdwen <= alu_rdwen;
        o_alu_rdidx <= alu_rdidx;
        o_alu_rdwdata <= alu_rdwdata;
    end
end








    
endmodule



module TEST2 (
    input wire i_clk,
    input wire i_rstn,
    input wire i_flush,

    //取指传入
    input wire i_data_vld,
    input wire[`xlen_def] i_iaddr,
    input wire[`ilen_def] i_data,
    input wire i_bpu_rsx_rdy,//rs1允许读,没有发生冲突,为1时才能读
    //写回
    input wire i_rdwen,
    input wire[`rfidxlen_def] i_rdidx,
    input wire[`xlen_def] i_rd_wdata,

    //rs1,rs2读冲突检测
    output reg o_bpu_rs1ren,
    output reg[`rfidxlen_def] o_bpu_rs1idx,
    output reg o_bpu_rs2ren,
    output reg[`rfidxlen_def] o_bpu_rs2idx,

    //分支预测的结果
    output reg o_wait,//等待，需要暂停上级所有流水线
    output reg o_bpu_taken,//分支预测跳转,同时冲刷流水线
    output reg[12:0] o_bpu_jaddr,//预测地址

    //传递给下级流水线
    output reg o_inst_vld,
    output reg[`xlen_def] o_exu_op1,
    output reg o_rdwen,
    output reg[`rfidxlen_def] o_rdidx,
    output reg[`decinfolen_def] o_decinfo
);

reg data_vld;
reg[`xlen_def] iaddr;
reg[`ilen_def] data;
reg bpu_rxs_rdy;
reg rdwen;
reg[`rfidxlen_def] rdidx;
reg[`xlen_def] rd_wdata;
reg csrwen;
reg[`csridxlen_def] csridx;
reg[`xlen_def] csr_wdata;


always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn)begin
        data_vld <= 0;
        iaddr <= 0;
        data <= 0;
        bpu_rxs_rdy <= 0;
        rdwen <= 0;
        rdidx <= 0;
        rd_wdata <= 0;
        csrwen <= 0;
        csridx <= 0;
        csr_wdata <= 0;
    end else begin
        data_vld <= i_data_vld;
        iaddr <= i_iaddr;
        data <= i_data;
        bpu_rxs_rdy <= i_bpu_rsx_rdy;
        rdwen <= i_rdwen;
        rdidx <= i_rdidx;
        rd_wdata <= i_rd_wdata;
    end
end



wire bpu_rs1ren;
wire[`rfidxlen_def] bpu_rs1idx;
wire bpu_rs2ren;
wire[`rfidxlen_def] bpu_rs2idx;

wire _wait;
wire _bpu_taken;
wire[`xlen_def] _bpu_jaddr;

wire _inst_vld;
wire[`xlen_def] _exu_op1;
wire[`xlen_def] _exu_op2;
wire[`xlen_def] _rs2rdata;
wire _rdwen;
wire[`rfidxlen_def] _rdidx;
wire _csrwren;
wire[`csridxlen_def] _csridx;
wire[`xlen_def] _csr_zimm;
wire[`decinfo_grplen_def] _decinfo_grp;
wire[`decinfolen_def] _decinfo;




BPU u_BPU(
    .i_clk         ( i_clk         ),
    .i_rstn        ( i_rstn        ),
    .i_flush       ( flush       ),
    .i_data_vld    ( data_vld    ),
    .i_iaddr       ( iaddr       ),
    .i_data        ( data        ),
    .o_bpu_rs1ren  ( bpu_rs1ren  ),
    .o_bpu_rs1idx  ( bpu_rs1idx  ),
    .o_bpu_rs2ren  ( bpu_rs2ren  ),
    .o_bpu_rs2idx  ( bpu_rs2idx  ),
    .i_bpu_rsx_rdy ( bpu_rsx_rdy ),
    .i_rdwen       ( rdwen       ),
    .i_rdidx       ( rdidx       ),
    .i_rd_wdata    ( rd_wdata    ),
    .i_csrwen      ( csrwen      ),
    .i_csridx      ( csridx      ),
    .i_csr_wdata   ( csr_wdata   ),
    .o_wait        ( _wait        ),
    .o_bpu_taken   ( _bpu_taken   ),
    .o_bpu_jaddr   ( _bpu_jaddr   ),
    .o_inst_vld    ( _inst_vld    ),
    .o_exu_op1     ( _exu_op1     ),
    .o_exu_op2     ( _exu_op2     ),
    .o_rs2rdata    ( _rs2rdata    ),
    .o_rdwen       ( _rdwen       ),
    .o_rdidx       ( _rdidx       ),
    .o_csrwren     ( _csrwren     ),
    .o_csridx      ( _csridx      ),
    .o_csr_zimm    ( _csr_zimm    ),
    .o_decinfo_grp ( _decinfo_grp ),
    .o_decinfo     ( _decinfo     )
);

    

always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn)begin
        o_bpu_rs1ren <= 0;
        o_bpu_rs1idx <= 0;
        o_bpu_rs2ren <= 0;
        o_bpu_rs2idx <= 0;
        o_wait <= 0;
        o_bpu_taken <= 0;
        o_bpu_jaddr <= 0;
        o_inst_vld <= 0;
        o_exu_op1 <= 0;
        o_rdwen <= 0;
        o_rdidx <= 0;
        o_decinfo <= 0;
    end 
    else begin
        o_bpu_rs1ren <= bpu_rs1ren;
        o_bpu_rs1idx <= bpu_rs1idx;
        o_bpu_rs2ren <= bpu_rs2ren;
        o_bpu_rs2idx <= bpu_rs2idx;
        o_wait <= _wait;
        o_bpu_taken <= _bpu_taken;
        o_bpu_jaddr <= _bpu_jaddr;
        o_inst_vld <= _inst_vld;
        o_exu_op1 <= _exu_op1;
        o_rdwen <= _rdwen;
        o_rdidx <= _rdidx;
        o_decinfo <= _decinfo;
    end
end



endmodule