



//写回模块


`include "config.v"





module WB (
    input wire i_clk,
    input wire i_rstn,

    input wire i_flush,

    //单周期写回
    input wire i_rdwen0,
    input wire[`rfidxlen_def] i_rdidx0,
    input wire[`xlen_def] i_rdwdata0,
    //mdu写回
    input wire i_mdu_working,
    input wire i_rdwen1,
    input wire[`rfidxlen_def] i_rdidx1,
    input wire[`xlen_def] i_rdwdata1,
    //lsu写回
    input wire i_lsu_working,
    input wire i_rdwen2,
    input wire[`rfidxlen_def] i_rdidx2,
    input wire[`xlen_def] i_rdwdata2,
    //跳转
    input wire i_exu_taken,
    input wire[`xlen_def] i_exu_jaddr,
    output reg o_exu_taken,
    output reg[`xlen_def] o_exu_jaddr,
    //写回等待
    output wire o_wait,
    output wire o_wb_rdwen,
    output wire[`rfidxlen_def] o_wb_rdidx,
    output wire[`xlen_def] o_wb_rdwdata
);
    reg rdwen0;
    reg rdwen1;
    reg rdwen2;
    reg[`rfidxlen_def] rdidx0;
    reg[`rfidxlen_def] rdidx1;
    reg[`rfidxlen_def] rdidx2;
    reg[`xlen_def] rdwdata0;
    reg[`xlen_def] rdwdata1;
    reg[`xlen_def] rdwdata2;


    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            rdwen0<=0;
            rdwen1<=0;
            rdwen2<=0;
        end
        else if((~o_wait) | i_flush) begin//写回等待
            rdwen0 <= i_flush ? 0 : i_rdwen0;
            rdwen1 <= (i_flush&(~i_rdwen1)) ? 0 : i_rdwen1;
            rdwen2 <= (i_flush&(~i_rdwen2)) ? 0 : i_rdwen2;
            rdidx0 <= i_rdidx0;
            rdidx1 <= i_rdidx1;
            rdidx2 <= i_rdidx2;
            rdwdata0 <= i_rdwdata0;
            rdwdata1 <= i_rdwdata1;
            rdwdata2 <= i_rdwdata2;
            
        end
        else if(o_wait)begin//当需要进行写回仲裁时
            if(rdwen2)begin
                rdwen2<=0;
            end 
            else if(rdwen1)begin
                rdwen1<=0;
            end
        end

    end

    //大于等于2个写使能,则暂停
    assign o_wait = (rdwen0 & rdwen1) | (rdwen0 & rdwen2) | (rdwen1 & rdwen2);
    assign o_wb_rdwen = rdwen0 | rdwen1 | rdwen2;
    //写回优先级:2>1>0
    assign o_wb_rdidx = rdwen2 ? rdidx2 : (rdwen1 ? rdidx1 : rdidx0);
    assign o_wb_rdwdata = rdwen2 ? rdwdata2 : (rdwen1 ? rdwdata1 : rdwdata0);


    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            o_exu_taken<=0;
            o_exu_jaddr<=0;
        end
        else begin
            o_exu_taken <= i_flush ? 0 : i_exu_taken;
            o_exu_jaddr <= i_exu_jaddr;
        end
    end

endmodule
