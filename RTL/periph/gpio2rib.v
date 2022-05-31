





/*
地址:0xf0

gpio0:j13
gpio1:h13
gpio2:f16
gpio3:e16

*/

module GPIO2RIB (
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
    output wire o_ribs_rsp, 
    input wire i_ribs_rdy,


    output wire[23:0] o_gpio_mode,
    input wire[23:0] i_gpio_in,
    output wire[23:0] o_gpio_out
);

//输入输出模式设置
//1:输出模式
//0:输入模式
reg[23:0] gpio_mode;
reg[23:0] gpio_out;
//地址:
//0x00:gpio_mode
//0x04:gpio_out
//0x08:gpio_in
assign o_gpio_mode = gpio_mode;
assign o_gpio_out = gpio_out;



assign o_ribs_gnt = i_ribs_req;
reg handshake_rdy;
always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn)begin
        handshake_rdy<=0;
    end
    else begin
        if(i_ribs_req)begin
            handshake_rdy<=1;
            case(i_ribs_addr[15:0])
            16'h00:begin
                if(i_ribs_wrcs)begin//写
                    gpio_mode       <=i_ribs_wdata[23:0];
                end
                else begin
                    o_ribs_rdata    <={8'h0,gpio_mode};
                end
            end
            16'h04:begin
                if(i_ribs_wrcs)begin
                    gpio_out        <=i_ribs_wdata[23:0];
                end
                else begin
                    o_ribs_rdata    <= {8'h0,gpio_out};
                end
            end
            16'h08:begin
                if(i_ribs_wrcs)begin//只读
                    
                end
                else begin
                    o_ribs_rdata    <= {8'h0,i_gpio_in};
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













    
endmodule