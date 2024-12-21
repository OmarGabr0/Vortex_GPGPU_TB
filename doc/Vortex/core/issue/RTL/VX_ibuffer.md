# VX_ibuffer

## Interfaces

```verilog
    VX_decode_if.slave  decode_if, // inputs
    VX_ibuffer_if.master ibuffer_if [PER_ISSUE_WARPS] // outputs
```

## Parameters

| Parameter                | Default Value                        | Description                                                                 |
|--------------------------|--------------------------------------|-----------------------------------------------------------------------------|
| [`UUID_ENABLE`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L52)  | Enabled (if `NDEBUG` is not defined or `SCOPE` is defined) | Enables UUID generation functionality for debugging or scoping purposes.   |
| [`UUID_WIDTH`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L52)   | 44 bits (default) or 1 bit (if neither `NDEBUG` nor `SCOPE` is defined) | Width of the Universal Unique ID, configurable based on debug/scoping mode.|
| `XLEN`                   | Architecture-defined (e.g., 32, 64)  | Width of general-purpose registers and native integer data types in RISC-V.|
| [`PC_BITS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L64)      | `XLEN - 1`                          | Width of the program counter (depends on XLEN).                            |
| [`NUM_THREADS`](https://github.com/vortexgpgpu/vortex/blob/main/hw/rtl/VX_define.vh#L102) | `NUM_WARPS * NUM_THREADS_PER_WARP`  | Total number of threads supported by the GPU.                              |
| [`INST_OP_BITS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L136) | 4                                   | Number of bits to represent instruction operations.                        |
| [`INST_ARGS_BITS`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_define.vh#L137) | `$bits(op_args_t)`                          | Number of bits to represent instruction arguments.                         |
| [`EX_BITS`](https://github.com/vortexgpgpu/vortex/blob/main/hw/rtl/VX_define.vh#L78)      | `CLOG2(NUM_EX_UNITS)`               | Each bit represent an operand                |
| [`NUM_REGS`](https://github.com/vortexgpgpu/vortex/blob/main/hw/rtl/VX_define.vh#L42)     | `NUM_IREGS` or `2 * NUM_IREGS`      | Total number of registers, including floating-point, if `EXT_F_ENABLE` is set. |
| [`NR_BITS`](https://github.com/vortexgpgpu/vortex/blob/main/hw/rtl/VX_define.vh#L45)      | `CLOG2(NUM_REGS)`                   | Number of bits required to address all registers.                          |
| [`IBUF_SIZE`](https://github.com/vortexgpgpu/vortex/blob/01974e124f114489844f148c43db00fe14e187ae/hw/rtl/VX_config.vh#L389)      | 4                   | The FIFO depth for the instruction buffer                          |

```verilog
    wire [PER_ISSUE_WARPS-1:0] ibuf_ready_in;
    assign decode_if.ready = ibuf_ready_in[decode_if.data.wid];

    for (genvar w = 0; w < PER_ISSUE_WARPS; ++w) begin : g_instr_bufs
        VX_elastic_buffer #(
            .DATAW   (DATAW),
            .SIZE    (`IBUF_SIZE),
            .OUT_REG (2) // 2-cycle EB for area reduction
        ) instr_buf (
            .clk      (clk),
            .reset    (reset),
            .valid_in (decode_if.valid && decode_if.data.wid == ISSUE_WIS_W'(w)),
            .data_in  ({
                decode_if.data.uuid,
                decode_if.data.tmask,
                decode_if.data.PC,
                decode_if.data.ex_type,
                decode_if.data.op_type,
                decode_if.data.op_args,
                decode_if.data.wb,
                decode_if.data.rd,
                decode_if.data.rs1,
                decode_if.data.rs2,
                decode_if.data.rs3
            }),
            .ready_in (ibuf_ready_in[w]),
            .valid_out(ibuffer_if[w].valid),
            .data_out (ibuffer_if[w].data),
            .ready_out(ibuffer_if[w].ready)
        );
    `ifndef L1_ENABLE
        assign decode_if.ibuf_pop[w] = ibuffer_if[w].valid && ibuffer_if[w].ready;
    `endif
    end
```

A FIFO buffer is instantiated for each warp in the slice to store the instructions for this warp.
