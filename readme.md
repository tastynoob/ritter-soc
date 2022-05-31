# ritter-soc说明

## 介绍

### ritter-soc信息
ritter-soc是我从大一时期到大二时期花了半年时间自研出来的基于riscv指令集的处理器     
里面包括ritter-core以及总线和外设       
所有设计均采用verilog设计       
该项目使用sipeed公司的tang premier FPGA开发板上开发     
目前ritter-soc支持完整的riscv32IM指令集     
并在此基础上添加了简易的浮点加速单元(FPU)       
能够运行完整复杂的程序

### ritter-soc架构图 (仅作参考)
![0.png](https://s2.loli.net/2022/02/25/cmg9uCvsF3k8wBr.png)


### ritter-soc工作状态
工作频率:84MHZ      
外设:一个串口,一个计数器 (以后会慢慢更新)       
coremark跑分:       
![1.png](https://s2.loli.net/2022/03/03/b7jKDser5oBfO2l.png)


## 使用说明
使用安路(anlogic)公司提供的FPGA开发软件(TD，可在sipeed公司wiki中寻找)           
打开project文件夹下的work-ritter_soc1.0.al文件(TD工程文件)      
即可打开ritter-soc的工程项目        
## 烧录程序
详细请见isa目录下的说明     
### 注意事项
编译项目之前记得更改如下几个文件        
1.project/al_ip/bram_itcm.v:更改bram填充文件地址"INIT_FILE"     
2.查看defines.v和config.v，根据需要修改宏定义       
3.在进行仿真时,注意需要导入安路的硬件仿真库(位于TD软件安装目录下的sim_release)      

## 更新日志
22/5/31:工作时钟频率调整为80Mhz,添加额外的串口和gpio外设，添加bootloader固件，可实现串口烧录程序,
详细见isa/文件夹下      
22/3/3: 优化了指令执行时序,版本改为v1.3     
22/2/25:ritter-soc 1.0发布          
21/7/24:ritter-core 0.1发布(不推荐使用)         