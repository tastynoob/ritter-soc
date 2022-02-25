


`include "config.v"
//pc生成
module IFU_PC (
    input wire i_clk,
    input wire i_rstn,

    input wire i_fetch_vld,
    input wire i_fifo_empty,
    //流水线暂停，pc回退
    input wire[`xlen_def] i_pc_goback,

    //允许pc改变,只有当改信号为1时,才允许pc自增
    input wire i_pc_vld,
    input wire i_jump,
    input wire[`xlen_def] i_jump_addr,
    //当前待取指pc
    output wire[`xlen_def] o_fetch_addr
);

    reg[`xlen_def] pc;

    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            pc <= `cpu_reset_addr;
        end
        else begin
            
            if(i_pc_vld | i_jump) begin
                pc <= i_jump ? (i_pc_vld ? i_jump_addr + 4 :  i_jump_addr) : pc + 4 ;
            end
            else if((~i_fifo_empty) & (~i_fetch_vld)) begin//当当前取到了数据,但是发生暂停时,则需要进行退回
                pc <= i_pc_goback;
            end

        end
    end

    assign o_fetch_addr =   i_jump ? i_jump_addr :
                            pc;

endmodule