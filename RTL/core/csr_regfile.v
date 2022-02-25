
`include "config.v"
`include "defines.v"



/*
csr寄存器组主要实现中断功能
发生中断时,
暂停流水线,替换写回段的跳转地址,替换mepc

//注意:
csr寄存器组不做读写冲突检测


*/




module CSR_REGFILE (
    input wire i_clk,
    input wire i_rstn,

    //读端口
    input wire i_csr_ren,
    input wire[`csridxlen_def] i_csr_ridx,
    output wire[`xlen_def] o_csr_rdata,
    //写端口
    input wire i_csr_wen,
    input wire[`csridxlen_def] i_csr_widx,
    input wire[`xlen_def] i_csr_wdata
);




    /***************************************************/
    //机器状态寄存器:0x300
    //进入trap时,将[prvx,iex]向左移,退出trap时,将[prvx,iex]向右移
    wire[1:0] mtsatus_prv1 = 2'b11;
    reg mstatus_ie1;                
    wire[1:0] mstatus_prv = 2'b11;//2:1 硬件线程当前特权模式 默认为11机器模式
    reg mstatus_ie = 0;//0  全局中断使能位
    wire[`xlen_def] mstatus;
    

    /***************************************************/
    //机器中断使能寄存器:0x304
    reg mie_mtie = 0;//7 mip对应的使能位
    reg mie_htie = 0;//6
    reg mie_stie = 0;//5
    reg mie_msie = 0;//3
    reg mie_hsie = 0;//2
    reg mie_ssie = 0;//1
    wire[`xlen_def] mie;

    /***************************************************/
    //机器自陷向量基址寄存器:0x305
    reg[`xlen-1:2] mtvec_base = 0;
    reg[1:0] mtvec_mode = 0;//1:0
    wire[`xlen_def] mtvec = {mtvec_base,mtvec_mode};
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn) begin
            mtvec_base <= 0;
            mtvec_mode <= 0;
        end else begin
            if(i_csr_wen && i_csr_widx == `csridxlen'h305) begin
                {mtvec_base,mtvec_mode} <= i_csr_wdata;
            end
        end
    end





    


    

    /***************************************************/
    //机器异常程序计数器:0x341
    reg[`xlen_def] mepc;

    /***************************************************/
    //机器原因寄存器:0x342
    reg mcause_int=0;//xlen-1
    reg[`xlen-1-1:0] mcause_exc_code=0;//xlen-2:0
    wire[`xlen_def] mcause; 


    /***************************************************/
    //机器中断寄存器:0x344
    reg mip_meip = 0;//11 机器级外部中断挂起位
    reg mip_mtip = 0;//7 机器级定时器中断挂起位，只读，自动复位，通过写mtimecmp清除
    reg mip_msip = 0;//3 机器级软件触发中断,可写
    wire[`xlen_def] mip;




    /***************************************************/
    //下面是用户自定义的寄存器
    /***************************************************/
    //浮点运算寄存器
    //分为4个寄存器
    //fctrl:浮点计算控制寄存器 :0x310
    //facc:浮点累积运算寄存器:0x311
    //fop1:浮点运算操作数1:0x312
    //fop2:浮点运算操作数2:0x313
    /*
    功能描述:
    facc = (facc [运算1]) fop1 [运算2] fop2
    可完成基本的32位浮点运算
    还可实现类似累加乘操作"facc = facc + fop1+fop2"
    fctrl说明:
    fctrl[1:0] :控制 运算2的符号
    fctrl[4:2] :控制 运算1的符号
    000:加
    001:减
    010:乘
    011:除
    1xx:关闭运算符1
    */

    reg[31:0] fctrl;
    reg[31:0] fop1;
    reg[31:0] fop2;
    wire[`xlen_def] fres0_add;
    wire[`xlen_def] fres0_sub;
    wire[`xlen_def] fres0_mul;
    wire[`xlen_def] fres =  fctrl[1:0] ==0 ? fres0_add : 
                            fctrl[1:0] ==1 ? fres0_sub : 
                            fctrl[1:0] ==2 ? fres0_mul : 
                            0;
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn) begin
            fctrl <= 0;
            fop1 <= 0;
            fop2 <= 0;
        end else begin
            if(i_csr_wen & (i_csr_widx == `csridxlen'h310)) begin
                fctrl <= i_csr_wdata;
            end
            if(i_csr_wen & (i_csr_widx == `csridxlen'h312)) begin
                fop1 <= i_csr_wdata;
            end 
            if(i_csr_wen & (i_csr_widx == `csridxlen'h313)) begin
                fop2 <= i_csr_wdata;
            end
        end
    end


    FPU32 u_FPU1(
        .i_clk    ( i_clk    ),
        .i_rsn    ( i_rsn    ),
        .i_op1    ( fop1    ),
        .i_op2    ( fop2    ),
        .o_addres ( fres0_add ),
        .o_subres ( fres0_sub ),
        .o_mulres ( fres0_mul ),
        .o_divres (   )//浮点除法资源消耗太大 
    );


    assign o_csr_rdata = (~i_csr_ren) ? 0 :
                        (i_csr_ridx == 12'h300) ? mstatus :
                        (i_csr_ridx == 12'h304) ? mie :
                        (i_csr_ridx == 12'h305) ? mtvec :
                        (i_csr_ridx == 12'h341) ? mepc :
                        (i_csr_ridx == 12'h342) ? mcause :
                        (i_csr_ridx == 12'h344) ? mip :
                        //以下是自定义寄存器
                        (i_csr_ridx == 12'h310) ? {30'h0,fctrl[1:0]} :
                        (i_csr_ridx == 12'h311) ? fres :
                        (i_csr_ridx == 12'h312) ? fop1 :
                        (i_csr_ridx == 12'h313) ? fop2 :
                        0;
    
endmodule







































