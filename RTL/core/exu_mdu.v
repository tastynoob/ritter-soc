




`include "config.v"
`include "defines.v"

/*
整数乘除法单元
*/


module EXU_MDU (
    input wire i_clk,
    input wire i_rstn,

    input wire i_vld,
    input wire i_flush,

    input wire[`decinfo_grplen_def] i_decinfo_grp,
    input wire[`decinfolen_def] i_mduinfo,
    input wire i_mdu_rdwen,//写使能
    input wire[`rfidxlen_def] i_mdu_rdidx,//需要写入寄存器
    input wire[`xlen_def] i_mdu_op1,//操作数1
    input wire[`xlen_def] i_mdu_op2,//操作数2


    output wire o_working,
    //给流水线控制模块的信号
    output wire o_will_rdwen,
    output wire[`rfidxlen_def] o_will_rdidx,

    //传递给写回模块
    output wire o_mdu_rdwen,
    output wire[`rfidxlen_def] o_mdu_rdidx,
    output wire[`xlen_def] o_mdu_rdwdata
);


    wire mdu_finish;
    
    //mduu控制逻辑
    //div_signed补充
    reg rem_op1_sym;//在rem有符号计算会出错,需要调整其符号,余数的符号只与被除数有关
    reg working;
    wire mdu_vld = i_decinfo_grp[`decinfo_grp_mdu] & (~o_working) & i_vld;
    reg rdwen;
    reg[`rfidxlen_def] rdidx;
    reg[`decinfolen_def] mduinfo;
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            rdwen<=0; 
            working<=0;
            rem_op1_sym<=0;
        end
        else if(mdu_vld) begin
            //读内存时,写寄存器
            rdwen   <= i_mdu_rdwen;//1为写
            rdidx   <= i_mdu_rdidx;
            working <= 1;
            mduinfo <= i_mduinfo;
            //记录被除数的正负号
            rem_op1_sym<=i_mdu_op1[`xlen-1];
        end
        else if(mdu_finish)begin
            rdwen<= 0;
            working<=0;
            rem_op1_sym<=0;
        end
        else if(i_flush)begin//写后写冲突,冲刷
            rdwen<=0;
        end
    end

    assign o_working = working & (~mdu_finish);

    assign o_will_rdwen = rdwen;
    assign o_will_rdidx = rdidx;


    //乘法计算
    //乘法消耗2个周期
    //除法消耗34个周期
    reg[7:0] cnt;//周期计数器
    reg mul_vld;
    reg[`xlen_def] op1;
    reg[`xlen_def] op2;
    reg mul_finish;
    wire[63:0] mul_ss = $signed(op1) * $signed(op2);//调用ip核
    wire[63:0] mul_uu = op1 * op2;
    wire[63:0] mul_su = $signed(op1) * $signed({1'b0,op2});
    wire mul_start = mdu_vld & 
    (i_mduinfo[`mduinfo_mul] | i_mduinfo[`mduinfo_mulh] | i_mduinfo[`mduinfo_mulhu] | i_mduinfo[`mduinfo_mulhsu]);
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            mul_vld<=0;
            cnt<=0;
            mul_finish<=0;
        end
        else if(mul_start) begin
            mul_vld<=1;
            op1<= i_mdu_op1;
            op2<= i_mdu_op2;
            cnt<=0;
            mul_finish<=0;
        end
        else if(mul_vld) begin
            if(cnt==1) begin
                mul_finish<=1;
                mul_vld<=0;
                cnt<=0;
            end
            else begin
                cnt<=cnt+1;
            end
        end
        else begin
            mul_finish<=0;
        end
    end


    wire div_signed_finish;
    wire[`xlen_def] div_signed_quo;
    wire[`xlen_def] div_signed_rem;
    wire div_signed_start = mdu_vld & (i_mduinfo[`mduinfo_div] | i_mduinfo[`mduinfo_rem]);
    DIV_SIGNED u_DIV_SIGNED(
        .clk    ( i_clk    ),
        .den    ( mdu_vld ?  i_mdu_op2 : 0   ),
        .num    ( mdu_vld ? i_mdu_op1  : 0  ),
        .rst    ( ~i_rstn    ),
        .start  ( div_signed_start  ),
        .finish ( div_signed_finish ),
        .quo    ( div_signed_quo    ),
        .rem    ( div_signed_rem    )
    );

    wire div_unsigned_finish;
    wire[`xlen_def] div_unsigned_quo;
    wire[`xlen_def] div_unsigned_rem;
    wire div_unsigned_start = mdu_vld & (i_mduinfo[`mduinfo_divu] | i_mduinfo[`mduinfo_remu]);
    DIV_UNSIGNED u_DIV_UNSIGNED(
        .clk    ( i_clk    ),
        .den    ( mdu_vld ?  i_mdu_op2 : 0    ),  //除数 分母
        .num    ( mdu_vld ? i_mdu_op1  : 0     ),  //除法 分子
        .rst    ( ~i_rstn    ),//高电平复位
        .start  ( div_unsigned_start  ),  //高电平开始
        .finish ( div_unsigned_finish ), //完成信号
        .quo    ( div_unsigned_quo    ), //商
        .rem    ( div_unsigned_rem    ) //余数
    );
    wire div_finish = div_unsigned_finish|div_signed_finish;
    assign mdu_finish = mul_finish|div_finish;

    assign o_mdu_rdwen =  mdu_finish & rdwen;
    assign o_mdu_rdidx = rdidx;

    assign o_mdu_rdwdata =  mduinfo[`mduinfo_mul] ? mul_ss[31:0] : 
                            mduinfo[`mduinfo_mulh] ? mul_ss[63:32] :
                            mduinfo[`mduinfo_mulhu] ? mul_uu[63:32] :
                            mduinfo[`mduinfo_mulhsu] ? mul_su[63:32] :
                            mduinfo[`mduinfo_div] ? div_signed_quo:
                            mduinfo[`mduinfo_divu] ? div_unsigned_quo:
                            mduinfo[`mduinfo_rem] ? (rem_op1_sym ? (-div_signed_rem) : div_signed_rem):
                            mduinfo[`mduinfo_remu] ? div_unsigned_rem:0;


    // assign o_mdu_rdwdata =  ({32{mduinfo[`mduinfo_mul]}}     & mul_ss[31:0])          |
    //                         ({32{mduinfo[`mduinfo_mulh]}}    & mul_ss[63:32])         |
    //                         ({32{mduinfo[`mduinfo_mulhu]}}   & mul_uu[63:32])         |
    //                         ({32{mduinfo[`mduinfo_mulhsu]}}  & mul_su[63:32])         |
    //                         ({32{mduinfo[`mduinfo_div]}}     & div_signed_quo)        |
    //                         ({32{mduinfo[`mduinfo_divu]}}    & div_unsigned_quo)        |
    //                         ({32{mduinfo[`mduinfo_rem]}}     & (rem_op1_sym ? (-div_signed_rem) : div_signed_rem)) |
    //                         ({32{mduinfo[`mduinfo_remu]}}    & div_unsigned_rem);
    
endmodule