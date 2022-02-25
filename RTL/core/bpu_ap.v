



//处理取指段，指令的对齐模式

/*
当align_node = 1并且inst_rv32=1,写入缓存,需要等待下一次数据,初次之外，其它情况都不需要等待


由于取指始终是pc自增4
因此只会出现一下2种情况
1:地址总是16位对齐
2:地址总是32位对齐


假设我们只支持32位定长指令集，则比较简便



*/





`include "config.v"



//仅处理32位指令的对齐问题
module BPU_AP (
    input wire i_clk,
    input wire i_rstn,

    input wire i_stop,//暂停,保持指令不变输出
    input wire i_flush,//冲刷

    input wire i_data_vld,//取指读出的数据是否有效
    input wire[`xlen_def] i_iaddr,//数据地址
    input wire[`ilen_def] i_data,//数据地址舍去低2位后的数据

    output wire o_inst_vld,//对齐处理完成,已经是可译码的指令
    output wire[`xlen_def] o_inst_pc,//指令pc
    output wire[`ilen_def] o_inst//对齐处理后的指令
);


    
    reg[15:0] leftover_buffer;//16位剩余缓存
    reg leftover_ok;//剩余缓存是否保存有数据
    reg[`xlen_def] last_iaddr;//上次读取的地址,合并上次数据与当前数据后的指令的地址仍为上次的数据地址
    //地址的最后2位代表对齐模式,这里只处理16位对齐，只需要第2位即可
    wire align16_mode = i_iaddr[1] | leftover_ok;
    


    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn) begin
            leftover_ok <= 0;
        end 
        else if(i_flush)begin
            leftover_ok<=0;
        end
        else if(i_data_vld & (~i_stop)) begin//读取的数据有效
            last_iaddr<=i_iaddr;
            if(align16_mode)begin
                leftover_ok <= 1;
                leftover_buffer <= i_data[31:16];
            end
            else begin
                leftover_ok<=0;
            end
        end
    end

    assign o_inst_vld = align16_mode ? leftover_ok&i_data_vld : i_data_vld;
    assign o_inst_pc = align16_mode ? last_iaddr : i_iaddr;//指令pc
    assign o_inst = align16_mode ? {i_data[15:0],leftover_buffer} : i_data;
    
endmodule