#
# Create work library
#
vlib work
#
# Compile sources
#
vlog  H:/AllProject/Tang/work-ritter_soc0.4/simulation/tb.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/ritter_top.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/pipe_ctrl.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/ifu.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/ifu_bju.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/ifu_pc.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/ifu_fetch.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/fifos.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/ifu2bpu.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/bpu.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/bpu_ap.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/decode.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/bpu_bp.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/regfile.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/dispatch.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/exu.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/exu_alu.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/exu_bju.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/exu_mdu.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/exu_lsu.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/wb.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/RTL/core/rib.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/simulation/tb.v
#
# Call vsim to invoke simulator
#
vsim -L  -gui -novopt work.TEST_TOP
#
# Add waves
#
add wave *
#
# Run simulation
#
run 1000ns
#
# End