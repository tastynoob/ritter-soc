





/*
地址:0xf0

gpio0:j13
gpio1:h13
gpio2:f16
gpio3:e16

*/

module ADC2RIB (
    input wire i_clk,
    input wire i_adc_clk,
    input wire i_rstn,

    //RIB接口
    input wire[31:0] i_ribs_addr,//主地址线
    input wire i_ribs_wrcs,//读写选择
    input wire[3:0] i_ribs_mask, //掩码
    input wire[31:0] i_ribs_wdata, //写数据
    output reg[31:0] o_ribs_rdata,
    input wire i_ribs_req, 
    output wire o_ribs_gnt, 
    output wire o_ribs_rsp, 
    input wire i_ribs_rdy
);

//输入输出模式设置
//1:输出模式
//0:输入模式
reg[2:0] channel_select;

//地址:
//0x00:adc channel select
//0x04:adc ctrl, write then start adc, read then return if finished
//0x08:adc read
reg start_adc;
wire[11:0] adc_read;
wire adc_finished;

assign o_ribs_gnt = i_ribs_req;
reg handshake_rdy;
always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn)begin
        handshake_rdy<=0;
        start_adc <= 0;
    end
    else begin
        if(i_ribs_req)begin
            handshake_rdy<=1;
            case(i_ribs_addr[15:0])
            16'h00:begin
                if(i_ribs_wrcs)begin//写
                    channel_select <= i_ribs_wdata[2:0];
                end
                else begin
                    o_ribs_rdata   <= {30'h0,channel_select};
                end
            end
            16'h04:begin
                if(i_ribs_wrcs)begin
                    start_adc <= i_ribs_wdata[0];
                end
                else begin
                    o_ribs_rdata    <= {31'h0,adc_finished};
                end
            end
            16'h08:begin
                if(i_ribs_wrcs)begin//只读
                    
                end
                else begin
                    o_ribs_rdata    <= {20'h0,adc_read};
                end
            end
            endcase
        end
        else begin
            handshake_rdy<=0;
        end
    end
end
assign o_ribs_rsp = handshake_rdy;

adc u_adc (
    .eoc(adc_finished),
    .dout(adc_read), 
    .clk(i_adc_clk), 
    .pd(1'b0), 
    .s(channel_select), 
    .soc(start_adc) 
);

    
endmodule