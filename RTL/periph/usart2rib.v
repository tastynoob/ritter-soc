

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
    output wire o_tx,
    input wire i_rx2,
    output wire o_tx2
);


reg[7:0] tx_buffer;
reg rx_vld;
wire[7:0] rx_data;
reg rx_err;
wire rx_vld_w;
wire rx_err_w;
wire tx_rdy;
reg tx_en;
//当第一次读取rx标志位时为高
//则需要等待rx标志位重新为低
reg has_rx;

//控制状态寄存器
//低3位分别是:串口读错误,串口读完成,串口发送完成
wire[31:0] usart_ctrl = {29'd0,rx_err_w && (has_rx==0),rx_vld_w&&(has_rx==0),tx_rdy};

////////////////////////////////////
reg[7:0] tx_buffer2;
reg rx_vld2;
wire[7:0] rx_data2;
reg rx_err2;
wire rx_vld2_w;
wire rx_err2_w;
wire tx_rdy2;
reg tx_en2;
//当第一次读取rx标志位时为高
//则需要等待rx标志位重新为低
reg has_rx2;

//控制状态寄存器
//低3位分别是:串口读错误,串口读完成,串口发送完成
wire[31:0] usart_ctrl2 = {29'd0,rx_err2_w && (has_rx2==0),rx_vld2_w&&(has_rx2==0),tx_rdy2};



///rib握手协议
wire handshake_rdy = i_ribs_req;
always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn)begin
        tx_en <= 0;
        o_ribs_rsp <= 0;
        rx_vld<=0;
        rx_err<=0;
        has_rx<=0;
        tx_buffer2<=0;
        tx_en2 <= 0;
        rx_vld2<=0;
        rx_err2<=0;
        has_rx2<=0;
    end
    else begin
        if(handshake_rdy)begin
            case(i_ribs_addr[15:0])
                16'h0000:begin//读控制寄存器
                    if(i_ribs_wrcs)begin//写无效

                    end
                    else begin//读
                        o_ribs_rdata <= usart_ctrl;
                        if((rx_vld_w || rx_err_w) && (has_rx == 0))begin
                            has_rx = 1;
                        end
                        else if(((rx_vld_w || rx_err_w)==0) && (has_rx == 1))begin
                            has_rx = 0;
                        end
                    end
                end
                16'h0004:begin//读写数据发送寄存器
                    //发送数据
                    if(i_ribs_wrcs)begin//写
                        tx_buffer <= i_ribs_wdata[7:0];
                        tx_en <= 1;
                    end
                    else begin//读
                        o_ribs_rdata <= {24'b0,tx_buffer};
                    end
                end
                16'h0008:begin//读数据接受寄存器(只读)
                    if(i_ribs_wrcs)begin//写无效
                        
                    end
                    else begin
                        o_ribs_rdata <= {24'b0,rx_data};
                    end
                end
                /////////////////////////////////////////////////串口2
                16'h0010:begin//读控制寄存器
                    if(i_ribs_wrcs)begin//写无效

                    end
                    else begin//读
                        o_ribs_rdata <= usart_ctrl2;
                        if((rx_vld2_w || rx_err2_w) && (has_rx2 == 0))begin
                            has_rx2 = 1;
                        end
                        else if(((rx_vld2_w || rx_err2_w)==0) && (has_rx2 == 1))begin
                            has_rx2 = 0;
                        end
                    end
                end
                16'h0014:begin//读写数据发送寄存器
                    //发送数据
                    if(i_ribs_wrcs)begin//写
                        tx_buffer2 <= i_ribs_wdata[7:0];
                        tx_en2 <= 1;
                    end
                    else begin//读
                        o_ribs_rdata <= {24'b0,tx_buffer2};
                    end
                end
                16'h0018:begin//读数据接受寄存器(只读)
                    if(i_ribs_wrcs)begin//写无效
                        
                    end
                    else begin
                        o_ribs_rdata <= {24'b0,rx_data2};
                    end
                end
            endcase
            o_ribs_rsp<=1;
        end
        else begin
            tx_en <= 0;
            tx_en2 <= 0;
            o_ribs_rsp <= 0;
        end
    end

end
assign o_ribs_gnt = i_ribs_req;



USART u_USART/* synthesis keep_hierarchy=true */
(
    .clk         ( i_clk         ),
    .rst_n       ( i_rstn       ),

    .rx_vld      ( rx_vld_w      ),//o
    .rx_data     ( rx_data     ),//o
    .rx_err      ( rx_err_w      ),//o
    .rxd         ( i_rx         ),//i


    .tx_rdy      ( tx_rdy      ),//o
    .tx_en       ( tx_en       ),//i
    .tx_data     ( tx_buffer     ),//i
    .txd         ( o_tx         )//o
);


USART u_USART2/* synthesis keep_hierarchy=true */
(
    .clk         ( i_clk         ),
    .rst_n       ( i_rstn       ),

    .rx_vld      ( rx_vld2_w      ),//o
    .rx_data     ( rx_data2     ),//o
    .rx_err      ( rx_err2_w      ),//o
    .rxd         ( i_rx2         ),//i


    .tx_rdy      ( tx_rdy2      ),//o  
    .tx_en       ( tx_en2       ),//i
    .tx_data     ( tx_buffer2     ),//i
    .txd         ( o_tx2         )//o
);


    
endmodule