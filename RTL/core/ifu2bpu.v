

`include "config.v"
`include "defines.v"


/*
IFU to BPU

使用FIFO来解决流水线频繁暂停的问题
*/

//ifu流水级
module IFU2BPU (
    input wire i_clk,
    input wire i_rstn,

    input wire i_vld,
    output wire o_ifu_vld,
    input wire i_flush,

    input wire i_data_vld,
    input wire[`xlen_def] i_iaddr,
    input wire[`ilen_def] i_data,

    output wire o_data_vld,
    output wire[`xlen_def] o_iaddr,
    output wire[`ilen_def] o_data
);




wire fifo_full;
wire fifo_empty;
wire[63:0] fifo_out;
wire[8:0] fifo_cnt;
//同步FIFO
SYNC_FIFO#(
    .unitwid    ( 64 ),
    .unitdpth   ( 8 )
)u_SYNC_FIFO(
    .i_clk      ( i_clk      ),
    .i_rstn     ( i_rstn     ),

    .i_flush    ( i_flush   ),

    .i_wen      ( i_data_vld         ),
    .i_unitdata ( {i_data,i_iaddr}   ),
    .o_full     ( fifo_full     ),

    .i_ren      ( (i_vld & (~fifo_empty))    ),
    .o_unitdata ( fifo_out      ),
    .o_empty    ( fifo_empty    ),

    .o_fifo_cnt  ( fifo_cnt  )
);

//i_vld==0 && fifo_full==1,ifu_vld = 0
assign o_ifu_vld = ~((i_vld==0) & (fifo_full==1));

//只要fifo不为空，就可以读取数据
assign o_data_vld = ~fifo_empty;
assign o_iaddr = fifo_out[31:0];
assign o_data = fifo_out[63:32];

















    // always @(posedge i_clk or negedge i_rstn) begin
    //     if(~i_rstn)begin
    //         o_data_vld<=0;
    //         o_iaddr <= 0;
    //         o_data <= `inst_nop;
    //     end
    //     else if(i_vld | i_flush) begin
    //         o_data_vld <= (i_flush) ? 0 : i_data_vld;
    //         o_iaddr <= (i_flush|(~i_data_vld)) ? 0 : i_iaddr;
    //         o_data <= (i_flush|(~i_data_vld)) ? `inst_nop : i_data;
    //     end
    // end


    
    
endmodule