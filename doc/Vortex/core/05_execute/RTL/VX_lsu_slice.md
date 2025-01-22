# VX_lsu_slice Documentation

The `VX_lsu_slice` module is responsible for managing memory requests and responses at the slice level within a Load-Store Unit (LSU). It coordinates memory operations, ensures proper address formatting, handles byte alignment, and manages memory fences. Additionally, it interacts with memory schedulers and commit interfaces for execution and completion.

---

## Parameters

| Parameter        | Default Value | Description                                          |
|------------------|---------------|------------------------------------------------------|
| `INSTANCE_ID`    | ""            | A unique identifier for the module instance.        |

---

## Local Parameters

| Parameter         | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `NUM_LANES`       | Number of LSU lanes available for execution.                                |
| `PID_BITS`        | Number of bits required to encode packet IDs based on thread distribution. |
| `PID_WIDTH`       | Aligned width of `PID_BITS`.                                               |
| `RSP_ARB_DATAW`   | Width of data for the response arbiter.                                     |
| `LSUQ_SIZEW`      | Width of the LSU queue index.                                               |
| `REQ_ASHIFT`      | Address alignment shift for LSU word size.                                  |
| `MEM_ASHIFT`      | Address alignment shift for memory block size.                              |
| `MEM_ADDRW`       | Effective memory address width after accounting for alignment.              |
| `TAG_ID_WIDTH`    | Width of the internal tag identifier (wid, PC, op_type, etc.).              |
| `TAG_WIDTH`       | Full tag width, including `uuid` and `tag_id`.                              |

---

## Interfaces

### Inputs

#### `VX_execute_if` (Slave)
The `execute_if` interface provides incoming memory instructions from the execution pipeline.

| Signal Name      | Width                     | Description                                                |
|------------------|---------------------------|------------------------------------------------------------|
| `valid`          | 1                         | Indicates if the execute interface has valid data.         |
| `data.rs1_data`  | `NUM_LANES * XLEN`        | Source register 1 data.                                    |
| `data.rs2_data`  | `NUM_LANES * XLEN`        | Source register 2 data (used for stores).                  |
| `data.op_args`   | Custom structure          | Operation-specific arguments, including offset.            |
| `data.op_type`   | LSU operation type width  | Specifies load/store operation type.                       |
| `data.uuid`      | `UUID_WIDTH`              | Unique identifier for the instruction.                     |
| `data.tmask`     | `NUM_LANES`               | Thread mask indicating active threads.                     |
| `data.wid`       | Warp ID width             | Warp identifier.                                           |
| `data.PC`        | `PC_BITS`                 | Program counter for the instruction.                       |
| `data.rd`        | `NR_BITS`                 | Destination register ID.                                    |
| `data.eop`       | 1                         | End-of-packet indicator for the instruction group.         |
| `ready`          | 1                         | Indicates if the slice can accept new requests.            |

---

### Outputs

#### `VX_commit_if` (Master)
The `commit_if` interface sends completed memory operations back to the pipeline for commit.

| Signal Name      | Width                     | Description                                                |
|------------------|---------------------------|------------------------------------------------------------|
| `valid`          | 1                         | Indicates if the commit interface has valid data.          |
| `data.uuid`      | `UUID_WIDTH`              | Unique identifier for the completed instruction.           |
| `data.wid`       | Warp ID width             | Warp identifier of the instruction.                        |
| `data.tmask`     | `NUM_LANES`               | Thread mask indicating threads affected by the operation.  |
| `data.PC`        | `PC_BITS`                 | Program counter of the instruction.                        |
| `data.rd`        | `NR_BITS`                 | Destination register ID for load operations.               |
| `data.data`      | `NUM_LANES * XLEN`        | Data for load instructions to be written back.             |
| `data.sop`       | 1                         | Start-of-packet indicator.                                 |
| `data.eop`       | 1                         | End-of-packet indicator.                                   |
| `ready`          | 1                         | Indicates if the pipeline is ready to accept commit data.  |

#### `VX_lsu_mem_if` (Master)
The `lsu_mem_if` interface communicates with the memory system for request and response handling.

| Signal Name          | Width                          | Description                                      |
|----------------------|--------------------------------|--------------------------------------------------|
| `req_valid`          | 1                              | Indicates if the memory request is valid.       |
| `req_data.mask`      | `NUM_LANES`                    | Thread mask for the memory request.             |
| `req_data.rw`        | 1                              | Indicates if the request is a read (`0`) or write (`1`). |
| `req_data.addr`      | `NUM_LANES * LSU_ADDR_WIDTH`   | Memory addresses for the request.               |
| `req_data.data`      | `NUM_LANES * LSU_WORD_SIZE*8`  | Data for write requests.                        |
| `req_data.byteen`    | `NUM_LANES * LSU_WORD_SIZE`    | Byte enable signals for the request.            |
| `req_data.flags`     | `NUM_LANES * MEM_REQ_FLAGS_WIDTH` | Additional memory request flags (e.g., I/O, local memory). |
| `req_ready`          | 1                              | Indicates if the memory system can accept requests. |
| `rsp_valid`          | 1                              | Indicates if the memory response is valid.      |
| `rsp_data.mask`      | `NUM_LANES`                    | Thread mask for the memory response.            |
| `rsp_data.data`      | `NUM_LANES * LSU_WORD_SIZE*8`  | Data from memory for load instructions.         |
| `rsp_ready`          | 1                              | Indicates if the memory system can accept responses. |

---

## Key Functional Features

### 1. **Address Calculation**
- Combines `rs1_data` and an immediate offset to compute the full memory address for each active lane.

### 2. **Byte Enable Handling**
- Dynamically generates byte-enable signals based on operation size (`8-bit`, `16-bit`, `32-bit`, etc.).

### 3. **Memory Scheduler Integration**
- Sends memory requests through the `VX_mem_scheduler` for optimized arbitration and access to memory channels.

### 4. **Fence Handling**
- Manages memory fences, ensuring synchronization between memory requests and responses.

### 5. **Misaligned Access Detection**
- Asserts an error if an instruction attempts a misaligned memory access based on its operation size.

### 6. **Response Formatting**
- Formats data from memory for each thread, applying alignment and sign-extension (or zero-extension) as needed.

---

## Summary

The `VX_lsu_slice` provides a robust implementation for handling memory requests and responses in a scalable manner. It supports multi-threaded execution with proper address formatting, dynamic byte enable generation, and integration with memory scheduling and commit systems.
