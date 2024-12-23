# VX_issue

This is the top module for issue stage, and [VX_issue_slice](../RTL/VX_issue_slice.md) is next in the hierarchy.

## Parameters

| Parameter      | Default Value                        | Description                                                                 |
|----------------|--------------------------------------|-----------------------------------------------------------------------------|
| [`UUID_ENABLE`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L52)  | Enabled (if `NDEBUG` is not defined or `SCOPE` is defined) | Enables UUID generation functionality for debugging or scoping purposes.   |
| [`UUID_WIDTH`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L52)   | 44 bits (default) or 1 bit (if neither `NDEBUG` nor `SCOPE` is defined) | Width of the Universal Unique ID, configurable based on debug/scoping mode.|
| `XLEN`                 | Architecture-defined (e.g., 32, 64) | Width of general-purpose registers and native integer data types in RISC-V.|
| [`PC_BITS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L64)              | `XLEN - 1`                          | Width of the program counter (depends on XLEN).                            |
| `EXT_F_ENABLE`         | Architecture-defined                | Indicates whether floating-point extension is enabled.                     |
| [`NUM_EX_UNITS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L77)         | `3 + EXT_F_ENABLE`                  | Number of execution units, including floating-point if enabled.            |
| [`EX_BITS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L78)              | `CLOG2(NUM_EX_UNITS)`               | Number of bits required to encode execution unit selection.                |
| [`EX_WIDTH`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L79)             | `UP(EX_BITS)`                       | Aligned width for execution unit encoding.                                 |
| [`INST_OP_BITS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L136) | 4 | Number of opcode bits. |
| [`INST_OP_BITS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L137) | $bits(op_args_t) | Number of bits used for the arguments field in an instruction. |
| [`NUM_IREGS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L35)            | 32                                  | Number of integer registers (fixed by RISC-V architecture).                |
| [`NUM_REGS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L42)             | `NUM_IREGS` or `2 * NUM_IREGS`      | Total number of registers, including floating-point, if `EXT_F_ENABLE` is set. |
| [`NR_BITS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L45)              | `CLOG2(NUM_REGS)`                   | Number of bits required to address all registers.                          |
| [`NRI_BITS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L37)             | `CLOG2(NUM_IREGS)`                  | Number of bits required to address integer registers.                      |
| [`ISSUE_WIDTH`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_config.vh#L352)          | `UP(NUM_WARPS / 8)`                 | Number of instructions issued per cycle, dependent on warp configuration.  |
| [`PER_ISSUE_WARPS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_gpu_pkg.sv#L260)      | `NUM_WARPS / ISSUE_WIDTH`           | Number of warps per issue slot.                                            |
| [`ISSUE_ISW`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_gpu_pkg.sv#L258)            | `CLOG2(ISSUE_WIDTH)`                | Number of bits required to encode issue width.                             |
| [`ISSUE_ISW_W`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_gpu_pkg.sv#L259)          | `UP(ISSUE_ISW)`                     | Aligned width for issue width encoding.                                    |
| [`ISSUE_WIS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_gpu_pkg.sv#L261)            | `CLOG2(PER_ISSUE_WARPS)`            | Number of bits required to encode number of warps per slice                |
| [`ISSUE_WIS_W`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_gpu_pkg.sv#L262)          | `UP(ISSUE_WIS)`                     | Aligned width for warps per slice encoding.                                |

## Interfaces and Ports

### Decode Interface (`decode_if`)

| Port Name   | Width                  | Direction | Description                                      |
|-------------|------------------------|-----------|--------------------------------------------------|
| `valid`     | 1 bit                  | Input     | Indicates if the instruction is valid.          |
| `ready`     | 1 bit                  | Output    | Indicates readiness to receive an instruction.  |
| `data.uuid` | `UUID_WIDTH`           | Input     | Universal Unique ID for the instruction.        |
| `data.wid`  | `LOG2UP(NUM_WARPS)`    | Input     | Warp ID.                                        |
| `data.tmask`| `NUM_THREADS`          | Input     | Thread mask indicating active threads.          |
| `data.PC`   | `PC_BITS`              | Input     | Program counter value.                          |
| `data.ex_type` | `EX_BITS`           | Input     | Execution type of the instruction.              |
| `data.op_type` | `INST_OP_BITS`      | Input     | Operation type of the instruction.              |
| `data.op_args` | Structure            | Input     | Arguments for the operation.                    |
| `data.wb`   | 1 bit                  | Input     | Indicates if writeback is required.             |
| `data.rd`   | `NR_BITS`              | Input     | Destination register.                           |
| `data.rs1`  | `NR_BITS`              | Input     | Source register 1.                              |
| `data.rs2`  | `NR_BITS`              | Input     | Source register 2.                              |
| `data.rs3`  | `NR_BITS`              | Input     | Source register 3.                              |

### Writeback Interface (`writeback_if`)

| Port Name       | Width                  | Direction | Description                                      |
|-----------------|------------------------|-----------|--------------------------------------------------|
| `valid`         | 1 bit                  | Input     | Indicates if the writeback data is valid.       |
| `data.uuid`     | `UUID_WIDTH`           | Input     | Universal Unique ID for the instruction.        |
| `data.wis`      | `ISSUE_WIS_W`          | Input     | Warp instruction slot ID.                       |
| `data.tmask`    | `NUM_THREADS`          | Input     | Thread mask indicating active threads.          |
| `data.PC`       | `PC_BITS`              | Input     | Program counter value.                          |
| `data.rd`       | `NR_BITS`              | Input     | Destination register.                           |
| `data.data`     | `NUM_THREADS` x `XLEN` | Input     | Result data for each thread.                    |
| `data.sop`      | 1 bit                  | Input     | Start of packet indicator.                      |
| `data.eop`      | 1 bit                  | Input     | End of packet indicator.                        |

### Dispatch Interface (`dispatch_if`)

| Port Name         | Width                  | Direction | Description                                      |
|-------------------|------------------------|-----------|--------------------------------------------------|
| `valid`           | 1 bit                  | Output    | Indicates if the dispatch data is valid.        |
| `ready`           | 1 bit                  | Input     | Indicates readiness of the execution unit.      |
| `data.uuid`       | `UUID_WIDTH`           | Output    | Universal Unique ID for the instruction.        |
| `data.wis`        | `ISSUE_WIS_W`          | Output    | Warp instruction slot ID.                       |
| `data.tmask`      | `NUM_THREADS`          | Output    | Thread mask indicating active threads.          |
| `data.PC`         | `PC_BITS`              | Output    | Program counter value.                          |
| `data.op_type`    | `INST_ALU_BITS`        | Output    | Operation type of the instruction.              |
| `data.op_args`    | Structure              | Output    | Arguments for the operation.                    |
| `data.wb`         | 1 bit                  | Output    | Indicates if writeback is required.             |
| `data.rd`         | `NR_BITS`              | Output    | Destination register.                           |
| `data.tid`        | `NT_WIDTH`             | Output    | Thread ID.                                      |
| `data.rs1_data`   | `NUM_THREADS` x `XLEN` | Output    | Data for source register 1.                     |
| `data.rs2_data`   | `NUM_THREADS` x `XLEN` | Output    | Data for source register 2.                     |
| `data.rs3_data`   | `NUM_THREADS` x `XLEN` | Output    | Data for source register 3.                     |

## Code

Each set of 8 warps corresponds to 1 issue slice, so we need to map each warp to its corresponding issue slice. This requires converting the warp ID.

```verilog
   wire [ISSUE_ISW_W-1:0] decode_isw = wid_to_isw(decode_if.data.wid);
   wire [ISSUE_WIS_W-1:0] decode_wis = wid_to_wis(decode_if.data.wid);
```

From [VX_gpu_pkg.sv](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_gpu_pkg.sv#L277):

```verilog
   function logic [ISSUE_ISW_W-1:0] wid_to_isw(
      input logic [`NW_WIDTH-1:0] wid
   );
      if (ISSUE_ISW != 0) begin
         wid_to_isw = wid[ISSUE_ISW_W-1:0];
      end else begin
         wid_to_isw = 0;
      end
   endfunction

   function logic [ISSUE_WIS_W-1:0] wid_to_wis(
      input logic [`NW_WIDTH-1:0] wid
   );
      if (ISSUE_WIS != 0) begin
         wid_to_wis = ISSUE_WIS_W'(wid >> ISSUE_ISW);
      end else begin
         wid_to_wis = 0;
      end
   endfunction
```

- **decode_isw:** Represents the **issue slice index** within the warp ID, identifying which slice of the issue unit the instruction belongs to.
- **decode_wis:** Represents the **warp index within an issue slice**, identifying which sub-group of warps (if any) the instruction corresponds to.

For example, with 16 warps, we get 2 slices. Warps 0–7 will have `isw = 0`, and warps 8–15 will have `isw = 1`. We also want each slice to have a warp counter starting from 0, so `wis` will be 0–7 for both slices in this example.

```verilog
wire [`ISSUE_WIDTH-1:0] decode_ready_in;
assign decode_if.ready = decode_ready_in[decode_isw];
```

- **`decode_ready_in`**: An array of readiness signals, where each bit represents the readiness of a slice.
- **`decode_if.ready`**: Assigned the readiness signal for the slice specified by **`decode_isw`**, which indexes into `decode_ready_in`.

```verilog
for (genvar issue_id = 0; issue_id < `ISSUE_WIDTH; ++issue_id) begin : g_issue_slices
```

- **Generates multiple issue slices** by looping over each issue slice.

```verilog
VX_decode_if #(.NUM_WARPS (PER_ISSUE_WARPS)) per_issue_decode_if();
VX_dispatch_if per_issue_dispatch_if[`NUM_EX_UNITS]();
```

- **`VX_decode_if`**: A decode interface for each slice, with **`PER_ISSUE_WARPS`** warps per slice.
- **`VX_dispatch_if`**: Dispatch interface for each execution unit (based on **`NUM_EX_UNITS`**) for each slice.

```verilog
assign per_issue_decode_if.valid = decode_if.valid && (decode_isw == ISSUE_ISW_W'(issue_id));
assign per_issue_decode_if.data.uuid = decode_if.data.uuid;
assign per_issue_decode_if.data.wid = decode_wis;
assign per_issue_decode_if.data.tmask = decode_if.data.tmask;
assign per_issue_decode_if.data.PC = decode_if.data.PC;
assign per_issue_decode_if.data.ex_type = decode_if.data.ex_type;
assign per_issue_decode_if.data.op_type = decode_if.data.op_type;
assign per_issue_decode_if.data.op_args = decode_if.data.op_args;
assign per_issue_decode_if.data.wb = decode_if.data.wb;
assign per_issue_decode_if.data.rd = decode_if.data.rd;
assign per_issue_decode_if.data.rs1 = decode_if.data.rs1;
assign per_issue_decode_if.data.rs2 = decode_if.data.rs2;
assign per_issue_decode_if.data.rs3 = decode_if.data.rs3;
assign decode_ready_in[issue_id] = per_issue_decode_if.ready;
```

- **Valid & Ready Signals**: Map the valid signal from decode to the desired slice, and map the ready signals from all slices to `decode_ready_in` in order to provide 1 ready signal which is selected by `decode_isw` calculated from warp ID.
- **Data Signals**: All data signals are unchanged from decode stage except for the warp ID, which is changed in order to be from 0 to `PER_ISSUE_WARPS` for each slice.

```verilog
VX_issue_slice #(
    .INSTANCE_ID ($sformatf("%s%0d", INSTANCE_ID, issue_id)),
    .ISSUE_ID (issue_id)
) issue_slice (
    `SCOPE_IO_BIND(issue_id)
    .clk          (clk),
    .reset        (reset),
`ifdef PERF_ENABLE
    .issue_perf   (per_issue_perf[issue_id]),
`endif
    .decode_if    (per_issue_decode_if),
    .writeback_if (writeback_if[issue_id]),
    .dispatch_if  (per_issue_dispatch_if)
);
```

- **`VX_issue_slice`**: Instantiates an issue slice for each `issue_id`, with unique `INSTANCE_ID` and `ISSUE_ID` based on the `issue_id`.
- **`decode_if`**: Connects each slice's decode interface (`per_issue_decode_if`).
- **`writeback_if`**: Connects each slice's writeback interface.
- **`dispatch_if`**: Connects each slice's dispatch interface.

```verilog
for (genvar ex_id = 0; ex_id < `NUM_EX_UNITS; ++ex_id) begin : g_dispatch_if
    `ASSIGN_VX_IF(dispatch_if[ex_id * `ISSUE_WIDTH + issue_id], per_issue_dispatch_if[ex_id]);
end
```

- **Dispatch Interface Transpose**: For each execution unit (`NUM_EX_UNITS`), the dispatch interface is assigned to the appropriate slice's dispatch interface (`per_issue_dispatch_if`).
