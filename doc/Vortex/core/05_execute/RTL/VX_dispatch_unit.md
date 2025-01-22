# VX_dispatch_unit Documentation

The `VX_dispatch_unit` is a key component responsible for dispatching memory instructions from multiple issue slots to execution units. It supports configurable block sizes, lane counts, and output buffering to handle diverse workloads.

---

## Parameters

| Parameter     | Default Value | Description                                                            |
|---------------|---------------|------------------------------------------------------------------------|
| `BLOCK_SIZE`  | 1             | Number of execution units to dispatch to.                             |
| `NUM_LANES`   | 1             | Number of lanes per execution unit.                                   |
| `OUT_BUF`     | 0             | Buffering level for output data.                                       |
| `MAX_FANOUT`  | `MAX_FANOUT`  | Maximum fanout threshold for optimization.                            |

---

## Interfaces

### Inputs

#### VX_dispatch_if (Slave)
The `dispatch_if` interface receives instructions to be dispatched to the execution units.

| Signal Name         | Width                | Description                                      |
|---------------------|----------------------|--------------------------------------------------|
| `valid`             | 1                    | Indicates if the dispatch instruction is valid.  |
| `data.uuid`         | `UUID_WIDTH`         | Unique identifier for the instruction.           |
| `data.wis`          | `ISSUE_WIS_W`        | Warp instruction slice identifier.               |
| `data.tmask`        | `NUM_THREADS`        | Thread mask indicating active threads.           |
| `data.PC`           | `PC_BITS`            | Program counter value.                           |
| `data.op_type`      | `INST_ALU_BITS`      | Type of the operation (e.g., ALU, memory).       |
| `data.op_args`      | Structure            | Additional operation arguments.                  |
| `data.wb`           | 1                    | Indicates if write-back is required.             |
| `data.rd`           | `NR_BITS`            | Destination register identifier.                 |
| `data.tid`          | `NT_WIDTH`           | Thread ID.                                       |
| `data.rs1_data`     | `NUM_THREADS * XLEN` | Data for source register 1.                      |
| `data.rs2_data`     | `NUM_THREADS * XLEN` | Data for source register 2.                      |
| `data.rs3_data`     | `NUM_THREADS * XLEN` | Data for source register 3.                      |
| `ready`             | 1                    | Indicates if the dispatch unit can accept instructions. |

---

### Outputs

#### VX_execute_if (Master)
The `execute_if` interface sends instructions from the dispatch unit to execution units.

| Signal Name         | Width                | Description                                      |
|---------------------|----------------------|--------------------------------------------------|
| `valid`             | 1                    | Indicates if the execution data is valid.        |
| `data.uuid`         | `UUID_WIDTH`         | Unique identifier for the instruction.           |
| `data.wid`          | `NW_WIDTH`           | Warp ID for the instruction.                     |
| `data.tmask`        | `NUM_LANES`          | Active thread mask for the current lane.         |
| `data.PC`           | `PC_BITS`            | Program counter value.                           |
| `data.op_type`      | `INST_ALU_BITS`      | Operation type.                                  |
| `data.op_args`      | Structure            | Additional operation arguments.                  |
| `data.wb`           | 1                    | Indicates if write-back is required.             |
| `data.rd`           | `NR_BITS`            | Destination register identifier.                 |
| `data.tid`          | `NT_WIDTH`           | Thread ID.                                       |
| `data.rs1_data`     | `NUM_LANES * XLEN`   | Data for source register 1.                      |
| `data.rs2_data`     | `NUM_LANES * XLEN`   | Data for source register 2.                      |
| `data.rs3_data`     | `NUM_LANES * XLEN`   | Data for source register 3.                      |
| `data.pid`          | `LOG2UP(NUM_THREADS/NUM_LANES)` | Packet ID for partial execution.                |
| `data.sop`          | 1                    | Start of packet indicator.                       |
| `data.eop`          | 1                    | End of packet indicator.                         |
| `ready`             | 1                    | Indicates if the execution unit is ready.        |

---

## Key Features and Functionality

### 1. Batch Dispatch Logic
- **Batch Selection:** When `BATCH_COUNT > 1`, the unit uses an arbiter to select the next batch of valid dispatch instructions. The selected batch index is updated on each cycle.
- **Batch Index Management:** Keeps track of batch indices for dispatching instructions in a round-robin or priority-based manner.

### 2. Partial Thread Handling
- **Thread Mask Splitting:** If `NUM_THREADS > NUM_LANES`, the unit splits threads into smaller groups (packets) based on the number of lanes.
- **Packet Management:** Handles the start (`sop`), end (`eop`), and intermediate packets for partially dispatched threads.

### 3. Data Routing
- **Instruction Routing:** Maps dispatch instructions to the appropriate execution blocks based on `BLOCK_SIZE` and `batch_idx`.
- **Elastic Buffering:** Uses elastic buffers to synchronize data flow between the dispatch and execution stages.

---

## Local Parameters

| Parameter            | Description                                                   |
|----------------------|---------------------------------------------------------------|
| `BLOCK_SIZE_W`       | Log2 of `BLOCK_SIZE`, used for block indexing.                |
| `NUM_PACKETS`        | Number of packets calculated as `NUM_THREADS / NUM_LANES`.    |
| `PID_WIDTH`          | Width of the packet ID field.                                 |
| `BATCH_COUNT`        | Number of instruction batches per block size.                 |
| `IN_DATAW`           | Width of input data from `dispatch_if`.                       |
| `OUT_DATAW`          | Width of output data to `execute_if`.                         |
| `DATA_TMASK_OFF`     | Offset for the thread mask field in `IN_DATAW`.               |
| `DATA_REGS_OFF`      | Offset for the register data fields in `IN_DATAW`.            |

---

## Summary

The `VX_dispatch_unit` efficiently routes memory instructions from multiple issue slots to execution units while handling variable block sizes, lane counts, and thread groups. Its modular design ensures scalability and flexibility for diverse GPU workloads.
