#
# Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#
# Author: Mark Rollins

AIE_SIM_ONLY	  := false
SIM_FIFO          := false

MY_APP            := fft32_r2_app
MY_SOURCES        := {$MY_APP}.cpp fft32_r2_graph.h fft32_r2_kernel.h fft32_r2_kernel.cpp fft32_r2_twiddle.h

PLATFORM_USE      := xilinx_vck190_base_202410_1
PLATFORM          ?= ${PLATFORM_REPO_PATHS}/${PLATFORM_USE}/${PLATFORM_USE}.xpfm

CHECK_FIFO        := --aie.evaluate-fifo-depth --aie.Xrouter=disablePathBalancing

AIE_OUTPUT        := libadf.a

AIE_FLAGS         := ${MY_APP}.cpp --platform=${PLATFORM} --aie.output-archive=${AIE_OUTPUT}

ifeq (${SIM_FIFO}, true)
	AIE_FLAGS := ${AIE_FLAGS} ${CHECK_FIFO}
endif
ifeq (${AIE_SIM_ONLY},true)
	AIE_FLAGS := ${AIE_FLAGS} --aie.Xpreproc="-DAIE_SIM_ONLY"
endif

all: 	${AIE_OUTPUT} sim

${AIE_OUTPUT}:	 ${MUY_SOURCES}
	v++ --compile --config aie.cfg --mode aie --target=hw ${AIE_FLAGS} 2>&1| tee log

x86com:
	v++ --compile --config aie.cfg --mode aie --target=x86sim ${AIE_FLAGS} 2>&1| tee log

sim:
	aiesimulator 2>&1| tee -a log

x86sim:
	x86simulator 2>&1| tee -a log

trace:
	aiesimulator --online -wdb -text 2>&1| tee -a log

profile:
	aiesimulator --online -wdb -text --profile 2>&1| tee -a log


throughput:
	@../python/throughput.py aiesimulator_output/data/sig0_o.txt --iscomplex

loopII:
	@../python/get_loop_II.py Work/aie

clean:
	rm -rf Work Work* ${WORK_DIR}
	rm -rf .Xil
	rm -rf aiesimulator_output aiesimulator.log
	rm -rf x86simulator_output
	rm -rf log log* ${LOG_FILE}
	rm -rf libadf.a *.xpe *.elf *.db *.soln Map_* xnw* *.lp *.log .xil .Xil *.lp *.db *.log *.exe *.vcd *.json
	rm -rf vitis_analyzer* pl_sample_count* vitis_design_wrapper* function_wdb_dir* trdata.aiesim*
	rm -rf temp ISS_RPC_SERVER_PORT .crashReporter* .AIE_SIM_CMD_LINE_OPTIONS
	rm -rf system*.* trdata.aiesim function_wdb_dir

