
# Create a library
vlib work


####################################Common cells include#####################################################################
vlog -sv \
+incdir+./vortex/third_party/cvfpu/src/common_cells/include \
+incdir+./vortex/third_party/cvfpu \
+incdir+./vortex/third_party/cvfpu/src/common_cells/include/common_cells \
+incdir+./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl \
+incdir+./vortex/hw \
+incdir+./vortex/hw/dpi \
+incdir+./vortex/hw/rtl \
+incdir+./vortex/hw/rtl/mem \
+incdir+./vortex/hw/rtl/libs \
+incdir+./vortex/hw/rtl/interfaces \
+incdir+./vortex/hw/rtl/fpu \
+incdir+./vortex/hw/rtl/core \
+incdir+./vortex/hw/rtl/cache \
+incdir+./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl \
./vortex/hw/rtl/VX_gpu_pkg.sv \
./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv \
./vortex/third_party/cvfpu/src/common_cells/src/cf_math_pkg.sv \
./vortex/third_party/cvfpu/src/common_cells/src/cb_filter_pkg.sv \
./vortex/third_party/cvfpu/src/fpnew_pkg.sv \
./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/control_mvp.sv \
./vortex/third_party/cvfpu/src/common_cells/include/common_cells/*.svh \
./vortex/third_party/cvfpu/src/common_cells/src/*.sv \
./vortex/third_party/cvfpu/src/common_cells/src/deprecated/*.sv \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/*.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl/*.v \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/*.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/clk/rtl/*.v \
./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/*.sv \
./vortex/third_party/cvfpu/src/*.sv \
./vortex/hw/rtl/*.sv \
./vortex/hw/dpi/*.vh \
./vortex/hw/rtl/fpu/VX_fpu_pkg.sv \
./vortex/hw/rtl/fpu/*.sv \
./vortex/hw/rtl/libs/*.sv \
./vortex/hw/rtl/*.sv \
./vortex/hw/rtl/*.vh \
./vortex/hw/rtl/mem/*.sv \
./vortex/hw/rtl/interfaces/*.sv \
./vortex/hw/rtl/fpu/*.vh \
./vortex/hw/rtl/core/*.sv \
./vortex/hw/rtl/cache/*.sv \
./vortex/hw/rtl/cache/*.vh \
axi_ram.v \
decode_mem.sv \
Vortex_tb.sv

################ to resolve include error in FPU unit #########################
#vlog -sv -work work -incdir "./vortex/third_party/cvfpu/src/common_cells/include" [glob *.sv]

################################################################################
# Load the testbench design

vsim -voptargs=+acc work.tb_vortex_axi

# Add all signals to the waveform window
#add wave -r /*
#add wave *

# Run the simulation
#run -all


#vsim -debugDB tb_vortex_axi
#view schematic


#./vortex/third_party/cvfpu/src/common_cells/include/common_cells/registers.svh