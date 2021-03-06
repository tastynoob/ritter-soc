







//地址: 0xf3

module PWM2RIB (
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

    output wire o_pwm
);

//ctrl:
//第一位是定时器使能位
reg[31:0] timer_ctrl;
//重装载器
reg[31:0] timer_reload;
//计数器
reg[31:0] timer_cnt;
//比较器
reg[31:0] timer_comp;

always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn)begin
        timer_ctrl<=32'h0;
        timer_comp<=32'h0;
        o_ribs_rsp<=1'b0;
    end
    else if(i_ribs_req) begin
        o_ribs_rsp <= 1'b1;
        if(i_ribs_wrcs)begin//写
            case(i_ribs_addr[15:0])
                16'h000:begin
                    //只写最后一位
                    timer_ctrl <= {31'b0,i_ribs_wdata[0]};
                end
                16'h004:begin//重装载值
                    timer_reload <= i_ribs_wdata;
                end
                16'h008:begin//比较器
                    timer_comp <= i_ribs_wdata;
                end
            endcase
        end
        else begin//读
            case(i_ribs_addr[15:0])
                16'h000:begin
                    //只读最后一位
                    o_ribs_rdata <= {31'b0,timer_ctrl[0]};
                end
                16'h004:begin//重装载值
                    o_ribs_rdata <= timer_reload;
                end
                16'h008:begin//比较器
                    o_ribs_rdata <= timer_comp;
                end
            endcase
        end
    end
    else begin
        o_ribs_rsp <= 1'b0;
    end
end


always @(posedge i_clk) begin
    //计数器
    if(timer_ctrl[0])begin//pwm使能
        if(timer_cnt > timer_reload)begin
            timer_cnt <=0;
        end
        else begin
            timer_cnt <= timer_cnt + 1;
        end
    end
end

assign o_ribs_gnt = i_ribs_req;

//当计数器的值小于比较器的值时,输出高电平
assign o_pwm = (timer_cnt < timer_comp) & timer_ctrl[0];

endmodule


