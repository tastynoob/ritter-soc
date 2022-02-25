





`include "config.v"
`include "defines.v"

/*
内存读写单元

内部采用2级流水线


//先只管4字节对齐的读写
*/




module EXU_LSU (
    input wire i_clk,
    input wire i_rstn,

    input wire i_vld,
    input wire i_flush,

    
    input wire[`decinfo_grplen_def] i_decinfo_grp,
    input wire[`decinfolen_def] i_lsuinfo,
    input wire i_lsu_rdwen,
    input wire[`rfidxlen_def] i_lsu_rdidx,//需要写入寄存器
    input wire[`xlen_def] i_lsu_rs2rdata,//需要写入内存的数据
    input wire[`xlen_def] i_lsu_addr,//alu计算的访存地址


    output wire o_working,

    //给流水线控制模块的信号
    output wire o_will_rdwen,
    output wire[`rfidxlen_def] o_will_rdidx,


    //传递给写回模块
    output wire o_lsu_rdwen,
    output wire[`rfidxlen_def] o_lsu_rdidx,
    output wire[`xlen_def] o_lsu_rdata,


    //连接RIB总线
    output reg[31:0] o_ribm_addr,
    output reg o_ribm_wrcs,//读写选择
    output reg[3:0] o_ribm_mask, //掩码
    output reg[31:0] o_ribm_wdata, //写数据
    input wire[31:0] i_ribm_rdata,

    output reg o_ribm_req, //发出请求
    input wire i_ribm_gnt, //总线授权
    input wire i_ribm_rsp, //响应有效
    output wire o_ribm_rdy
);

    //rib握手
    assign o_ribm_rdy = i_ribm_rsp;
    wire handshake_rdy = o_ribm_req & i_ribm_gnt;
    //访问成功
    wire access_rdy = i_ribm_rsp;
    reg handshake_rdy_last;//上次传输的握手状态
    //一个总线事务传输完成,上次握手成功&当前传输成功
    wire trans_finish = handshake_rdy_last & access_rdy;
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            handshake_rdy_last <= 0;
        end
        else begin
            //只有当访问成功或handshake_rdy_last为0时，才允许下一次的传输
            if(access_rdy | (~handshake_rdy_last))begin
                handshake_rdy_last <= handshake_rdy;
            end
        end
    end



    

    //lsu控制逻辑

    
    reg working;
    reg rdwen;
    reg[`rfidxlen_def] rdidx;
    reg[`decinfolen_def] lsuinfo;
    reg access2_vld;//二次访问
    reg access2_once;//二次访问第一次成功
    wire[1:0] align_mode = i_lsu_addr[1:0];
    reg[1:0] align_mode_reg;
    reg[`xlen_def] rs2rdata_reg;
    reg[`xlen_def] overleft_buffer;//剩余缓存
    wire lsu_vld = i_decinfo_grp[`decinfo_grp_lsu] & (~o_working) & i_vld;
    //lsu访存完成
    wire lsu_finish = (access2_vld ? access2_once : 1) & trans_finish;
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            rdwen<=0;
            working<=0;
            access2_vld<=0;
            access2_once<=0;
        end
        else if(lsu_vld) begin
            //读内存时,写寄存器
            rdwen   <= (~i_lsuinfo[`lsuinfo_wrcs]) & i_lsu_rdwen;//1为写
            rdidx   <= i_lsu_rdidx;
            working <= 1;
            
            //二次访问的跳转:读/写时
            //32位数据,mode!=00
            //16位数据,mode==11
            access2_vld <=  i_lsuinfo[`lsuinfo_opw] ? (align_mode != 3'b00) : 
                            i_lsuinfo[`lsuinfo_oph] ? (align_mode == 3'b11) : 0;

            align_mode_reg <= align_mode;//寄存
            rs2rdata_reg <= i_lsu_rs2rdata;//寄存
            lsuinfo <= i_lsuinfo;

            access2_once<=0;
        end
        else if(lsu_finish)begin
            rdwen<=0;
            working<=0;
            access2_vld<=0;
            access2_once<=0;
        end
        else if(access2_vld & trans_finish)begin
            overleft_buffer <= i_ribm_rdata;//记录第一次读内存结果
            access2_once<=1;///第一次访存成功,开始第二次访存

        end
        else if(i_flush)begin
            rdwen<=0;
        end
    end

    assign o_working = access2_vld ? (working&(~(trans_finish&access2_once))) : working&(~trans_finish);
    assign o_will_rdwen = rdwen;
    assign o_will_rdidx = rdidx;
    
    


    reg handshake_once;

    //发出请求
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            o_ribm_req<=0;
            handshake_once<=0;
        end
        else if(lsu_vld)begin


            o_ribm_req<=1;

            o_ribm_addr<=   {i_lsu_addr[31:2],2'b0};

            o_ribm_wrcs<=   i_lsuinfo[`lsuinfo_wrcs];
            //写掩码
            o_ribm_mask<=   i_lsuinfo[`lsuinfo_opw] ? (4'b1111 << align_mode) :
                            i_lsuinfo[`lsuinfo_oph] ? (4'b0011 << align_mode) :
                            i_lsuinfo[`lsuinfo_opb] ? (4'b0001 << align_mode) : 0;


            o_ribm_wdata<=  (i_lsu_rs2rdata << {align_mode,3'b000}) ;
                            
            handshake_once<=0;

        end
        else if((!handshake_once) & access2_vld & handshake_rdy)begin //第二次请求

            handshake_once<=1;
        
            o_ribm_req<=1;

            o_ribm_addr<=   {o_ribm_addr[31:2] + 1,2'b0};
            //没必要
            //o_ribm_wrcs<=   lsuinfo[`lsuinfo_wrcs];

            //二次访存的写掩码
            o_ribm_mask<=   lsuinfo[`lsuinfo_opw] ? {~(4'b1111 << align_mode_reg)} :
                            lsuinfo[`lsuinfo_oph] ? {~(4'b0011 << align_mode_reg)} :
                            0;

            o_ribm_wdata<= (rs2rdata_reg >> {4-align_mode_reg,3'b000}) ;

        end
        else if(handshake_rdy) begin//握手成功后撤销请求
            o_ribm_req<=0;
            handshake_once<=0;
        end
    end




    assign o_lsu_rdwen = (access2_vld ? access2_once : rdwen) & trans_finish;
    assign o_lsu_rdidx = rdidx;

    wire[`xlen*2 -1:0] access2_data = ({i_ribm_rdata,overleft_buffer} >> {align_mode_reg,3'b000}) ;
    wire[`xlen_def] access_data = (i_ribm_rdata >> {align_mode_reg,3'b000}) ;


    
    assign o_lsu_rdata = access2_vld ? 
                        (
                        lsuinfo[`lsuinfo_opw] ? access2_data[`xlen-1:0] ://二次访存的32位数据
                        lsuinfo[`lsuinfo_oph] ? {(lsuinfo[`lsuinfo_lu] ? 16'd0:{16{access2_data[15]}}),access2_data[15:0]} 
                        : 0
                        ) 
                        ://二次访存的16位数据
                        (
                        lsuinfo[`lsuinfo_oph] ? {(lsuinfo[`lsuinfo_lu] ? 16'd0:{16{access_data[15]}}),access_data[15:0]} : //一次访存的16位数据
                        lsuinfo[`lsuinfo_opb] ? {(lsuinfo[`lsuinfo_lu] ? 24'd0:{24{access_data[7]}}),access_data[7:0]} : //一次访存的8位数据
                        i_ribm_rdata
                        );//一次访存的32位数据



    // //此处改为并行逻辑
    // assign o_lsu_rdata = access2_vld ? 
    //                     (
    //                     ({32{lsuinfo[`lsuinfo_opw]}} & access2_data[`xlen-1:0]) |  //二次访存的32位数据
    //                     ({32{lsuinfo[`lsuinfo_oph]}} & {(lsuinfo[`lsuinfo_lu] ? 16'd0:{16{access2_data[15]}}),access2_data[15:0]})  //二次访存的16位数据
    //                     ) 
    //                     :
    //                     (
    //                     ({32{lsuinfo[`lsuinfo_opw]}} & access_data[`xlen-1:0]) |//一次访存的32位数据
    //                     ({32{lsuinfo[`lsuinfo_oph]}} & {(lsuinfo[`lsuinfo_lu] ? 16'd0:{16{access_data[15]}}),access_data[15:0]}) | //一次访存的16位数据
    //                     ({32{lsuinfo[`lsuinfo_opb]}} & {(lsuinfo[`lsuinfo_lu] ? 24'd0:{24{access_data[7]}}),access_data[7:0]})  //一次访存的8位数据
    //                     );//一次访存的32位数据


    
endmodule