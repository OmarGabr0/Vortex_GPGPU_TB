# VX_issue_slice

Each slice instantiates:

- [**VX_ibuffer**](../RTL/VX_ibuffer.md)
- [**VX_scoreboard**]()
- [**VX_operands**]()
- [**VX_dispatch**]()

```verilog
   VX_ibuffer_if ibuffer_if [PER_ISSUE_WARPS]();
   VX_scoreboard_if scoreboard_if();
   VX_operands_if operands_if();

   VX_ibuffer #(
      .INSTANCE_ID ($sformatf("%s-ibuffer", INSTANCE_ID))
   ) ibuffer (
      .clk            (clk),
      .reset          (reset),
   `ifdef PERF_ENABLE
      .perf_stalls    (issue_perf.ibf_stalls),
   `endif
      .decode_if      (decode_if),
      .ibuffer_if     (ibuffer_if)
   );

   VX_scoreboard #(
      .INSTANCE_ID ($sformatf("%s-scoreboard", INSTANCE_ID))
   ) scoreboard (
      .clk            (clk),
      .reset          (reset),
   `ifdef PERF_ENABLE
      .perf_stalls    (issue_perf.scb_stalls),
      .perf_units_uses(issue_perf.units_uses),
      .perf_sfu_uses  (issue_perf.sfu_uses),
   `endif
      .writeback_if   (writeback_if),
      .ibuffer_if     (ibuffer_if),
      .scoreboard_if  (scoreboard_if)
   );

   VX_operands #(
      .INSTANCE_ID ($sformatf("%s-operands", INSTANCE_ID))
   ) operands (
      .clk            (clk),
      .reset          (reset),
   `ifdef PERF_ENABLE
      .perf_stalls    (issue_perf.opd_stalls),
   `endif
      .writeback_if   (writeback_if),
      .scoreboard_if  (scoreboard_if),
      .operands_if    (operands_if)
   );

   VX_dispatch #(
      .INSTANCE_ID ($sformatf("%s-dispatch", INSTANCE_ID))
   ) dispatch (
      .clk            (clk),
      .reset          (reset),
   `ifdef PERF_ENABLE
      `UNUSED_PIN     (perf_stalls),
   `endif
      .operands_if    (operands_if),
      .dispatch_if    (dispatch_if)
   );
```