







//地址:

module TIMER2RIB (
    input wire i_clk,
    input wire i_rstn,
    //RIB接口
    input wire[31:0] i_ribs_addr,//主地址线
    input wire i_ribs_wrcs,//读写选择
    input wire[3:0] i_ribs_mask, //掩码
    input wire[31:0] i_ribs_wdata, //写数据
    output reg[31:0] o_ribs_rdata,

    input wire i_ribs_req, 
    output wire o_ribs_gnt, 
    output reg o_ribs_rsp, 
    input wire i_ribs_rdy
);

//ctrl:
//第一位是定时器使能位
reg[31:0] timer_ctrl;
reg[63:0] timer_cnt;


always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn)begin
        timer_ctrl<=32'h1;
        timer_cnt<=64'h0;
        o_ribs_rsp<=1'b0;
    end
    else if(i_ribs_req) begin
        o_ribs_rsp <= 1'b1;
        case(i_ribs_addr[15:0])
        16'h000:begin
            if(i_ribs_wrcs)begin//写
                //只写最后一位
                timer_ctrl <= {31'b0,i_ribs_wdata[0]};
            end
            else begin//读
                //只读最后一位
                o_ribs_rdata <= {31'b0,timer_ctrl[0]};
            end
        end
        16'h004:begin//定时器的低32位
            if(i_ribs_wrcs)begin
                timer_cnt[31:0] <= i_ribs_wdata;
            end
            else begin
                o_ribs_rdata <= timer_cnt[31:0];
            end
        end
        16'h008:begin//定时器的高32位
            if(i_ribs_wrcs)begin
                timer_cnt[63:32] <= i_ribs_wdata;
            end
            else begin
                o_ribs_rdata <= timer_cnt[63:32];
            end
        end
        endcase
    end
    else begin
        o_ribs_rsp <= 1'b0;
        if(timer_ctrl[0])begin
            timer_cnt <= timer_cnt + 1;
        end
    end
end

assign o_ribs_gnt = i_ribs_req;
























endmodule