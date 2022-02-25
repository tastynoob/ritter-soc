


//同步FIFO
module SYNC_FIFO #(
    parameter unitwid = 32,
    parameter unitdpth = 16
)(
    input wire i_clk,
    input wire i_rstn,

    input wire i_flush,

    input wire i_wen,
    input wire[unitwid-1:0] i_unitdata,
    output wire o_full,

    input wire i_ren,
    output wire[unitwid-1:0] o_unitdata,
    output wire o_empty,

    output reg[$clog2(unitdpth):0] o_fifo_cnt
);


    function integer clogb2 (input integer bit_depth);
    begin
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
        bit_depth = bit_depth>>1;
    end
    endfunction

    //fifo储存单元
    reg[unitwid-1:0] fifo_units[unitdpth-1:0];
    //fifo头指针,尾指针,长度
    reg[clogb2(unitdpth)-1:0] hptr,eptr;

    
    //hptr + 1
    wire[clogb2(unitdpth)-1:0] hptr_1 = ((hptr == (unitdpth-1)) ? 0 : (hptr + 1));
    //eptr + 1
    wire[clogb2(unitdpth)-1:0] eptr_1 = ((eptr == (unitdpth-1)) ? 0 : (eptr + 1));

    assign o_full =  (o_fifo_cnt == (unitdpth));
    assign o_empty = (o_fifo_cnt == 0);

    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            hptr<=0;
            eptr<=0;
            o_fifo_cnt<=0;
        end
        else if(i_flush)begin
            hptr<=0;
            eptr<=0;
            o_fifo_cnt<=0;
        end
        else begin

            if(i_wen & i_ren)begin
                //不做任何操作
            end
            else if(i_wen & (~o_full))begin
                o_fifo_cnt<=o_fifo_cnt + 1;
            end
            else if(i_ren & (~o_empty))begin
                o_fifo_cnt<=o_fifo_cnt - 1;
            end


            if(i_wen)begin//只有写
                fifo_units[hptr] <= i_unitdata;
                hptr<=hptr_1;
            end
            if(i_ren & (~o_empty))begin//只有读
                eptr<=eptr_1;
            end
        end
    end

    assign o_unitdata = fifo_units[eptr];

endmodule




//取指段专用FIFO
//没有满输出,没有空输出,只有FIFO储存数量输出
module IFU_FIFO #(
    parameter unitwid = 32,
    parameter unitdpth = 16
)(
    input wire i_clk,
    input wire i_rstn,

    input wire i_flush,//冲刷FIFO

    input wire i_wen,
    input wire[unitwid-1:0] i_unitdata,

    input wire i_ren,
    output wire[unitwid-1:0] o_unitdata,

    output wire o_empty,
    output reg[$clog2(unitdpth):0] o_fifo_cnt
);


    function integer clogb2 (input integer bit_depth);
    begin
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
        bit_depth = bit_depth>>1;
    end
    endfunction

    //fifo储存单元
    reg[unitwid-1:0] fifo_units[unitdpth-1:0];
    //fifo头指针,尾指针,长度
    reg[clogb2(unitdpth)-1:0] hptr,eptr;

    
    //hptr + 1
    wire[clogb2(unitdpth)-1:0] hptr_1 = ((hptr == (unitdpth-1)) ? 0 : (hptr + 1));
    //eptr + 1
    wire[clogb2(unitdpth)-1:0] eptr_1 = ((eptr == (unitdpth-1)) ? 0 : (eptr + 1));



    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            hptr<=0;
            eptr<=0;
            o_fifo_cnt<=0;
        end
        else if(i_flush)begin
            //在ifu跳转时如果握手成功，仍需写入当前请求地址
            if(i_wen)begin
                fifo_units[0] <= i_unitdata;
                o_fifo_cnt<=1;
                hptr<=hptr_1;
            end
            else begin//握手失败,直接清空
                o_fifo_cnt<=0;
                hptr<=0;
            end
            eptr<=0;
        end
        else begin
            if(i_wen & i_ren)begin
                //不做任何操作
            end
            else if(i_wen)begin
                o_fifo_cnt<=o_fifo_cnt + 1;
            end
            else if(i_ren)begin
                o_fifo_cnt<=o_fifo_cnt - 1;
            end


            if(i_wen)begin//只有写
                fifo_units[hptr] <= i_unitdata;
                hptr<=hptr_1;
            end
            if(i_ren)begin//只有读
                eptr<=eptr_1;
            end
        end
    end

    assign o_unitdata = fifo_units[eptr];

    assign o_empty = o_fifo_cnt == 0;

endmodule