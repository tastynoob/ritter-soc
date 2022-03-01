

`define   DATA_WIDTH                        32
`define   ADDR_WIDTH                        21
`define   DM_WIDTH                          4
`define   ROW_WIDTH                        11
`define   BA_WIDTH                        2

module SDRAM2RIB (
    input wire i_clk,
    input wire i_rstn,

	//RIB接口
    input wire[31:0] i_ribs_addr,//主地址线
    input wire i_ribs_wrcs,//读写选择
    input wire[3:0] i_ribs_mask, //掩码
    input wire[31:0] i_ribs_wdata, //写数据
    output wire[31:0] o_ribs_rdata,

    input wire i_ribs_req, 
    output wire o_ribs_gnt, 
    output wire o_ribs_rsp, 
    input wire i_ribs_rdy
);

wire  			SDRAM_CLK;
wire 			SDR_RAS;
wire  			SDR_CAS;
wire  			SDR_WE;
wire  [1:0]		SDR_BA; 
wire  [10:0]	SDR_ADDR;
wire  [31:0]	SDR_DQ ;
wire  [3:0]		SDR_DM; 

wire Sdr_init_done;
wire Sdr_init_ref_vld;
wire Sdr_busy;

wire sdr_read_finish;

wire handshake = i_ribs_req & o_ribs_gnt;
reg handshake_rdy;
always @(posedge i_clk or negedge i_rstn) begin
	if(~i_rstn)begin
		handshake_rdy <= 0;
	end
	else if(handshake & (i_ribs_wrcs==1)) begin//如果是写
		handshake_rdy<=1;
	end
	else begin
		handshake_rdy<=~o_ribs_rsp;
	end
end


assign o_ribs_rsp = (Sdr_init_done & (~(Sdr_init_ref_vld|Sdr_busy))) ?  handshake_rdy | sdr_read_finish : 0;
//当sdram处于刷新过程或者busy过程,需等待其结束
assign o_ribs_gnt = Sdr_init_ref_vld|Sdr_busy ? 0 : i_ribs_req;


sdr_as_ram #( 
.self_refresh_open(1'b1)
)u2_ram( 
	.Sdr_clk(i_clk),
	.Sdr_clk_sft(i_clk),
	.Rst(~i_rstn),
						
	.Sdr_init_done(Sdr_init_done),//o
	.Sdr_init_ref_vld(Sdr_init_ref_vld),//o
	.Sdr_busy(Sdr_busy),//o
	
	.App_ref_req(1'b0),
	
	.App_wr_en		( (i_ribs_req&(i_ribs_wrcs==1)) 	), //i
	.App_wr_addr	( i_ribs_addr[22:2] 			),  //i	
	.App_wr_dm		( i_ribs_mask 					),//i mask
	.App_wr_din		( i_ribs_wdata 					),//i

	.App_rd_en		( (i_ribs_req&(i_ribs_wrcs==0))	),//i
	.App_rd_addr	( i_ribs_addr[22:2]				),//i
	.Sdr_rd_en		( sdr_read_finish					),//o 该信号为高是才说明数据有效
	.Sdr_rd_dout	( o_ribs_rdata					),//o


	.SDRAM_CLK(SDRAM_CLK),
	.SDR_RAS(SDR_RAS),
	.SDR_CAS(SDR_CAS),
	.SDR_WE(SDR_WE),
	.SDR_BA(SDR_BA),
	.SDR_ADDR(SDR_ADDR),
	.SDR_DM(SDR_DM),
	.SDR_DQ(SDR_DQ)	
);


SDRAM sdram(
	.clk(SDRAM_CLK),
	.ras_n(SDR_RAS),
	.cas_n(SDR_CAS),
	.we_n(SDR_WE),
	.addr(SDR_ADDR[10:0]),
	.ba(SDR_BA),
	.dq(SDR_DQ),
	.cs_n(1'b0),
	.dm0(SDR_DM[0]),
	.dm1(SDR_DM[1]),
	.dm2(SDR_DM[2]),
	.dm3(SDR_DM[3]),
	.cke(1'b1)
);
endmodule



`ifdef SIMULATION


module SDRAM (
    clk,
    ras_n,
    cas_n,
    we_n,
    addr,
    ba,
    dq,
    cs_n,
    dm0,
    dm1,
    dm2,
    dm3,
    cke
);

input         clk;
input         ras_n;
input         cas_n;
input         we_n;
input  [10:0] addr;
input  [1:0]  ba;
inout  [31:0] dq;
input         cs_n; //DEFAULT := '0'
input         dm0; //DEFAULT := '0'
input         dm1; //DEFAULT := '0'
input         dm2; //DEFAULT := '0'
input         dm3; //DEFAULT := '0'
input         cke; //DEFAULT := '1'

endmodule

`endif




