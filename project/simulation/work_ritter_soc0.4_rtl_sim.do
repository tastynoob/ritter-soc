#
# Create work library
#
vlib work
#
# Compile sources
#
vlog  H:/AllProject/Tang/work-ritter_soc0.4/project/simulation/work_ritter_soc0.4_rtl_sim.v
vlog  H:/AllProject/Tang/work-ritter_soc0.4/simulation/tb.v
#
# Call vsim to invoke simulator
#
vsim -L H:/AllProject/Tang/work-ritter_soc0.4/work -gui -novopt work.TEST_TOP
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