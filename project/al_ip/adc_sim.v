// Verilog netlist created by TD v5.0.27252
// Tue Jul  4 09:19:16 2023

`timescale 1ns / 1ps
module adc  // adc.v(14)
  (
  clk,
  pd,
  s,
  soc,
  dout,
  eoc
  );

  input clk;  // adc.v(18)
  input pd;  // adc.v(19)
  input [2:0] s;  // adc.v(20)
  input soc;  // adc.v(21)
  output [11:0] dout;  // adc.v(16)
  output eoc;  // adc.v(15)


  EG_PHY_ADC #(
    .CH0("ENABLE"),
    .CH1("ENABLE"),
    .CH2("ENABLE"),
    .CH3("ENABLE"),
    .CH4("ENABLE"),
    .CH5("ENABLE"),
    .CH6("ENABLE"),
    .CH7("ENABLE"),
    .VREF("DISABLE"))
    adc (
    .clk(clk),
    .pd(pd),
    .s(s),
    .soc(soc),
    .dout(dout),
    .eoc(eoc));  // adc.v(32)
  EG_PHY_CONFIG #(
    .DONE_PERSISTN("ENABLE"),
    .INIT_PERSISTN("ENABLE"),
    .JTAG_PERSISTN("DISABLE"),
    .PROGRAMN_PERSISTN("DISABLE"))
    config_inst ();

endmodule 

