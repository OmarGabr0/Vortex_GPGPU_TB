# VX_lsu_unit Documentation

The `VX_lsu_unit` module implements a Load-Store Unit (LSU) designed to handle memory instructions efficiently in a GPU pipeline. Below are the key interfaces and structured ports used in this module.

---

## Interfaces

### 1. VX_dispatch_if
The `VX_dispatch_if` interface provides inputs for dispatching memory instructions to the LSU.

| Signal Name         | Width                          | Description                                      |
|---------------------|--------------------------------|--------------------------------------------------|
| `valid`             | 1                              | Indicates if the dispatch instruction is valid.  |
| `ready`             | 1                              | Indicates if the LSU is ready to accept instructions. |
| `data.uuid`         | `UUID_WIDTH`                  | Unique identifier for the instruction.           |
| `data.wis`          | `ISSUE_WIS_W`                 | Warp instruction slice identifier.               |
| `data.tmask`        | `NUM_THREADS`                 | Thread mask indicating active threads.           |
| `data.PC`           | `PC_BITS`                     | Program counter value.                           |
| `data.op_type`      | `INST_ALU_BITS`               | Type of the operation (e.g., ALU, memory).       |
| `data.op_args`      | Structure                     | Additional operation arguments.                  |
| `data.wb`           | 1                              | Indicates if write-back is required.             |
| `data.rd`           | `NR_BITS`                     | Destination register identifier.                 |
| `data.tid`          | `NT_WIDTH`                    | Thread ID.                                       |
| `data.rs1_data`     | `NUM_THREADS * XLEN`          | Data for source register 1.                      |
| `data.rs2_data`     | `NUM_THREADS * XLEN`          | Data for source register 2.                      |
| `data.rs3_data`     | `NUM_THREADS * XLEN`          | Data for source register 3.                      |

---

### 2. VX_execute_if
The `VX_execute_if` interface is used for communication between the dispatch unit and LSU slices. It contains the subset of threads and lanes actively executing memory instructions.

| Signal Name         | Width                          | Description                                      |
|---------------------|--------------------------------|--------------------------------------------------|
| `valid`             | 1                              | Indicates if the execution data is valid.        |
| `ready`             | 1                              | Indicates if the LSU slice is ready.             |
| `data.uuid`         | `UUID_WIDTH`                  | Unique identifier for the instruction.           |
| `data.wid`          | `NW_WIDTH`                    | Warp ID for the instruction.                     |
| `data.tmask`        | `NUM_LANES`                   | Active thread mask for the current lane.         |
| `data.PC`           | `PC_BITS`                     | Program counter value.                           |
| `data.op_type`      | `INST_ALU_BITS`               | Operation type.                                  |
| `data.op_args`      | Structure                     | Additional operation arguments.                  |
| `data.wb`           | 1                              | Indicates if write-back is required.             |
| `data.rd`           | `NR_BITS`                     | Destination register identifier.                 |
| `data.tid`          | `NT_WIDTH`                    | Thread ID.                                       |
| `data.rs1_data`     | `NUM_LANES * XLEN`            | Data for source register 1.                      |
| `data.rs2_data`     | `NUM_LANES * XLEN`            | Data for source register 2.                      |
| `data.rs3_data`     | `NUM_LANES * XLEN`            | Data for source register 3.                      |
| `data.pid`          | `LOG2UP(NUM_THREADS/NUM_LANES)` | Packet ID for partial execution.                |
| `data.sop`          | 1                              | Start of packet indicator.                       |
| `data.eop`          | 1                              | End of packet indicator.                         |

---

### 3. VX_commit_if
The `VX_commit_if` interface collects execution results and sends them back to the pipeline.

| Signal Name         | Width                          | Description                                      |
|---------------------|--------------------------------|--------------------------------------------------|
| `valid`             | 1                              | Indicates if the commit data is valid.           |
| `ready`             | 1                              | Indicates if the pipeline is ready for commits.  |
| `data.uuid`         | `UUID_WIDTH`                  | Unique identifier for the instruction.           |
| `data.wid`          | `NW_WIDTH`                    | Warp ID for the instruction.                     |
| `data.tmask`        | `NUM_LANES`                   | Active thread mask for the current lane.         |
| `data.PC`           | `PC_BITS`                     | Program counter value.                           |
| `data.wb`           | 1                              | Indicates if write-back occurred.                |
| `data.rd`           | `NR_BITS`                     | Destination register identifier.                 |
| `data.data`         | `NUM_LANES * XLEN`            | Result data for each lane.                       |
| `data.pid`          | `LOG2UP(NUM_THREADS/NUM_LANES)` | Packet ID for the instruction.                  |
| `data.sop`          | 1                              | Start of packet indicator.                       |
| `data.eop`          | 1                              | End of packet indicator.                         |

---

### 4. VX_lsu_mem_if
The `VX_lsu_mem_if` interface manages memory requests and responses for the LSU.

| Signal Name         | Width                          | Description                                      |
|---------------------|--------------------------------|--------------------------------------------------|
| `req_valid`         | 1                              | Indicates if a memory request is valid.          |
| `req_ready`         | 1                              | Indicates if the memory system is ready.         |
| `rsp_valid`         | 1                              | Indicates if a memory response is valid.         |
| `rsp_ready`         | 1                              | Indicates if the LSU is ready to accept responses.|
| `req_data.mask`     | `NUM_LANES`                   | Mask for selecting active lanes for the request. |
| `req_data.rw`       | 1                              | Read/Write indicator.                            |
| `req_data.addr`     | `NUM_LANES * ADDR_WIDTH`       | Address for each lane's memory operation.        |
| `req_data.data`     | `NUM_LANES * DATA_SIZE * 8`    | Data payload for each lane.                      |
| `req_data.byteen`   | `NUM_LANES * DATA_SIZE`        | Byte-enable mask for writes.                     |
| `req_data.flags`    | `NUM_LANES * FLAGS_WIDTH`      | Flags for memory operations.                     |
| `req_data.tag`      | `TAG_WIDTH`                   | Tag for identifying memory requests.             |
| `rsp_data.mask`     | `NUM_LANES`                   | Mask for selecting active lanes for the response.|
| `rsp_data.data`     | `NUM_LANES * DATA_SIZE * 8`    | Data payload for each lane.                      |
| `rsp_data.tag`      | `TAG_WIDTH`                   | Tag for identifying memory responses.            |

---

## Key Functional Components

### 1. Dispatch Unit
- Routes issued instructions (`dispatch_if`) to the appropriate LSU blocks.
- Converts full-thread data into lane-level instructions for `VX_execute_if`.

### 2. LSU Slices
- Executes memory operations independently within `NUM_LSU_BLOCKS` slices.
- Interfaces with `VX_lsu_mem_if` for memory requests and responses.

### 3. Gather Unit
- Aggregates commit results from each slice (`VX_commit_if`) into a global output.
- Handles synchronization for commit operations.

```markdown
**Summary**: The `VX_lsu_unit` orchestrates memory instruction dispatch, execution, and commit using modular interfaces (`dispatch_if`, `execute_if`, `commit_if`, `lsu_mem_if`). Each interface handles structured data efficiently to enable parallel processing and scalability.
