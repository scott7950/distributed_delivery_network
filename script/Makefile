
ifeq ($(GUI), 1)
    GUI_ARG = -gui
endif

ifeq ($(COV), 1)
    COV_COMPILE_ARG =  -cover sbceft 
    #COV_COMPILE_ARG =  -cover bcet 
    COV_RUN_ARG =  -coverage
endif

TESTNAME ?= uart_multiple_write_fifo_unicast_test

PROJECT_DIR = /mnt
RTL_DIR = $(PROJECT_DIR)/rtl
RTL = -f $(RTL_DIR)/file.lst

TB_DIR = $(PROJECT_DIR)/env
INCDIR = +incdir+$(TB_DIR)

UART_TB_DIR = $(TB_DIR)/uart_env
INCDIR += +incdir+$(UART_TB_DIR)

TEST_DIR = $(PROJECT_DIR)/test
TEST_FILE = $(TEST_DIR)/test.sv
INCDIR += +incdir+$(TEST_DIR)

SEQUENCE_DIR = $(TEST_DIR)/sequence
INCDIR += +incdir+$(SEQUENCE_DIR)

PACKET_SEQUENCE_DIR = $(SEQUENCE_DIR)/uart_sequence
INCDIR += +incdir+$(PACKET_SEQUENCE_DIR)

UVM_TB_TOP = $(TB_DIR)/top.sv

COMPILE_LOG_ARG = -l $(TESTNAME).sv.compile.log

WAVE_ARG = +define+WAVE_ON=1

UVM_COMPILE_ARG = +incdir+/mnt/uvm-1.2/src /mnt/uvm-1.2/src/uvm.sv

COMPILE_ARG = -sv -novopt
COMPILE_ARG += $(UVM_COMPILE_ARG) $(INCDIR) $(COMPILE_LOG_ARG) $(WAVE_ARG)

RUN_LOG_ARG = -l $(TESTNAME).run.log

SCRIPT_DIR = $(PROJECT_DIR)/script
RUN_TCL = $(SCRIPT_DIR)/do.tcl

RUN_ARG  = $(RUN_LOG_ARG) $(GUI_ARG) 
RUN_ARG += +UVM_TESTNAME=$(TESTNAME) +UVM_VERBOSITY=UVM_FULL -c -novopt -sv_lib lib/uvm_dpi work.top -do $(RUN_TCL) -wlf $(TESTNAME).wlf

SEED = 1

MIT_HOME = /home/tools/questasim/questasim/include
UVM_DPI_DIR = /mnt/uvm-1.2/src/dpi
UVM_DPI_FILE = /mnt/uvm-1.2/src/dpi/uvm_dpi.cc

UVM_DPI_COMPILE_ARG = -m32 -fPIC -DQUESTA -g -W -shared
UVM_DPI_COMPILE_ARG += -I$(MIT_HOME) -I$(UVM_DPI_DIR) $(UVM_DPI_FILE)

RTL_COMPILE_ARG = -novopt $(COV_COMPILE_ARG) -l $(TESTNAME).vhdl.compile.log

default: test 

test: lib/uvm_dpi.so compile run

run:
	vsim $(COV_RUN_ARG) $(RUN_ARG)

compile:
	if [ ! -d unisim ]; then vlib unisim; \
		vcom -work unisim ../xilinx_lib/unisims/unisim_VCOMP.vhd; \
		vcom -work unisim ../xilinx_lib/unisims/unisim_VPKG.vhd; \
		vcom -work unisim ../xilinx_lib/unisims/primitive/*.vhd; \
	fi;
	if [ ! -d work ]; then vlib work; fi;
	vcom $(RTL_COMPILE_ARG) $(RTL)
	vlog $(COMPILE_ARG) $(UVM_TB_TOP)

lib/uvm_dpi.so:
	if [ ! -d lib ]; then mkdir lib; fi
	g++ $(UVM_DPI_COMPILE_ARG) -o $@

clean:
	rm -rf simv simv.* *log

