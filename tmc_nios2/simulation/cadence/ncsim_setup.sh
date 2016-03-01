
# (C) 2001-2016 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 15.1 193 linux 2016.03.01.13:02:16

# ----------------------------------------
# ncsim - auto-generated simulation script

# ----------------------------------------
# This script can be used to simulate the following IP:
#     tmc_nios2
# To create a top-level simulation script which compiles other
# IP, and manages other system issues, copy the following template
# and adapt it to your needs:
# 
# # Start of template
# # If the copied and modified template file is "ncsim.sh", run it as:
# #   ./ncsim.sh
# #
# # Do the file copy, dev_com and com steps
# source ncsim_setup.sh \
# SKIP_ELAB=1 \
# SKIP_SIM=1
# 
# # Compile the top level module
# ncvlog -sv "$QSYS_SIMDIR/../top.sv"
# 
# # Do the elaboration and sim steps
# # Override the top-level name
# # Override the user-defined sim options, so the simulation
# # runs forever (until $finish()).
# source ncsim_setup.sh \
# SKIP_FILE_COPY=1 \
# SKIP_DEV_COM=1 \
# SKIP_COM=1 \
# TOP_LEVEL_NAME=top \
# USER_DEFINED_SIM_OPTIONS=""
# # End of template
# ----------------------------------------
# If tmc_nios2 is one of several IP cores in your
# Quartus project, you can generate a simulation script
# suitable for inclusion in your top-level simulation
# script by running the following command line:
# 
# ip-setup-simulation --quartus-project=<quartus project>
# 
# ip-setup-simulation will discover the Altera IP
# within the Quartus project, and generate a unified
# script which supports all the Altera IP within the design.
# ----------------------------------------
# ACDS 15.1 193 linux 2016.03.01.13:02:16
# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="tmc_nios2"
QSYS_SIMDIR="./../"
QUARTUS_INSTALL_DIR="/home/tyler/altera_lite/15.1/quartus/"
SKIP_FILE_COPY=0
SKIP_DEV_COM=0
SKIP_COM=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="-input \"@run 100; exit\""

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_ELAB=1 SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# ----------------------------------------
# initialize simulation properties - DO NOT MODIFY!
ELAB_OPTIONS=""
SIM_OPTIONS=""
if [[ `ncsim -version` != *"ncsim(64)"* ]]; then
  :
else
  :
fi

# ----------------------------------------
# create compilation libraries
mkdir -p ./libraries/work/
mkdir -p ./libraries/error_adapter_0/
mkdir -p ./libraries/avalon_st_adapter/
mkdir -p ./libraries/rsp_mux_001/
mkdir -p ./libraries/rsp_mux/
mkdir -p ./libraries/rsp_demux_004/
mkdir -p ./libraries/rsp_demux/
mkdir -p ./libraries/cmd_mux_004/
mkdir -p ./libraries/cmd_mux/
mkdir -p ./libraries/cmd_demux_001/
mkdir -p ./libraries/cmd_demux/
mkdir -p ./libraries/router_006/
mkdir -p ./libraries/router_002/
mkdir -p ./libraries/router_001/
mkdir -p ./libraries/router/
mkdir -p ./libraries/jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo/
mkdir -p ./libraries/jtag_uart_0_avalon_jtag_slave_agent/
mkdir -p ./libraries/nios2_gen2_0_data_master_agent/
mkdir -p ./libraries/jtag_uart_0_avalon_jtag_slave_translator/
mkdir -p ./libraries/nios2_gen2_0_data_master_translator/
mkdir -p ./libraries/cpu/
mkdir -p ./libraries/rst_controller/
mkdir -p ./libraries/irq_mapper/
mkdir -p ./libraries/mm_interconnect_0/
mkdir -p ./libraries/uart_0/
mkdir -p ./libraries/timer_0/
mkdir -p ./libraries/sysid_qsys_0/
mkdir -p ./libraries/spi_0/
mkdir -p ./libraries/rx_fifo_read/
mkdir -p ./libraries/rx_fifo_empty/
mkdir -p ./libraries/pio_1/
mkdir -p ./libraries/pio_0/
mkdir -p ./libraries/onchip_memory2_0/
mkdir -p ./libraries/onchip_flash_0/
mkdir -p ./libraries/nios2_gen2_0/
mkdir -p ./libraries/jtag_uart_0/
mkdir -p ./libraries/i2c_opencores_0/
mkdir -p ./libraries/altera_ver/
mkdir -p ./libraries/lpm_ver/
mkdir -p ./libraries/sgate_ver/
mkdir -p ./libraries/altera_mf_ver/
mkdir -p ./libraries/altera_lnsim_ver/
mkdir -p ./libraries/fiftyfivenm_ver/

# ----------------------------------------
# copy RAM/ROM files to simulation directory
if [ $SKIP_FILE_COPY -eq 0 ]; then
  cp -f $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_b.hex ./
  cp -f $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_ociram_default_contents.dat ./
  cp -f $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_a.mif ./
  cp -f $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_ociram_default_contents.mif ./
  cp -f $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_b.mif ./
  cp -f $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_a.dat ./
  cp -f $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_ociram_default_contents.hex ./
  cp -f $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_a.hex ./
  cp -f $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_b.dat ./
fi

# ----------------------------------------
# compile device library files
if [ $SKIP_DEV_COM -eq 0 ]; then
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                -work altera_ver      
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                         -work lpm_ver         
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                            -work sgate_ver       
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                        -work altera_mf_ver   
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                    -work altera_lnsim_ver
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/fiftyfivenm_atoms.v"                -work fiftyfivenm_ver 
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/cadence/fiftyfivenm_atoms_ncrypt.v" -work fiftyfivenm_ver 
fi

# ----------------------------------------
# compile design files in correct order
if [ $SKIP_COM -eq 0 ]; then
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_avalon_st_adapter_error_adapter_0.sv" -work error_adapter_0                              -cdslib ./cds_libs/error_adapter_0.cds.lib                             
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_avalon_st_adapter.v"                  -work avalon_st_adapter                            -cdslib ./cds_libs/avalon_st_adapter.cds.lib                           
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                      -work rsp_mux_001                                  -cdslib ./cds_libs/rsp_mux_001.cds.lib                                 
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_rsp_mux_001.sv"                       -work rsp_mux_001                                  -cdslib ./cds_libs/rsp_mux_001.cds.lib                                 
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                      -work rsp_mux                                      -cdslib ./cds_libs/rsp_mux.cds.lib                                     
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_rsp_mux.sv"                           -work rsp_mux                                      -cdslib ./cds_libs/rsp_mux.cds.lib                                     
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_rsp_demux_004.sv"                     -work rsp_demux_004                                -cdslib ./cds_libs/rsp_demux_004.cds.lib                               
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_rsp_demux.sv"                         -work rsp_demux                                    -cdslib ./cds_libs/rsp_demux.cds.lib                                   
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                      -work cmd_mux_004                                  -cdslib ./cds_libs/cmd_mux_004.cds.lib                                 
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_cmd_mux_004.sv"                       -work cmd_mux_004                                  -cdslib ./cds_libs/cmd_mux_004.cds.lib                                 
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                      -work cmd_mux                                      -cdslib ./cds_libs/cmd_mux.cds.lib                                     
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_cmd_mux.sv"                           -work cmd_mux                                      -cdslib ./cds_libs/cmd_mux.cds.lib                                     
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_cmd_demux_001.sv"                     -work cmd_demux_001                                -cdslib ./cds_libs/cmd_demux_001.cds.lib                               
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_cmd_demux.sv"                         -work cmd_demux                                    -cdslib ./cds_libs/cmd_demux.cds.lib                                   
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_router_006.sv"                        -work router_006                                   -cdslib ./cds_libs/router_006.cds.lib                                  
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_router_002.sv"                        -work router_002                                   -cdslib ./cds_libs/router_002.cds.lib                                  
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_router_001.sv"                        -work router_001                                   -cdslib ./cds_libs/router_001.cds.lib                                  
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_router.sv"                            -work router                                       -cdslib ./cds_libs/router.cds.lib                                      
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/altera_avalon_sc_fifo.v"                                          -work jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo -cdslib ./cds_libs/jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo.cds.lib
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_merlin_slave_agent.sv"                                     -work jtag_uart_0_avalon_jtag_slave_agent          -cdslib ./cds_libs/jtag_uart_0_avalon_jtag_slave_agent.cds.lib         
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_merlin_burst_uncompressor.sv"                              -work jtag_uart_0_avalon_jtag_slave_agent          -cdslib ./cds_libs/jtag_uart_0_avalon_jtag_slave_agent.cds.lib         
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_merlin_master_agent.sv"                                    -work nios2_gen2_0_data_master_agent               -cdslib ./cds_libs/nios2_gen2_0_data_master_agent.cds.lib              
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_merlin_slave_translator.sv"                                -work jtag_uart_0_avalon_jtag_slave_translator     -cdslib ./cds_libs/jtag_uart_0_avalon_jtag_slave_translator.cds.lib    
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_merlin_master_translator.sv"                               -work nios2_gen2_0_data_master_translator          -cdslib ./cds_libs/nios2_gen2_0_data_master_translator.cds.lib         
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_debug_slave_wrapper.v"                 -work cpu                                          -cdslib ./cds_libs/cpu.cds.lib                                         
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_debug_slave_sysclk.v"                  -work cpu                                          -cdslib ./cds_libs/cpu.cds.lib                                         
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu.v"                                     -work cpu                                          -cdslib ./cds_libs/cpu.cds.lib                                         
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_test_bench.v"                          -work cpu                                          -cdslib ./cds_libs/cpu.cds.lib                                         
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_debug_slave_tck.v"                     -work cpu                                          -cdslib ./cds_libs/cpu.cds.lib                                         
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/altera_reset_controller.v"                                        -work rst_controller                               -cdslib ./cds_libs/rst_controller.cds.lib                              
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/altera_reset_synchronizer.v"                                      -work rst_controller                               -cdslib ./cds_libs/rst_controller.cds.lib                              
  ncvlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_irq_mapper.sv"                                          -work irq_mapper                                   -cdslib ./cds_libs/irq_mapper.cds.lib                                  
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0.v"                                    -work mm_interconnect_0                            -cdslib ./cds_libs/mm_interconnect_0.cds.lib                           
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_uart_0.v"                                               -work uart_0                                       -cdslib ./cds_libs/uart_0.cds.lib                                      
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_timer_0.v"                                              -work timer_0                                      -cdslib ./cds_libs/timer_0.cds.lib                                     
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_sysid_qsys_0.vo"                                        -work sysid_qsys_0                                 -cdslib ./cds_libs/sysid_qsys_0.cds.lib                                
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_spi_0.v"                                                -work spi_0                                        -cdslib ./cds_libs/spi_0.cds.lib                                       
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_rx_fifo_read.v"                                         -work rx_fifo_read                                 -cdslib ./cds_libs/rx_fifo_read.cds.lib                                
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_rx_fifo_empty.v"                                        -work rx_fifo_empty                                -cdslib ./cds_libs/rx_fifo_empty.cds.lib                               
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_pio_1.v"                                                -work pio_1                                        -cdslib ./cds_libs/pio_1.cds.lib                                       
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_pio_0.v"                                                -work pio_0                                        -cdslib ./cds_libs/pio_0.cds.lib                                       
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_onchip_memory2_0.v"                                     -work onchip_memory2_0                             -cdslib ./cds_libs/onchip_memory2_0.cds.lib                            
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/altera_onchip_flash_util.v"                                       -work onchip_flash_0                               -cdslib ./cds_libs/onchip_flash_0.cds.lib                              
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/altera_onchip_flash.v"                                            -work onchip_flash_0                               -cdslib ./cds_libs/onchip_flash_0.cds.lib                              
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/altera_onchip_flash_avmm_data_controller.v"                       -work onchip_flash_0                               -cdslib ./cds_libs/onchip_flash_0.cds.lib                              
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/altera_onchip_flash_avmm_csr_controller.v"                        -work onchip_flash_0                               -cdslib ./cds_libs/onchip_flash_0.cds.lib                              
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0.v"                                         -work nios2_gen2_0                                 -cdslib ./cds_libs/nios2_gen2_0.cds.lib                                
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/tmc_nios2_jtag_uart_0.v"                                          -work jtag_uart_0                                  -cdslib ./cds_libs/jtag_uart_0.cds.lib                                 
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/i2c_opencores.v"                                                  -work i2c_opencores_0                              -cdslib ./cds_libs/i2c_opencores_0.cds.lib                             
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/i2c_master_top.v"                                                 -work i2c_opencores_0                              -cdslib ./cds_libs/i2c_opencores_0.cds.lib                             
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/i2c_master_defines.v"                                             -work i2c_opencores_0                              -cdslib ./cds_libs/i2c_opencores_0.cds.lib                             
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/i2c_master_byte_ctrl.v"                                           -work i2c_opencores_0                              -cdslib ./cds_libs/i2c_opencores_0.cds.lib                             
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/i2c_master_bit_ctrl.v"                                            -work i2c_opencores_0                              -cdslib ./cds_libs/i2c_opencores_0.cds.lib                             
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/submodules/timescale.v"                                                      -work i2c_opencores_0                              -cdslib ./cds_libs/i2c_opencores_0.cds.lib                             
  ncvlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/tmc_nios2.v"                                                                                                                                                                                           
fi

# ----------------------------------------
# elaborate top level design
if [ $SKIP_ELAB -eq 0 ]; then
  ncelab -access +w+r+c -namemap_mixgen $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS $TOP_LEVEL_NAME
fi

# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  eval ncsim -licqueue $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS $TOP_LEVEL_NAME
fi
