

/*
通用寄存器组

*/

`include "config.v"



module REGFILE (
    input wire i_clk,
    input wire i_rstn,
    input wire i_rdwen,
    input wire[`rfidxlen_def] i_rdidx,
    input wire[`xlen_def] i_rd_wdata,

    input wire i_rs1ren,
    input wire[`rfidxlen_def] i_rs1idx,
    output wire[`xlen_def] o_rs1_rdata,

    input wire i_rs2ren,
    input wire[`rfidxlen_def] i_rs2idx,
    output wire[`xlen_def] o_rs2_rdata,
    //旁路
    input wire i_bypass_rdwen,
    input wire[`rfidxlen_def] i_bypass_rdidx,
    input wire[`xlen_def] i_bypass_rd_wdata

);


    reg[`xlen_def] rfxs[31:0];//31个寄存器

    generate
        genvar i;
        for(i=0;i<32;i=i+1)begin:gen_regfile_rd
            if(i==0)begin
                //0号寄存器不做任何写操作
            end
            else begin
                always @(posedge i_clk) begin
                    if(i_rdwen & (i_rdidx == i))begin
                        rfxs[i] <= i_rd_wdata;
                    end
                end
            end
        end
    endgenerate


    assign o_rs1_rdata =    i_rs1ren ? 
                            (
                            ((i_rs1idx == i_bypass_rdidx) & i_bypass_rdwen)  ?
                            i_bypass_rd_wdata :
                                (
                                ((i_rs1idx == i_rdidx) & i_rdwen) ? i_rd_wdata 
                                : rfxs[i_rs1idx]
                                )
                            ) 
                            : 0;

    assign o_rs2_rdata =    i_rs2ren ? 
                            (
                            ((i_rs2idx == i_bypass_rdidx) & i_bypass_rdwen)  ?
                            i_bypass_rd_wdata :
                                (
                                ((i_rs2idx == i_rdidx) & i_rdwen) ? i_rd_wdata 
                                : rfxs[i_rs2idx]
                                )
                            ) 
                            : 0;


    wire[31:0] x1_ra = rfxs[1];
    wire[31:0] x2_sp = rfxs[2];
    wire[31:0] x3_gp = rfxs[3];
    wire[31:0] x4_tp = rfxs[4];
    wire[31:0] x5_t0 = rfxs[5];
    wire[31:0] x6_t1 = rfxs[6];
    wire[31:0] x7_t2 = rfxs[7];
    wire[31:0] x8_s0 = rfxs[8];
    wire[31:0] x9_s1 = rfxs[9];
    wire[31:0] x10_a0 = rfxs[10];
    wire[31:0] x11_a1 = rfxs[11];
    wire[31:0] x12_a2 = rfxs[12];
    wire[31:0] x13_a3 = rfxs[13];
    wire[31:0] x14_a4 = rfxs[14];
    wire[31:0] x15_a5 = rfxs[15];
    wire[31:0] x16_a6 = rfxs[16];
    wire[31:0] x17_a7 = rfxs[17];
    wire[31:0] x18_s2 = rfxs[18];
    wire[31:0] x19_s3 = rfxs[19];
    wire[31:0] x20_s4 = rfxs[20];
    wire[31:0] x21_s5 = rfxs[21];
    wire[31:0] x22_s6 = rfxs[22];
    wire[31:0] x23_s7 = rfxs[23];
    wire[31:0] x24_s8 = rfxs[24];
    wire[31:0] x25_s9 = rfxs[25];
    wire[31:0] x26_s10 = rfxs[26];
    wire[31:0] x27_s11 = rfxs[27];
    wire[31:0] x28_t3 = rfxs[28];
    wire[31:0] x29_t4 = rfxs[29];
    wire[31:0] x30_t5 = rfxs[30];
    wire[31:0] x31_t6 = rfxs[31];

    // always @(posedge i_clk) begin
    //     if(x1_ra == 32'h83)begin
    //         $stop();
    //     end
    //     //判断哪个寄存器的值为0x31
    //     if(x2_sp == 32'h83)begin
    //         $stop();
    //     end
    //     if(x3_gp == 32'h83)begin
    //         $stop();
    //     end
    //     if(x4_tp == 32'h83)begin
    //         $stop();
    //     end
    //     if(x5_t0 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x6_t1 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x7_t2 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x8_s0 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x9_s1 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x10_a0 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x11_a1 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x12_a2 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x13_a3 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x14_a4 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x15_a5 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x16_a6 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x17_a7 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x18_s2 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x19_s3 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x20_s4 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x21_s5 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x22_s6 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x23_s7 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x24_s8 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x25_s9 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x26_s10 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x27_s11 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x28_t3 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x29_t4 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x30_t5 == 32'h83)begin
    //         $stop();
    //     end
    //     if(x31_t6 == 32'h83)begin
    //         $stop();
    //     end
    // end




endmodule