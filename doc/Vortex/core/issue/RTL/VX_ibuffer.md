# VX_ibuffer

## Interfaces

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

### Instruction Buffer Interface (`ibuffer_if`)

| Port Name      | Width                  | Direction | Description                                      |
|----------------|------------------------|-----------|--------------------------------------------------|
| `valid`        | 1 bit                  | Output    | Indicates if the instruction is valid.          |
| `ready`        | 1 bit                  | Input     | Indicates readiness to receive an instruction.  |
| `data.uuid`    | `UUID_WIDTH`           | Output    | Universal Unique ID for the instruction.        |
| `data.tmask`   | `NUM_THREADS`          | Output    | Thread mask indicating active threads.          |
| `data.PC`      | `PC_BITS`              | Output    | Program counter value.                          |
| `data.ex_type` | `EX_BITS`              | Output    | Execution type of the instruction.              |
| `data.op_type` | `INST_OP_BITS`         | Output    | Operation type of the instruction.              |
| `data.op_args` | Structure              | Output    | Arguments for the operation.                    |
| `data.wb`      | 1 bit                  | Output    | Indicates if writeback is required.             |
| `data.rd`      | `NR_BITS`              | Output    | Destination register.                           |
| `data.rs1`     | `NR_BITS`              | Output    | Source register 1.                              |
| `data.rs2`     | `NR_BITS`              | Output    | Source register 2.                              |
| `data.rs3`     | `NR_BITS`              | Output    | Source register 3.                              |

## Code
