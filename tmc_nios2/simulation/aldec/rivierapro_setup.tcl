
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
# Auto-generated simulation script rivierapro_setup.tcl
# ----------------------------------------
# This script can be used to simulate the following IP:
#     tmc_nios2
# To create a top-level simulation script which compiles other
# IP, and manages other system issues, copy the following template
# and adapt it to your needs:
# 
# # Start of template
# # If the copied and modified template file is "aldec.do", run it as:
# #   vsim -c -do aldec.do
# #
# # Source the generated sim script
# source rivierapro_setup.tcl
# # Compile eda/sim_lib contents first
# dev_com
# # Override the top-level name (so that elab is useful)
# set TOP_LEVEL_NAME top
# # Compile the standalone IP.
# com
# # Compile the user top-level
# vlog -sv2k5 ../../top.sv
# # Elaborate the design.
# elab
# # Run the simulation
# run
# # Report success to the shell
# exit -code 0
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

# ----------------------------------------
# Initialize variables
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
}

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "tmc_nios2"
}

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
}

if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "/home/tyler/altera_lite/15.1/quartus/"
}

if ![info exists USER_DEFINED_COMPILE_OPTIONS] { 
  set USER_DEFINED_COMPILE_OPTIONS ""
}
if ![info exists USER_DEFINED_ELAB_OPTIONS] { 
  set USER_DEFINED_ELAB_OPTIONS ""
}

# ----------------------------------------
# Initialize simulation properties - DO NOT MODIFY!
set ELAB_OPTIONS ""
set SIM_OPTIONS ""
if ![ string match "*-64 vsim*" [ vsim -version ] ] {
} else {
}

set Aldec "Riviera"
if { [ string match "*Active-HDL*" [ vsim -version ] ] } {
  set Aldec "Active"
}

if { [ string match "Active" $Aldec ] } {
  scripterconf -tcl
  createdesign "$TOP_LEVEL_NAME"  "."
  opendesign "$TOP_LEVEL_NAME"
}

# ----------------------------------------
# Copy ROM/RAM files to simulation directory
alias file_copy {
  echo "\[exec\] file_copy"
  file copy -force $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_b.hex ./
  file copy -force $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_ociram_default_contents.dat ./
  file copy -force $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_a.mif ./
  file copy -force $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_ociram_default_contents.mif ./
  file copy -force $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_b.mif ./
  file copy -force $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_a.dat ./
  file copy -force $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_ociram_default_contents.hex ./
  file copy -force $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_a.hex ./
  file copy -force $QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_rf_ram_b.dat ./
}

# ----------------------------------------
# Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib      ./libraries     
ensure_lib      ./libraries/work
vmap       work ./libraries/work
ensure_lib                  ./libraries/altera_ver      
vmap       altera_ver       ./libraries/altera_ver      
ensure_lib                  ./libraries/lpm_ver         
vmap       lpm_ver          ./libraries/lpm_ver         
ensure_lib                  ./libraries/sgate_ver       
vmap       sgate_ver        ./libraries/sgate_ver       
ensure_lib                  ./libraries/altera_mf_ver   
vmap       altera_mf_ver    ./libraries/altera_mf_ver   
ensure_lib                  ./libraries/altera_lnsim_ver
vmap       altera_lnsim_ver ./libraries/altera_lnsim_ver
ensure_lib                  ./libraries/fiftyfivenm_ver 
vmap       fiftyfivenm_ver  ./libraries/fiftyfivenm_ver 
ensure_lib                                              ./libraries/error_adapter_0                             
vmap       error_adapter_0                              ./libraries/error_adapter_0                             
ensure_lib                                              ./libraries/avalon_st_adapter                           
vmap       avalon_st_adapter                            ./libraries/avalon_st_adapter                           
ensure_lib                                              ./libraries/rsp_mux_001                                 
vmap       rsp_mux_001                                  ./libraries/rsp_mux_001                                 
ensure_lib                                              ./libraries/rsp_mux                                     
vmap       rsp_mux                                      ./libraries/rsp_mux                                     
ensure_lib                                              ./libraries/rsp_demux_004                               
vmap       rsp_demux_004                                ./libraries/rsp_demux_004                               
ensure_lib                                              ./libraries/rsp_demux                                   
vmap       rsp_demux                                    ./libraries/rsp_demux                                   
ensure_lib                                              ./libraries/cmd_mux_004                                 
vmap       cmd_mux_004                                  ./libraries/cmd_mux_004                                 
ensure_lib                                              ./libraries/cmd_mux                                     
vmap       cmd_mux                                      ./libraries/cmd_mux                                     
ensure_lib                                              ./libraries/cmd_demux_001                               
vmap       cmd_demux_001                                ./libraries/cmd_demux_001                               
ensure_lib                                              ./libraries/cmd_demux                                   
vmap       cmd_demux                                    ./libraries/cmd_demux                                   
ensure_lib                                              ./libraries/router_006                                  
vmap       router_006                                   ./libraries/router_006                                  
ensure_lib                                              ./libraries/router_002                                  
vmap       router_002                                   ./libraries/router_002                                  
ensure_lib                                              ./libraries/router_001                                  
vmap       router_001                                   ./libraries/router_001                                  
ensure_lib                                              ./libraries/router                                      
vmap       router                                       ./libraries/router                                      
ensure_lib                                              ./libraries/jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo
vmap       jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo ./libraries/jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo
ensure_lib                                              ./libraries/jtag_uart_0_avalon_jtag_slave_agent         
vmap       jtag_uart_0_avalon_jtag_slave_agent          ./libraries/jtag_uart_0_avalon_jtag_slave_agent         
ensure_lib                                              ./libraries/nios2_gen2_0_data_master_agent              
vmap       nios2_gen2_0_data_master_agent               ./libraries/nios2_gen2_0_data_master_agent              
ensure_lib                                              ./libraries/jtag_uart_0_avalon_jtag_slave_translator    
vmap       jtag_uart_0_avalon_jtag_slave_translator     ./libraries/jtag_uart_0_avalon_jtag_slave_translator    
ensure_lib                                              ./libraries/nios2_gen2_0_data_master_translator         
vmap       nios2_gen2_0_data_master_translator          ./libraries/nios2_gen2_0_data_master_translator         
ensure_lib                                              ./libraries/cpu                                         
vmap       cpu                                          ./libraries/cpu                                         
ensure_lib                                              ./libraries/rst_controller                              
vmap       rst_controller                               ./libraries/rst_controller                              
ensure_lib                                              ./libraries/irq_mapper                                  
vmap       irq_mapper                                   ./libraries/irq_mapper                                  
ensure_lib                                              ./libraries/mm_interconnect_0                           
vmap       mm_interconnect_0                            ./libraries/mm_interconnect_0                           
ensure_lib                                              ./libraries/uart_0                                      
vmap       uart_0                                       ./libraries/uart_0                                      
ensure_lib                                              ./libraries/timer_0                                     
vmap       timer_0                                      ./libraries/timer_0                                     
ensure_lib                                              ./libraries/sysid_qsys_0                                
vmap       sysid_qsys_0                                 ./libraries/sysid_qsys_0                                
ensure_lib                                              ./libraries/spi_0                                       
vmap       spi_0                                        ./libraries/spi_0                                       
ensure_lib                                              ./libraries/rx_fifo_read                                
vmap       rx_fifo_read                                 ./libraries/rx_fifo_read                                
ensure_lib                                              ./libraries/rx_fifo_empty                               
vmap       rx_fifo_empty                                ./libraries/rx_fifo_empty                               
ensure_lib                                              ./libraries/pio_1                                       
vmap       pio_1                                        ./libraries/pio_1                                       
ensure_lib                                              ./libraries/pio_0                                       
vmap       pio_0                                        ./libraries/pio_0                                       
ensure_lib                                              ./libraries/onchip_memory2_0                            
vmap       onchip_memory2_0                             ./libraries/onchip_memory2_0                            
ensure_lib                                              ./libraries/onchip_flash_0                              
vmap       onchip_flash_0                               ./libraries/onchip_flash_0                              
ensure_lib                                              ./libraries/nios2_gen2_0                                
vmap       nios2_gen2_0                                 ./libraries/nios2_gen2_0                                
ensure_lib                                              ./libraries/jtag_uart_0                                 
vmap       jtag_uart_0                                  ./libraries/jtag_uart_0                                 
ensure_lib                                              ./libraries/i2c_opencores_0                             
vmap       i2c_opencores_0                              ./libraries/i2c_opencores_0                             

# ----------------------------------------
# Compile device library files
alias dev_com {
  echo "\[exec\] dev_com"
  eval vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"              -work altera_ver      
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                       -work lpm_ver         
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                          -work sgate_ver       
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                      -work altera_mf_ver   
  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                  -work altera_lnsim_ver
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/fiftyfivenm_atoms.v"              -work fiftyfivenm_ver 
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/fiftyfivenm_atoms_ncrypt.v" -work fiftyfivenm_ver 
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  echo "\[exec\] com"
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_avalon_st_adapter_error_adapter_0.sv" -work error_adapter_0                             
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_avalon_st_adapter.v"                  -work avalon_st_adapter                           
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                      -work rsp_mux_001                                 
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_rsp_mux_001.sv"                       -work rsp_mux_001                                 
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                      -work rsp_mux                                     
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_rsp_mux.sv"                           -work rsp_mux                                     
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_rsp_demux_004.sv"                     -work rsp_demux_004                               
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_rsp_demux.sv"                         -work rsp_demux                                   
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                      -work cmd_mux_004                                 
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_cmd_mux_004.sv"                       -work cmd_mux_004                                 
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                      -work cmd_mux                                     
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_cmd_mux.sv"                           -work cmd_mux                                     
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_cmd_demux_001.sv"                     -work cmd_demux_001                               
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_cmd_demux.sv"                         -work cmd_demux                                   
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_router_006.sv"                        -work router_006                                  
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_router_002.sv"                        -work router_002                                  
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_router_001.sv"                        -work router_001                                  
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0_router.sv"                            -work router                                      
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_avalon_sc_fifo.v"                                          -work jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/altera_merlin_slave_agent.sv"                                     -work jtag_uart_0_avalon_jtag_slave_agent         
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/altera_merlin_burst_uncompressor.sv"                              -work jtag_uart_0_avalon_jtag_slave_agent         
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/altera_merlin_master_agent.sv"                                    -work nios2_gen2_0_data_master_agent              
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/altera_merlin_slave_translator.sv"                                -work jtag_uart_0_avalon_jtag_slave_translator    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/altera_merlin_master_translator.sv"                               -work nios2_gen2_0_data_master_translator         
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_debug_slave_wrapper.v"                 -work cpu                                         
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_debug_slave_sysclk.v"                  -work cpu                                         
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu.v"                                     -work cpu                                         
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_test_bench.v"                          -work cpu                                         
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0_cpu_debug_slave_tck.v"                     -work cpu                                         
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_reset_controller.v"                                        -work rst_controller                              
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_reset_synchronizer.v"                                      -work rst_controller                              
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/submodules/tmc_nios2_irq_mapper.sv"                                          -work irq_mapper                                  
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_mm_interconnect_0.v"                                    -work mm_interconnect_0                           
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_uart_0.v"                                               -work uart_0                                      
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_timer_0.v"                                              -work timer_0                                     
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_sysid_qsys_0.vo"                                        -work sysid_qsys_0                                
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_spi_0.v"                                                -work spi_0                                       
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_rx_fifo_read.v"                                         -work rx_fifo_read                                
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_rx_fifo_empty.v"                                        -work rx_fifo_empty                               
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_pio_1.v"                                                -work pio_1                                       
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_pio_0.v"                                                -work pio_0                                       
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_onchip_memory2_0.v"                                     -work onchip_memory2_0                            
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_onchip_flash_util.v"                                       -work onchip_flash_0                              
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_onchip_flash.v"                                            -work onchip_flash_0                              
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_onchip_flash_avmm_data_controller.v"                       -work onchip_flash_0                              
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/altera_onchip_flash_avmm_csr_controller.v"                        -work onchip_flash_0                              
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_nios2_gen2_0.v"                                         -work nios2_gen2_0                                
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/tmc_nios2_jtag_uart_0.v"                                          -work jtag_uart_0                                 
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/i2c_opencores.v"                                                  -work i2c_opencores_0                             
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/i2c_master_top.v"                                                 -work i2c_opencores_0                             
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/i2c_master_defines.v"                                             -work i2c_opencores_0                             
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/i2c_master_byte_ctrl.v"                                           -work i2c_opencores_0                             
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/i2c_master_bit_ctrl.v"                                            -work i2c_opencores_0                             
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/submodules/timescale.v"                                                      -work i2c_opencores_0                             
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/tmc_nios2.v"                                                                                                                   
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  echo "\[exec\] elab"
  eval vsim +access +r -t ps $ELAB_OPTIONS -L work -L error_adapter_0 -L avalon_st_adapter -L rsp_mux_001 -L rsp_mux -L rsp_demux_004 -L rsp_demux -L cmd_mux_004 -L cmd_mux -L cmd_demux_001 -L cmd_demux -L router_006 -L router_002 -L router_001 -L router -L jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo -L jtag_uart_0_avalon_jtag_slave_agent -L nios2_gen2_0_data_master_agent -L jtag_uart_0_avalon_jtag_slave_translator -L nios2_gen2_0_data_master_translator -L cpu -L rst_controller -L irq_mapper -L mm_interconnect_0 -L uart_0 -L timer_0 -L sysid_qsys_0 -L spi_0 -L rx_fifo_read -L rx_fifo_empty -L pio_1 -L pio_0 -L onchip_memory2_0 -L onchip_flash_0 -L nios2_gen2_0 -L jtag_uart_0 -L i2c_opencores_0 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Elaborate the top level design with -dbg -O2 option
alias elab_debug {
  echo "\[exec\] elab_debug"
  eval vsim -dbg -O2 +access +r -t ps $ELAB_OPTIONS -L work -L error_adapter_0 -L avalon_st_adapter -L rsp_mux_001 -L rsp_mux -L rsp_demux_004 -L rsp_demux -L cmd_mux_004 -L cmd_mux -L cmd_demux_001 -L cmd_demux -L router_006 -L router_002 -L router_001 -L router -L jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo -L jtag_uart_0_avalon_jtag_slave_agent -L nios2_gen2_0_data_master_agent -L jtag_uart_0_avalon_jtag_slave_translator -L nios2_gen2_0_data_master_translator -L cpu -L rst_controller -L irq_mapper -L mm_interconnect_0 -L uart_0 -L timer_0 -L sysid_qsys_0 -L spi_0 -L rx_fifo_read -L rx_fifo_empty -L pio_1 -L pio_0 -L onchip_memory2_0 -L onchip_flash_0 -L nios2_gen2_0 -L jtag_uart_0 -L i2c_opencores_0 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with -dbg -O2
alias ld_debug "
  dev_com
  com
  elab_debug
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "file_copy                     -- Copy ROM/RAM files to simulation directory"
  echo
  echo "dev_com                       -- Compile device library files"
  echo
  echo "com                           -- Compile the design files in correct order"
  echo
  echo "elab                          -- Elaborate top level design"
  echo
  echo "elab_debug                    -- Elaborate the top level design with -dbg -O2 option"
  echo
  echo "ld                            -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                      -- Compile all the design files and elaborate the top level design with -dbg -O2"
  echo
  echo 
  echo
  echo "List Of Variables"
  echo
  echo "TOP_LEVEL_NAME                -- Top level module name."
  echo "                                 For most designs, this should be overridden"
  echo "                                 to enable the elab/elab_debug aliases."
  echo
  echo "SYSTEM_INSTANCE_NAME          -- Instantiated system module name inside top level module."
  echo
  echo "QSYS_SIMDIR                   -- Qsys base simulation directory."
  echo
  echo "QUARTUS_INSTALL_DIR           -- Quartus installation directory."
  echo
  echo "USER_DEFINED_COMPILE_OPTIONS  -- User-defined compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_ELAB_OPTIONS     -- User-defined elaboration options, added to elab/elab_debug aliases."
}
file_copy
h
