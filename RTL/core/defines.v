







//add x0,x0,0 == 空指令
`define inst_nop 32'h00000013

//32位指令开头
`define opc_type32        2'b11

//需要计算
//需要写rd
//alu_b位为imm
`define opc_lui         5'b01101 // rd = imm
`define opc_auipc       5'b00101 // rd = pc + imm
////////////////////////////////无条件跳转
`define opc_jal         5'b11011 // rd = pc + 4; pc += imm
`define opc_jalr        5'b11001 // rd = pc+4;pc= ( rs1 + imm ) & ~1;
/////////////////////////////////branch
`define opc_branch      5'b11000
`define func_beq        3'b000 // if(rs1 == rs2) pc += imm; => if(rs1-rs2=0) 
`define func_bne        3'b001 // if(rs1 != rs2) pc += imm; => if(rs1-rs2)
`define func_blt        3'b100 // if(rs1 < rs2)             => if(rs1 < rs2)
`define func_bge        3'b101 // if(rs1 >= rs2) pc += imm; => if(!(rs1 < rs2))
`define func_bltu       3'b110 // if(rs1 <u rs2)            => if(rs1 <u rs2)
`define func_bgeu       3'b111 // if(rs1 >=u rs2)           => if(!(rs1 <u rs2))
//////////////////////////////////load加载
`define opc_load        5'b00000
`define func_lb         3'b000
`define func_lh         3'b001
`define func_lw         3'b010
`define func_lbu        3'b100
`define func_lhu        3'b101
////////////////////////////////store储存
`define opc_store       5'b01000
`define func_sb         3'b000
`define func_sh         3'b001
`define func_sw         3'b010
///////////////////////////////imm立即数指令
`define opc_opimm       5'b00100
`define func_addi       3'b000
`define func_slti       3'b010
`define func_sltiu      3'b011
`define func_xori       3'b100
`define func_ori        3'b110
`define func_andi       3'b111
`define func_slli       3'b001
//特殊变种
`define func_srli_srai  3'b101
`define func7_srli      7'b0000000
`define func7_srai      7'b0100000
/////////////////////////////////op寄存器指令
`define opc_op          5'b01100
`define func_add_sub    3'b000
`define func7_add       7'b0000000
`define func7_sub       7'b0100000
`define func_sll        3'b001
`define func_slt        3'b010
`define func_sltu       3'b011
`define func_xor        3'b100
`define func_srl_sra    3'b101
`define func7_srl       7'b0000000
`define func7_sra       7'b0100000
`define func_or         3'b110
`define func_and        3'b111
//////////////////////////////////////fence
`define opc_fence       5'b00011
`define func_fence      3'b000
`define func_fencei     3'b001
/////////////////////////////////system系统指令
`define opc_system      5'b11100
`define func_ecall_ebreak 3'b000
`define func12_ecall    12'b000000000000
`define func12_ebreak   12'b000000000001
`define func_csrrw      3'b001 //rd = csr,csr = rs1
`define func_csrrs      3'b010 //rd = csr,csr = csr | rs1
`define func_csrrc      3'b011 //rd = csr,csr = csr & ~rs1
`define func_csrrwi     3'b101 //rd = csr,csr = zimm
`define func_csrrsi     3'b110 //rd = csr,csr = csr | zimm
`define func_csrrci     3'b111 //rd = csr,csr = csr & ~zimm,


//公共部分
`define decinfo_grp_alu 0
`define decinfo_grp_lsu 1
`define decinfo_grp_bju 2
`define decinfo_grp_mdu 3
`define decinfo_grp_scu 4
`define decinfo_grp_add 5 //加法操作作为公共计算部分
`define decinfo_grplen 6
`define decinfo_grplen_def 5:0

/***********************************************/
//alu计算选择
`define aluinfo_sub 1
`define aluinfo_sll 2
`define aluinfo_srl 3
`define aluinfo_sra 4
`define aluinfo_xor 5
`define aluinfo_and 6
`define aluinfo_or 7
`define aluinfo_slt 8
`define aluinfo_sltu 9
`define aluinfolen 10
/***********************************************/
//lsu访存选择,要用到加法
`define lsuinfo_wrcs 1
`define lsuinfo_opb 2 //字节
`define lsuinfo_oph 3 //半字
`define lsuinfo_opw 4 //字
`define lsuinfo_lu 5 //无符号拓展
`define lsuinfolen 6
/***********************************************/
//bju分支选择,要用到加法
`define bjuinfo_jal 1 //对于jal/jalr指令，需要将pc+4地址写入rd寄存器
`define bjuinfo_beq 2
`define bjuinfo_bne 3
`define bjuinfo_blt 4
`define bjuinfo_bge 5
`define bjuinfo_bltu 6
`define bjuinfo_bgeu 7
`define bjuinfo_bpu_bflag 8
`define bjuinfolen 9
/***********************************************/
//mdu乘除法选择
`define mduinfo_mul 1
`define mduinfo_mulh 2
`define mduinfo_mulhsu 3
`define mduinfo_mulhu 4
`define mduinfo_div 5
`define mduinfo_divu 6
`define mduinfo_rem 7
`define mduinfo_remu 8
`define mduinfolen 9
/***********************************************/
//scu系统控制
`define scuinfo_ecall 1
`define scuinfo_ebreak 2
`define scuinfo_csrrw 3
`define scuinfo_csrrs 4
`define scuinfo_csrrc 5
`define scuinfo_csrimm 6
`define scuinfo_csrwen 7
`define scuinfolen 8
/***********************************************/
//decinfo
`define decinfolen 10
`define decinfolen_def 9:0
