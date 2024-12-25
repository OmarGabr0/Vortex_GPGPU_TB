# VX_split_join

## Parameters

| Parameter        | Default Value | Description                                                    |
|------------------|---------------|----------------------------------------------------------------|
| `INSTANCE_ID`    | ""            | Unique identifier for the instance of the module.             |
| `NW_WIDTH`       | `32`          | Width of the warp identifier.                                 |
| `NUM_THREADS`    | `8`           | Number of threads in a warp.                                  |
| `PC_BITS`        | `32`          | Width of the program counter.                                 |
| `DV_STACK_SIZEW` | `5`           | Width of the stack pointer.                                   |
| `NUM_WARPS`      | `4`           | Number of warps supported in the system.                      |

## Code

```verilog
for (genvar i = 0; i < `NUM_WARPS; ++i) begin : g_ipdom_stacks
    VX_ipdom_stack #(
        .WIDTH (`NUM_THREADS + `PC_BITS),
        .DEPTH (`DV_STACK_SIZE),
        .OUT_REG (0)
    ) ipdom_stack (
        .clk   (clk),
        .reset (reset),
        .q0    (ipdom_q0),
        .q1    (ipdom_q1),
        .d     (ipdom_data[i]),
        .d_set (ipdom_set[i]),
        .q_ptr (ipdom_q_ptr[i]),
        .push  (ipdom_push && (i == wid)),
        .pop   (ipdom_pop && (i == wid)),
        `UNUSED_PIN (empty),
        `UNUSED_PIN (full)
    );
end
```

- `VX_ipdom_stack` is instantiated to manage data related to the split and join process for each warp.

```verilog
VX_pipe_register #(
    .DATAW  (1 + 1 + 1 + `NW_WIDTH + `NUM_THREADS + `PC_BITS),
    .DEPTH  (1),
    .RESETW (1)
) pipe_reg (
    .clk      (clk),
    .reset    (reset),
    .enable   (1'b1),
    .data_in  ({valid && sjoin.valid, sjoin_is_dvg, ipdom_set[wid], wid, ipdom_data[wid]}),
    .data_out ({join_valid, join_is_dvg, join_is_else, join_wid, {join_tmask, join_pc}})
);
```

- A basic buffer is instaitaed for the join signals.

```verilog
assign stack_ptr = ipdom_q_ptr[stack_wid];
```

- The stack pointer is assigned based on the warp identifier, which keeps track of the current warp state.
