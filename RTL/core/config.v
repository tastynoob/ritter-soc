
//当处于仿真模式时,开启下面的宏定义以取代bram的实现
//`define SIMULATION 


//是否使用FPU
`define HAS_FPU

//取指是否使用对齐处理器(可处理2字节对齐,不支持一字节对齐)
//但只支持32位指令的对齐
//`define USE_AP





//cpu位宽
`define xlen 32
`define xlen_def (32-1):0
//cpu指令位宽
`define ilen 32
`define ilen_def (32-1):0
//寄存器索引位宽
`define rfidxlen 5
`define rfidxlen_def (5-1):0

//csr寄存器索引
`define csridxlen 12
`define csridxlen_def 11:0

`define shamtlen 5
`define shamtlen_def 4:0

`define cpu_reset_addr 32'h00_00_00_00


//自陷向量表
`define trapveclen 8
`define trapveclen_def 7:0


`define itag_no1 4'b0001
`define itag_no2 4'b0010
`define itag_no3 4'b0100
`define itag_no4 4'b1000
