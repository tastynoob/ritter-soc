// Verilog netlist created by TD v5.0.38657
// Tue Mar  1 15:05:40 2022

`timescale 1ns / 1ps
module SDRAM  // sdram.v(14)
  (
  addr,
  ba,
  cas_n,
  cke,
  clk,
  cs_n,
  dm0,
  dm1,
  dm2,
  dm3,
  ras_n,
  we_n,
  dq
  );

  input [10:0] addr;  // sdram.v(19)
  input [1:0] ba;  // sdram.v(20)
  input cas_n;  // sdram.v(17)
  input cke;  // sdram.v(27)
  input clk;  // sdram.v(15)
  input cs_n;  // sdram.v(22)
  input dm0;  // sdram.v(23)
  input dm1;  // sdram.v(24)
  input dm2;  // sdram.v(25)
  input dm3;  // sdram.v(26)
  input ras_n;  // sdram.v(16)
  input we_n;  // sdram.v(18)
  inout [31:0] dq;  // sdram.v(21)


  EG_PHY_CONFIG #(
    .DONE_PERSISTN("ENABLE"),
    .INIT_PERSISTN("ENABLE"),
    .JTAG_PERSISTN("DISABLE"),
    .PROGRAMN_PERSISTN("DISABLE"))
    config_inst ();
  EG_PHY_SDRAM_2M_32 sdram (
    .addr(addr),
    .ba(ba),
    .cas_n(cas_n),
    .cke(cke),
    .clk(clk),
    .cs_n(cs_n),
    .dm0(dm0),
    .dm1(dm1),
    .dm2(dm2),
    .dm3(dm3),
    .ras_n(ras_n),
    .we_n(we_n),
    .dq(dq));  // sdram.v(29)

endmodule 

