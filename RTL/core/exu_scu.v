



`include "config.v"
`include "defines.v"


/*
系统控制单元
负责读写csr寄存器
包括中断管理


*/








module EXU_SCU (
    input wire i_clk,
    input wire i_rstn,

    input wire[`decinfo_grplen_def] i_decinfo_grp,
    input wire[`decinfolen_def] i_scuinfo,
    input wire[`xlen_def] i_scu_op1,

    input wire[`xlen_def] i_csr_rdata,
    input wire[`xlen_def] i_csr_zimm,
    

    //写回寄存器
    output wire o_scu_rdwen,
    output wire[`xlen_def] o_scu_wdata,

    //写回csr
    output wire o_csr_wen,
    output wire[`xlen_def] o_csr_wdata
);


    
    wire[`xlen_def] csr_rw = (i_scuinfo[`scuinfo_csrimm] ? i_csr_zimm : i_scu_op1);
    wire[`xlen_def] csr_rs = i_csr_rdata | (i_scuinfo[`scuinfo_csrimm] ? i_csr_zimm : i_scu_op1);
    wire[`xlen_def] csr_rc = i_csr_rdata & (~(i_scuinfo[`scuinfo_csrimm] ? i_csr_zimm : i_scu_op1)) ; 
    



    assign o_csr_wen =   i_decinfo_grp[`decinfo_grp_scu] & i_scuinfo[`scuinfo_csrwen];
    assign o_csr_wdata = (i_scuinfo[`scuinfo_csrrw] ? csr_rw : 0) |
                         (i_scuinfo[`scuinfo_csrrs] ? csr_rs : 0) |
                         (i_scuinfo[`scuinfo_csrrc] ? csr_rc : 0); 

    
    assign o_scu_rdwen = i_decinfo_grp[`decinfo_grp_scu] & i_decinfo_grp[`decinfo_grp_scu];
    assign o_scu_wdata = i_csr_rdata;

    
endmodule






