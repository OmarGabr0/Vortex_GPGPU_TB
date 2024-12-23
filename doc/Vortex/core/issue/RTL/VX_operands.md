# VX_operands

## Parameters

| Name                    | Value                                             |
|-------------------------|---------------------------------------------------|
| `NUM_BANKS`             | 4                                                 |
| `OUT_BUF`               | 3                                                 |
| `NUM_SRC_OPDS`          | 3                                                 |
| `REQ_SEL_BITS`          | `CLOG2(NUM_SRC_OPDS)`                             |
| `REQ_SEL_WIDTH`         | `UP(REQ_SEL_BITS)`                                |
| `BANK_SEL_BITS`         | `CLOG2(NUM_BANKS)`                                |
| `BANK_SEL_WIDTH`        | `UP(BANK_SEL_BITS)`                               |
| `PER_BANK_REGS`         | `NUM_REGS / NUM_BANKS`                           |
| `META_DATAW`            | `ISSUE_WIS_W + NUM_THREADS + PC_BITS + 1 + EX_BITS + INST_OP_BITS + INST_ARGS_BITS + NR_BITS + UUID_WIDTH` |
| `REGS_DATAW`            | `XLEN * NUM_THREADS`                             |
| `DATAW`                 | `META_DATAW + NUM_SRC_OPDS * REGS_DATAW`         |
| `RAM_ADDRW`             | `LOG2UP(NUM_REGS * PER_ISSUE_WARPS)`             |
| `PER_BANK_ADDRW`        | `RAM_ADDRW - BANK_SEL_BITS`                      |
| `XLEN_SIZE`             | `XLEN / 8`                                       |
| `BYTEENW`               | `NUM_THREADS * XLEN_SIZE`                        |

```verilog
wire [NUM_SRC_OPDS-1:0][`NR_BITS-1:0] src_opds;
assign src_opds = {scoreboard_if.data.rs3, scoreboard_if.data.rs2, scoreboard_if.data.rs1};
```

A 2D array, where each row is a source operand register number.

```verilog
wire [NUM_SRC_OPDS-1:0][PER_BANK_ADDRW-1:0] req_data_in;
for (genvar i = 0; i < NUM_SRC_OPDS; ++i) begin : g_req_data_in
   if (ISSUE_WIS != 0) begin : g_wis
      assign req_data_in[i] = {src_opds[i][`NR_BITS-1:BANK_SEL_BITS], scoreboard_if.data.wis};
   end else begin : g_no_wis
      assign req_data_in[i] = src_opds[i][`NR_BITS-1:BANK_SEL_BITS];
   end
end
```

`req_data_in` is the address of the register in the bank.

```verilog
wire [NUM_SRC_OPDS-1:0][BANK_SEL_WIDTH-1:0] req_bank_idx;
for (genvar i = 0; i < NUM_SRC_OPDS; ++i) begin : g_req_bank_idx
   if (NUM_BANKS != 1) begin : g_multibanks
      assign req_bank_idx[i] = src_opds[i][BANK_SEL_BITS-1:0];
   end else begin : g_singlebank
      assign req_bank_idx[i] = '0;
   end
end
```

`req_bank_idx` selects the bank.

```verilog
reg [NUM_SRC_OPDS-1:0] data_fetched_st1;
wire [NUM_SRC_OPDS-1:0] req_valid_in, req_ready_in;
for (genvar i = 0; i < NUM_SRC_OPDS; ++i) begin : g_src_valid
   assign src_valid[i] = (src_opds[i] != 0) && ~data_fetched_st1[i];
end

assign req_valid_in = {NUM_SRC_OPDS{scoreboard_if.valid}} & src_valid;

always @(posedge clk) begin
   if (reset || scoreboard_if.ready) begin
      data_fetched_st1 <= 0;
   end else begin
      data_fetched_st1 <= data_fetched_st1 | req_fire_in;
   end
end
```

`req_valid_in` indicates the request is valid if it was not fetched already.

```verilog
wire [NUM_SRC_OPDS-1:0] req_fire_in = req_valid_in & req_ready_in;
```

`req_fire_in` is only fired when the banks are ready and the request is valid.

```verilog
VX_stream_xbar #(
   .NUM_INPUTS  (NUM_SRC_OPDS),
   .NUM_OUTPUTS (NUM_BANKS),
   .DATAW       (PER_BANK_ADDRW),
   .ARBITER     ("P"), // use priority arbiter
   .PERF_CTR_BITS(`PERF_CTR_BITS),
   .OUT_BUF     (0) // no output buffering
) req_xbar (
   .clk       (clk),
   .reset     (reset),
   `UNUSED_PIN(collisions),
   .valid_in  (req_valid_in),
   .data_in   (req_data_in),
   .sel_in    (req_bank_idx),
   .ready_in  (req_ready_in),
   .valid_out (gpr_rd_valid),
   .data_out  (gpr_rd_addr),
   .sel_out   (gpr_rd_req_idx),
   .ready_out (gpr_rd_ready)
);
```

A stream crossbar is instantiated to connect every operand to every bank, where it outputs the general purpose registers read address.

```verilog
reg has_collision_n;
always @(*) begin
   has_collision_n = 0;
   for (integer i = 0; i < NUM_SRC_OPDS; ++i) begin
      for (integer j = 1; j < (NUM_SRC_OPDS-i); ++j) begin
            has_collision_n |= src_valid[i]
                           && src_valid[j+i]
                           && (req_bank_idx[i] == req_bank_idx[j+i]);
      end
   end
end
```

A collision occurs when two or more source operands simultaneously request access to the same bank.

## Operand Collector Pipeline

The operand collector implements a pipeline for accessing the general purpose registers in the register file, where every bank is a dual port ram and has multiple registers.

```verilog
wire pipe_ready_in;
assign scoreboard_if.ready = pipe_ready_in && ~has_collision_n;
```

The operand collector is only ready if there was no collisions and the pipeline is ready to receive data.

### Stage 1

```verilog
wire [NUM_BANKS-1:0] gpr_rd_valid, gpr_rd_ready;
wire [NUM_BANKS-1:0] gpr_rd_valid_st1, gpr_rd_valid_st2;
wire [NUM_BANKS-1:0][PER_BANK_ADDRW-1:0] gpr_rd_addr, gpr_rd_addr_st1;
wire [NUM_BANKS-1:0][`NUM_THREADS-1:0][`XLEN-1:0] gpr_rd_data_st2;
wire [NUM_BANKS-1:0][REQ_SEL_WIDTH-1:0] gpr_rd_req_idx, gpr_rd_req_idx_st1, gpr_rd_req_idx_st2;
wire pipe_fire_st1 = pipe_valid_st1 && pipe_ready_st1;

assign pipe_data = {
   scoreboard_if.data.wis,
   scoreboard_if.data.tmask,
   scoreboard_if.data.PC,
   scoreboard_if.data.wb,
   scoreboard_if.data.ex_type,
   scoreboard_if.data.op_type,
   scoreboard_if.data.op_args,
   scoreboard_if.data.rd,
   scoreboard_if.data.uuid
};
   VX_pipe_buffer #(
   .DATAW (NUM_BANKS + META_DATAW + 1 + NUM_BANKS * (PER_BANK_ADDRW + REQ_SEL_WIDTH))
) pipe_reg1 (
   .clk      (clk),
   .reset    (reset),
   .valid_in (scoreboard_if.valid),
   .ready_in (pipe_ready_in),
   .data_in  ({gpr_rd_valid,     pipe_data,     has_collision_n,   gpr_rd_addr,     gpr_rd_req_idx}),
   .data_out ({gpr_rd_valid_st1, pipe_data_st1, has_collision_st1, gpr_rd_addr_st1, gpr_rd_req_idx_st1}),
   .valid_out(pipe_valid_st1),
   .ready_out(pipe_ready_st1)
);
```

`gpr_rd_addr_st1` is the read address for the dual-port ram.

### Stage 2

```verilog
reg [NUM_SRC_OPDS-1:0][(`NUM_THREADS * `XLEN)-1:0] src_data_st2, src_data_m_st2;

VX_pipe_buffer #(
   .DATAW (NUM_BANKS + META_DATAW + NUM_BANKS * REQ_SEL_WIDTH)
) pipe_reg2 (
   .clk      (clk),
   .reset    (reset),
   .valid_in (pipe_valid2_st1),
   .ready_in (pipe_ready_st1),
   .data_in  ({gpr_rd_valid_st1, pipe_data_st1, gpr_rd_req_idx_st1}),
   .data_out ({gpr_rd_valid_st2, pipe_data_st2, gpr_rd_req_idx_st2}),
   .valid_out(pipe_valid_st2),
   .ready_out(pipe_ready_st2)
);

always @(*) begin
   src_data_m_st2 = src_data_st2;
   for (integer b = 0; b < NUM_BANKS; ++b) begin
      if (gpr_rd_valid_st2[b]) begin
            src_data_m_st2[gpr_rd_req_idx_st2[b]] = gpr_rd_data_st2[b];
      end
   end
end

always @(posedge clk) begin
   if (reset || pipe_fire_st2) begin
      src_data_st2 <= 0;
   end else begin
      src_data_st2 <= src_data_m_st2;
   end
end
```

In the second stage, each bank responds with the read data for all the threads of each source operand (`gpr_rd_data_st2`) and we update the corresponding `src_data_m_st2`.

### Stage 3

```verilog
VX_elastic_buffer #(
   .DATAW   (DATAW),
   .SIZE    (`TO_OUT_BUF_SIZE(OUT_BUF)),
   .OUT_REG (`TO_OUT_BUF_REG(OUT_BUF))
) out_buf (
   .clk       (clk),
   .reset     (reset),
   .valid_in  (pipe_valid_st2),
   .ready_in  (pipe_ready_st2),
   .data_in   ({pipe_data_st2, src_data_m_st2}),
   .data_out  ({
      operands_if.data.wis,
      operands_if.data.tmask,
      operands_if.data.PC,
      operands_if.data.wb,
      operands_if.data.ex_type,
      operands_if.data.op_type,
      operands_if.data.op_args,
      operands_if.data.rd,
      operands_if.data.uuid,
      operands_if.data.rs3_data,
      operands_if.data.rs2_data,
      operands_if.data.rs1_data
   }),
   .valid_out (operands_if.valid),
   .ready_out (operands_if.ready)
);
```

From [VX_platform.vh](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_platform.vh#L261)

```verilog
// size(x): 0 -> 0, 1 -> 1, 2 -> 2, 3 -> 2, 4-> 2, 5 -> 2
`define TO_OUT_BUF_SIZE(s)    `MIN(s & 7, 2)

// reg(x): 0 -> 0, 1 -> 1, 2 -> 0, 3 -> 1, 4 -> 2, 5 > 3
`define TO_OUT_BUF_REG(s)     (((s & 7) < 2) ? (s & 7) : ((s & 7) - 2))
```

The final data is buffered to a skid buffer connected to the dispatch.

### Writeback

```verilog
wire [PER_BANK_ADDRW-1:0] gpr_wr_addr;
if (ISSUE_WIS != 0) begin : g_gpr_wr_addr
   assign gpr_wr_addr = {writeback_if.data.rd[`NR_BITS-1:BANK_SEL_BITS], writeback_if.data.wis};
end else begin : g_gpr_wr_addr_no_wis
   assign gpr_wr_addr = writeback_if.data.rd[`NR_BITS-1:BANK_SEL_BITS];
end

wire [BANK_SEL_WIDTH-1:0] gpr_wr_bank_idx;
if (NUM_BANKS != 1) begin : g_gpr_wr_bank_idx
   assign gpr_wr_bank_idx = writeback_if.data.rd[BANK_SEL_BITS-1:0];
end else begin : g_gpr_wr_bank_idx_0
   assign gpr_wr_bank_idx = '0;
end
```

All the writeback signals to update the register file:

- **`gpr_wr_addr`**: The register address in a bank.  
- **`gpr_wr_bank_idx`**: The bank index selected for the writeback operation.  

```verilog
for (genvar b = 0; b < NUM_BANKS; ++b) begin : g_gpr_rams
   wire gpr_wr_enabled;
   if (BANK_SEL_BITS != 0) begin : g_gpr_wr_enabled_multibanks
      assign gpr_wr_enabled = writeback_if.valid
                           && (gpr_wr_bank_idx == BANK_SEL_BITS'(b));
   end else begin : g_gpr_wr_enabled
      assign gpr_wr_enabled = writeback_if.valid;
   end

   wire [BYTEENW-1:0] wren;
   for (genvar i = 0; i < `NUM_THREADS; ++i) begin : g_wren
      assign wren[i*XLEN_SIZE+:XLEN_SIZE] = {XLEN_SIZE{writeback_if.data.tmask[i]}};
   end

   VX_dp_ram #(
      .DATAW (REGS_DATAW),
      .SIZE  (PER_BANK_REGS * PER_ISSUE_WARPS),
      .OUT_REG (1),
      .READ_ENABLE (1),
      .WRENW (BYTEENW),
   `ifdef GPR_RESET
      .RESET_RAM (1),
   `endif
      .NO_RWCHECK (1)
   ) gpr_ram (
      .clk   (clk),
      .reset (reset),
      .read  (pipe_fire_st1),
      .wren  (wren),
      .write (gpr_wr_enabled),
      .waddr (gpr_wr_addr),
      .wdata (writeback_if.data.data),
      .raddr (gpr_rd_addr_st1[b]),
      .rdata (gpr_rd_data_st2[b])
   );
end
```

The code loops for each bank to pass its corresponding signals for reading and writing.

- **`gpr_wr_enabled`**: Indicates if the write operation is enabled for the specific bank.  
- **`wren`**: Write enable signals for each thread, specifying which bytes in the data are being updated.  
- **`writeback_if.valid`**: Valid signal for initiating the writeback operation.  
- **`writeback_if.data.tmask`**: Thread mask specifying the active threads involved in the writeback.  
- **`writeback_if.data.wis`**: Warp instruction ID within a slice.  
- **`writeback_if.data.data`**: The actual data being written to the register file.  
- **`writeback_if.data.rd`**: The destination register index for the writeback operation.
