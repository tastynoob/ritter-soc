# See LICENSE for license details.

#*****************************************************************************
# lw.S
#-----------------------------------------------------------------------------
#
# Test lw instruction.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64U
RVTEST_CODE_BEGIN
T:
lw x2,0(x0)
li x3,1
call T






RVTEST_DATA_END