
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
