# VX_scoreboard

## Parameters

| Parameter                | Default Value                        | Description                                                                 |
|--------------------------|--------------------------------------|-----------------------------------------------------------------------------|
| `NUM_SRC_OPDS`  | 3 | rs1, rs2, rs3   |
| `NUM_OPDS`  | 4 | rs1, rs2, rs3, rd   |
| `DATAW`      | `UUID_WIDTH` + NUM_THREADS + `PC_BITS + 1` + EX_BITS + `INST_OP_BITS` + INST_ARGS_BITS + (`NR_BITS * 4) + 1                  | Data width   |
| [`PER_ISSUE_WARPS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_gpu_pkg.sv#L260)      | 8                   | Number of warps per slice |
| [`NR_BITS`](https://github.com/vortexgpgpu/vortex/blob/main/hw/rtl/VX_define.vh#L45)      | `CLOG2(NUM_REGS)`                   | Number of bits required to address all registers. |

```verilog
for (genvar w = 0; w < PER_ISSUE_WARPS; ++w) begin : g_stanging_bufs
    VX_pipe_buffer #(
        .DATAW (DATAW)
    ) stanging_buf (
        .clk      (clk),
        .reset    (reset),
        .valid_in (ibuffer_if[w].valid),
        .data_in  (ibuffer_if[w].data),
        .ready_in (ibuffer_if[w].ready),
        .valid_out(staging_if[w].valid),
        .data_out (staging_if[w].data),
        .ready_out(staging_if[w].ready)
    );
end
```

As stated in [VX_ibuffer](../RTL/VX_ibuffer.md), each warp within a slice has its own FIFO buffer. The data for each FIFO buffer is registered to a DQ flip-flop called the staging buffer.

```verilog
for (genvar w = 0; w < PER_ISSUE_WARPS; ++w) begin : g_scoreboard
    reg [`NUM_REGS-1:0] inuse_regs;

    reg [NUM_OPDS-1:0] operands_busy, operands_busy_n;

    wire ibuffer_fire = ibuffer_if[w].valid && ibuffer_if[w].ready;
    wire staging_fire = staging_if[w].valid && staging_if[w].ready;
    wire writeback_fire = writeback_if.valid
                        && (writeback_if.data.wis == ISSUE_WIS_W'(w))
                        && writeback_if.data.eop;

    wire [NUM_OPDS-1:0][`NR_BITS-1:0] ibuf_opds, stg_opds;
    assign ibuf_opds = {ibuffer_if[w].data.rs3, ibuffer_if[w].data.rs2, ibuffer_if[w].data.rs1, ibuffer_if[w].data.rd};
    assign stg_opds = {staging_if[w].data.rs3, staging_if[w].data.rs2, staging_if[w].data.rs1, staging_if[w].data.rd};
```

For each warp within a slice, we define the following signals:

- **`inuse_regs`**: A signal that indicates which registers are currently in use in the warp's register file.
- **`operands_busy`**: A signal that indicates which operands are currently busy.
- **`ibuffer_fire`**: A signal that indicates when the instruction buffer for the warp is ready to provide a valid instruction.
- **`staging_fire`**: A signal that indicates when the staging buffer for the warp is ready to accept a valid instruction.
- **`writeback_fire`**: A signal that indicates when a writeback operation has completed for a specific warp.
- **`ibuf_opds`** and **`stg_opds`**: Arrays that capture the operand registers for the instruction buffer and staging buffer, respectively. Each operand (e.g., `rs1`, `rs2`, `rs3`, `rd`) is extracted and concatenated into a vector to simplify further processing or checks within the scoreboard.

```verilog
always @(posedge clk) begin
    if (reset) begin
        inuse_regs <= '0;
    end else begin
        if (writeback_fire) begin
            inuse_regs[writeback_if.data.rd] <= 0;
        end
        if (staging_fire && staging_if[w].data.wb) begin
            inuse_regs[staging_if[w].data.rd] <= 1;
        end
    end
    operands_busy <= operands_busy_n;
    operands_ready[w] <= ~(|operands_busy_n);
end
```

- Only **`rd`** will update the **`inuse_regs`** register, which prevents RAW (Read-After-Write) and WAW (Write-After-Write) hazards.
- If the commit stage has already written to **`rd`** (**`writeback_fire` == 1**), that register is freed.
- If the new instruction in the staging buffer requires a writeback, we assert the corresponding register in **`inuse_regs`**.
- An instruction will only proceed if all of its operands are free (**`operands_ready`** is set when **`operands_busy_n`** equals zero).

```verilog
always @(*) begin
    for (integer i = 0; i < NUM_OPDS; ++i) begin
        operands_busy_n[i] = operands_busy[i];
        if (ibuffer_fire) begin
            operands_busy_n[i] = inuse_regs[ibuf_opds[i]];
        end
        if (writeback_fire) begin
            if (ibuffer_fire) begin
                if (writeback_if.data.rd == ibuf_opds[i]) begin
                    operands_busy_n[i] = 0;
                end
            end else begin
                if (writeback_if.data.rd == stg_opds[i]) begin
                    operands_busy_n[i] = 0;
                end
            end
        end
        if (staging_fire && staging_if[w].data.wb && staging_if[w].data.rd == ibuf_opds[i]) begin
            operands_busy_n[i] = 1;
        end
    end
end
```

We loop through each operand to update **`operands_busy_n`**:

- If there is a new instruction from the instruction buffer (**`ibuffer_fire` == 1**), we set the busy flag if it requests a register that is in use.
- If the writeback is completed for an instruction, we check if its **`rd`** matches either the new operands (**`ibuf_opds`**) or the old ones (**`stg_opds**), and deassert the busy flag for the operand using the same register.
- If the staging buffer’s **`rd`** matches any of the new instruction operands (**`ibuf_opds`**), the busy flag is asserted.

```verilog
wire [PER_ISSUE_WARPS-1:0] arb_valid_in;
wire [PER_ISSUE_WARPS-1:0][DATAW-1:0] arb_data_in;
wire [PER_ISSUE_WARPS-1:0] arb_ready_in;

for (genvar w = 0; w < PER_ISSUE_WARPS; ++w) begin : g_arb_data_in
    assign arb_valid_in[w] = staging_if[w].valid && operands_ready[w];
    assign arb_data_in[w] = staging_if[w].data;
    assign staging_if[w].ready = arb_ready_in[w] && operands_ready[w];
end
```

- If the operands are busy for an instruction, another instruction won’t be selected. The **`ready`** signal connected to the instruction buffer (**`staging_if[w].ready`**) is deasserted until the operands are ready. The pipeline is not stalled, as new instructions will continue to be written to the instruction buffer while waiting for operands to become free.

```verilog
VX_stream_arb #(
    .NUM_INPUTS (PER_ISSUE_WARPS),
    .DATAW      (DATAW),
    .ARBITER    ("C"),
    .OUT_BUF    (3)
) out_arb (
    .clk      (clk),
    .reset    (reset),
    .valid_in (arb_valid_in),
    .ready_in (arb_ready_in),
    .data_in  (arb_data_in),
    .data_out ({
        scoreboard_if.data.uuid,
        scoreboard_if.data.tmask,
        scoreboard_if.data.PC,
        scoreboard_if.data.ex_type,
        scoreboard_if.data.op_type,
        scoreboard_if.data.op_args,
        scoreboard_if.data.wb,
        scoreboard_if.data.rd,
        scoreboard_if.data.rs1,
        scoreboard_if.data.rs2,
        scoreboard_if.data.rs3
    }),
    .valid_out (scoreboard_if.valid),
    .ready_out (scoreboard_if.ready),
    .sel_out   (scoreboard_if.data.wis)
);
```

A cyclic arbiter is instantiated to prioritize and select one warp at a time in a round-robin manner when multiple warps are ready.
