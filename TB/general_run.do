
# Create a library
vlib work


####################################Common cells include#####################################################################
vlog -sv \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/common_cells/include/common_cells \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/dpi \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/mem \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/libs \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/interfaces \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/fpu \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/core \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/cache \
+incdir+C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/VX_gpu_pkg.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/common_cells/src/cf_math_pkg.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/common_cells/src/cb_filter_pkg.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/fpnew_pkg.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/control_mvp.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/common_cells/include/common_cells/*.svh \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/common_cells/src/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/common_cells/src/deprecated/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/*.v \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl/*.v \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/*.v \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/clk/rtl/*.v \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/dpi/*.vh \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/fpu/VX_fpu_pkg.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/fpu/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/libs/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/*.vh \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/mem/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/interfaces/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/fpu/*.vh \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/core/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/cache/*.sv \
C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/hw/rtl/cache/*.vh \
axi_ram.v \
decode_mem.sv \
Vortex_tb.sv

# Load the testbench design

vsim -voptargs=+acc work.tb_vortex_axi

# Add all signals to the waveform window
#add wave -r /*
#add wave *

# Run the simulation
#run -all


#vsim -debugDB tb_vortex_axi
#view schematic


#C:/GP_FPGA_RISC_NTT/update_Vortex_AXI/vortex/third_party/cvfpu/src/common_cells/include/common_cells/registers.svh