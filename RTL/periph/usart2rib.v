

//usart模块,使用rib总线传输数据
//使用方法:
//寄存器:usart_ctrl:0x000 控制寄存器
//寄存器:tx_data:0x004 数据发送寄存器
//寄存器:rx_data:0x008 数据接收寄存器

module USART2RIB (
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
    input wire i_ribs_rdy,

    //串口接口
    input wire i_rx,
    output wire o_tx
);


reg[7:0] tx_buffer;


wire rx_vld;
wire[7:0] rx_data;
wire rx_err;
wire tx_rdy;
reg tx_en;

//控制状态寄存器
//低3位分别是:串口读错误,串口读完成,串口发送完成
wire[31:0] usart_ctrl = {29'd0,rx_err,rx_vld,tx_rdy};



///rib握手协议
wire handshake_rdy = i_ribs_req;
always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn)begin
        tx_en <= 0;
        o_ribs_rsp <= 0;
    end
    else begin
        if(handshake_rdy)begin
            case(i_ribs_addr[15:0])
            16'h000:begin//读控制寄存器
                if(i_ribs_wrcs)begin//写无效

                end
                else begin//读
                    o_ribs_rdata <= usart_ctrl;
                end
            end
            16'h004:begin//读写数据发送寄存器
                //发送数据
                if(i_ribs_wrcs)begin//写
                    tx_buffer <= i_ribs_wdata[7:0];
                    tx_en <= 1;
                end
                else begin//读
                    o_ribs_rdata <= {24'b0,tx_buffer};
                end
            end
            16'h008:begin//读数据接受寄存器(只读)
                if(i_ribs_wrcs)begin//写无效
                    
                end
                else begin
                    o_ribs_rdata <= {24'b0,rx_data};
                end
            end
            default:begin
            end
            endcase
            o_ribs_rsp<=1;
        end
        else begin
            tx_en <= 0;
            o_ribs_rsp <= 0;
        end
    end
end
assign o_ribs_gnt = i_ribs_req;



USART u_USART(
    .clk         ( i_clk         ),
    .rst_n       ( i_rstn       ),

    .rx_vld      ( rx_vld      ),//o
    .rx_data     ( rx_data     ),//o
    .rx_err      ( rx_err      ),//o
    .rxd         ( i_rx         ),//i


    .tx_rdy      ( tx_rdy      ),//o
    .tx_en       ( tx_en       ),//i
    .tx_data     ( tx_buffer     ),//i
    .txd         ( o_tx         )//o
);


    
endmodule