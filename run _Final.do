
# Create a library
vlib work


####################################Common cells include#####################################################################
vlog -sv \
+incdir+./vortex/hw \                               
+incdir+./vortex/third_party/cvfpu/src/common_cells/include/common_cells \
+incdir+./vortex/third_party/cvfpu \
+incdir+./vortex/third_party/cvfpu/src/common_cells/include \
+incdir+./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl \
+incdir+./vortex/hw/dpi \
+incdir+./vortex/hw/rtl \
+incdir+./vortex/hw/rtl/mem \
+incdir+./vortex/hw/rtl/libs \
+incdir+./vortex/hw/rtl/interfaces \
+incdir+./vortex/hw/rtl/fpu \
+incdir+./vortex/hw/rtl/core \
+incdir+./vortex/hw/rtl/cache \
+incdir+./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl \
+incdir+./vortex/third_party/cvfpu/src/common_cells/include \
./vortex/hw/rtl/VX_platform.vh \
./vortex/hw/rtl/VX_scope.vh \
./vortex/hw/rtl/VX_define.vh \
./vortex/hw/rtl/VX_types.vh \
./vortex/hw/rtl/VX_config.vh \
./vortex/hw/rtl/cache/VX_cache_define.vh \
./vortex/hw/rtl/fpu/VX_fpu_define.vh \
./vortex/third_party/cvfpu/src/common_cells/include/common_cells/registers.svh \ 
./vortex/hw/rtl/libs/VX_allocator.sv \
./vortex/hw/rtl/core/VX_alu_dot8.sv \
./vortex/hw/rtl/core/VX_alu_int.sv \
./vortex/hw/rtl/core/VX_alu_muldiv.sv \
./vortex/hw/rtl/core/VX_alu_unit.sv \
./vortex/hw/rtl/libs/VX_axi_adapter.sv \
./vortex/hw/rtl/libs/VX_axi_write_ack.sv \
./vortex/hw/rtl/cache/VX_bank_flush.sv \
./vortex/hw/rtl/libs/VX_bits_insert.sv \
./vortex/hw/rtl/libs/VX_bits_remove.sv \
./vortex/hw/rtl/interfaces/VX_branch_ctl_if.sv \
./vortex/hw/rtl/VX_gpu_pkg.sv \
./vortex/hw/rtl/cache/VX_cache.sv \
./vortex/hw/rtl/cache/VX_cache_bank.sv \
./vortex/hw/rtl/cache/VX_cache_bypass.sv \
./vortex/hw/rtl/cache/VX_cache_cluster.sv \
./vortex/hw/rtl/cache/VX_cache_data.sv \
./vortex/hw/rtl/cache/VX_cache_flush.sv \
./vortex/hw/rtl/cache/VX_cache_mshr.sv \
./vortex/hw/rtl/cache/VX_cache_tags.sv \
./vortex/hw/rtl/cache/VX_cache_wrap.sv \
./vortex/hw/rtl/VX_cluster.sv \
./vortex/hw/rtl/core/VX_commit.sv \
./vortex/hw/rtl/interfaces/VX_commit_csr_if.sv \
./vortex/hw/rtl/interfaces/VX_commit_if.sv \
./vortex/hw/rtl/interfaces/VX_commit_sched_if.sv \
./vortex/hw/rtl/core/VX_core.sv \
./vortex/hw/rtl/fpu/VX_fpu_pkg.sv \
./vortex/hw/rtl/core/VX_csr_data.sv \
./vortex/hw/rtl/core/VX_csr_unit.sv \
./vortex/hw/rtl/libs/VX_cyclic_arbiter.sv \
./vortex/hw/rtl/interfaces/VX_dcr_bus_if.sv \
./vortex/hw/rtl/core/VX_dcr_data.sv \
./vortex/hw/rtl/core/VX_decode.sv \
./vortex/hw/rtl/interfaces/VX_decode_if.sv \
./vortex/hw/rtl/interfaces/VX_decode_sched_if.sv \
./vortex/hw/rtl/libs/VX_decoder.sv \
./vortex/hw/rtl/core/VX_dispatch.sv \
./vortex/hw/rtl/interfaces/VX_dispatch_if.sv \
./vortex/hw/rtl/core/VX_dispatch_unit.sv \
./vortex/hw/rtl/libs/VX_dp_ram.sv \
./vortex/hw/rtl/libs/VX_elastic_adapter.sv \
./vortex/hw/rtl/libs/VX_elastic_buffer.sv \
./vortex/hw/rtl/libs/VX_encoder.sv \
./vortex/hw/rtl/core/VX_execute.sv \
./vortex/hw/rtl/interfaces/VX_execute_if.sv \
./vortex/hw/rtl/core/VX_fetch.sv \
./vortex/hw/rtl/interfaces/VX_fetch_if.sv \
./vortex/hw/rtl/libs/VX_fifo_queue.sv \
./vortex/hw/rtl/libs/VX_find_first.sv \
./vortex/hw/rtl/fpu/VX_fpu_csr_if.sv \
./vortex/third_party/cvfpu/src/fpnew_pkg.sv \
./vortex/third_party/cvfpu/src/common_cells/src/cf_math_pkg.sv \
./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv \
./vortex/hw/rtl/fpu/VX_fpu_fpnew.sv \
./vortex/hw/rtl/core/VX_fpu_unit.sv \
./vortex/hw/rtl/core/VX_gather_unit.sv \
./vortex/hw/rtl/libs/VX_generic_arbiter.sv \
./vortex/hw/rtl/core/VX_ibuffer.sv \
./vortex/hw/rtl/interfaces/VX_ibuffer_if.sv \
./vortex/hw/rtl/libs/VX_index_buffer.sv \
./vortex/hw/rtl/core/VX_ipdom_stack.sv \
./vortex/hw/rtl/core/VX_issue.sv \
./vortex/hw/rtl/core/VX_issue_slice.sv \
./vortex/hw/rtl/mem/VX_lmem_switch.sv \
./vortex/hw/rtl/mem/VX_local_mem.sv \
./vortex/hw/rtl/mem/VX_lsu_adapter.sv \
./vortex/hw/rtl/mem/VX_lsu_mem_if.sv \
./vortex/hw/rtl/core/VX_lsu_slice.sv \
./vortex/hw/rtl/core/VX_lsu_unit.sv \
./vortex/hw/rtl/libs/VX_lzc.sv \
./vortex/hw/rtl/libs/VX_matrix_arbiter.sv \
./vortex/hw/rtl/libs/VX_mem_adapter.sv \
./vortex/hw/rtl/mem/VX_mem_arb.sv \
./vortex/hw/rtl/mem/VX_mem_bus_if.sv \
./vortex/hw/rtl/libs/VX_mem_coalescer.sv \
./vortex/hw/rtl/libs/VX_mem_scheduler.sv \
./vortex/hw/rtl/core/VX_mem_unit.sv \
./vortex/hw/rtl/libs/VX_multiplier.sv \
./vortex/hw/rtl/libs/VX_onehot_mux.sv \
./vortex/hw/rtl/core/VX_operands.sv \
./vortex/hw/rtl/interfaces/VX_operands_if.sv \
./vortex/hw/rtl/core/VX_pe_switch.sv \
./vortex/hw/rtl/libs/VX_pending_size.sv \
./vortex/hw/rtl/libs/VX_pipe_buffer.sv \
./vortex/hw/rtl/libs/VX_pipe_register.sv \
./vortex/hw/rtl/libs/VX_popcount.sv \
./vortex/hw/rtl/libs/VX_priority_arbiter.sv \
./vortex/hw/rtl/libs/VX_priority_encoder.sv \
./vortex/hw/rtl/libs/VX_reduce.sv \
./vortex/hw/rtl/libs/VX_reset_relay.sv \
./vortex/hw/rtl/libs/VX_rr_arbiter.sv \
./vortex/hw/rtl/libs/VX_scan.sv \
./vortex/hw/rtl/interfaces/VX_sched_csr_if.sv \
./vortex/hw/rtl/core/VX_schedule.sv \
./vortex/hw/rtl/interfaces/VX_schedule_if.sv \
./vortex/hw/rtl/core/VX_scoreboard.sv \
./vortex/hw/rtl/interfaces/VX_scoreboard_if.sv \
./vortex/hw/rtl/libs/VX_serial_div.sv \
./vortex/hw/rtl/core/VX_sfu_unit.sv \
./vortex/hw/rtl/libs/VX_shift_register.sv \
./vortex/hw/rtl/VX_socket.sv \
./vortex/hw/rtl/libs/VX_sp_ram.sv \
./vortex/hw/rtl/core/VX_split_join.sv \
./vortex/hw/rtl/libs/VX_stream_arb.sv \
./vortex/hw/rtl/libs/VX_stream_buffer.sv \
./vortex/hw/rtl/libs/VX_stream_pack.sv \
./vortex/hw/rtl/libs/VX_stream_switch.sv \
./vortex/hw/rtl/libs/VX_stream_unpack.sv \
./vortex/hw/rtl/libs/VX_stream_xbar.sv \
./vortex/hw/rtl/libs/VX_transpose.sv \
./vortex/hw/rtl/core/VX_uuid_gen.sv \
./vortex/hw/rtl/interfaces/VX_warp_ctl_if.sv \
./vortex/hw/rtl/core/VX_wctl_unit.sv \
./vortex/hw/rtl/interfaces/VX_writeback_if.sv \
./vortex/hw/rtl/vortex.sv \
./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/control_mvp.sv \
./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/div_sqrt_top_mvp.sv \
./vortex/third_party/cvfpu/src/fpnew_cast_multi.sv \
./vortex/third_party/cvfpu/src/fpnew_classifier.sv \
./vortex/third_party/cvfpu/src/fpnew_divsqrt_multi.sv \
./vortex/third_party/cvfpu/src/fpnew_divsqrt_th_32.sv \
./vortex/third_party/cvfpu/src/fpnew_divsqrt_th_64_multi.sv \
./vortex/third_party/cvfpu/src/fpnew_fma.sv \
./vortex/third_party/cvfpu/src/fpnew_fma_multi.sv \
./vortex/third_party/cvfpu/src/fpnew_noncomp.sv \
./vortex/third_party/cvfpu/src/fpnew_opgroup_block.sv \
./vortex/third_party/cvfpu/src/fpnew_opgroup_fmt_slice.sv \
./vortex/third_party/cvfpu/src/fpnew_opgroup_multifmt_slice.sv \
./vortex/third_party/cvfpu/src/fpnew_rounding.sv \
./vortex/third_party/cvfpu/src/fpnew_top.sv \
./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/iteration_div_sqrt_mvp.sv \
./vortex/third_party/cvfpu/src/common_cells/src/lzc.sv \
./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/norm_div_sqrt_mvp.sv \
./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/nrbd_nrsc_mvp.sv \
./vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl/preprocess_mvp.sv \
./vortex/third_party/cvfpu/src/common_cells/src/rr_arb_tree.sv \
./vortex/hw/rtl/vortex_axi.sv \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_ctrl.v \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_double.v \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_ff1.v \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_pack.v \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_prepare.v \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_round.v \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_scalar_dp.v \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_srt.v \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_srt_radix16_bound_table.v \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_srt_radix16_with_sqrt.v \
./vortex/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_top.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/clk/rtl/gated_clk_cell.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_ctrl.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_ff1.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_pack_single.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_prepare.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_round_single.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_special.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_srt_single.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_top.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl/pa_fpu_dp.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl/pa_fpu_frbus.v \
./vortex/third_party/cvfpu/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl/pa_fpu_src_type.v \
axi_ram.v \ 
decode_mem.sv \ 
vortex_tb.sv

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