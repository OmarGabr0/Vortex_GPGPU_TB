# VX_dispatch

```verilog
wire [`NT_WIDTH-1:0] last_active_tid;

VX_find_first #(
    .N (`NUM_THREADS),
    .DATAW (`NT_WIDTH),
    .REVERSE (1)
) last_tid_select (
    .valid_in (operands_if.data.tmask),
    .data_in  (tids),
    .data_out (last_active_tid),
    `UNUSED_PIN (valid_out)
);
```

- **Last Active Thread Selection**: Identifies the highest-index active thread (`last_active_tid`) from the thread mask (`operands_if.data.tmask`) using the `VX_find_first` module.

```verilog
wire [`NUM_EX_UNITS-1:0] operands_ready_in;
assign operands_if.ready = operands_ready_in[operands_if.data.ex_type];

for (genvar i = 0; i < `NUM_EX_UNITS; ++i) begin : g_buffers
    VX_elastic_buffer #(
        .DATAW   (DATAW),
        .SIZE    (2),
        .OUT_REG (1)
    ) buffer (
        .clk        (clk),
        .reset      (reset),
        .valid_in   (operands_if.valid && (operands_if.data.ex_type == `EX_BITS'(i))),
        .ready_in   (operands_ready_in[i]),
        .data_in    ({
            operands_if.data.uuid,
            operands_if.data.wis,
            operands_if.data.tmask,
            operands_if.data.PC,
            operands_if.data.op_type,
            operands_if.data.op_args,
            operands_if.data.wb,
            operands_if.data.rd,
            last_active_tid,
            operands_if.data.rs1_data,
            operands_if.data.rs2_data,
            operands_if.data.rs3_data
        }),
        .data_out   (dispatch_if[i].data),
        .valid_out  (dispatch_if[i].valid),
        .ready_out  (dispatch_if[i].ready)
    );
end
```

- **Operand Readiness Mapping**: The `operands_if.ready` signal is driven by the `ready` signal from the buffer corresponding to the current execution type (`operands_if.data.ex_type`).

- **Data Buffering**: For each execution unit, a `VX_elastic_buffer` is instantiated to store operand data, including metadata like UUID, thread mask, and operand values, while managing the valid-ready handshake signals for dispatch.
