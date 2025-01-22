# VX_mem_unit

The `VX_mem_unit` module is responsible for managing memory operations, including interactions with local memory (LMEM) and data cache (DCACHE). It integrates structured interfaces and several submodules for efficient memory handling.

## Parameters

| Parameter       | Default Value | Description                                                       |
|-----------------|---------------|-------------------------------------------------------------------|
| `INSTANCE_ID`   | ""            | Unique identifier for the module instance.                       |

## Interfaces and Ports

### Inputs

| Port Name | Width | Direction | Description |
|-----------|-------|-----------|-------------|
| `clk`     | 1     | Input     | Clock signal. |
| `reset`   | 1     | Input     | Reset signal. |

### Outputs

| Port Name   | Width        | Direction | Description                      |
|-------------|--------------|-----------|----------------------------------|
| `lmem_perf` | `cache_perf_t` (conditional) | Output    | Performance counters for local memory (if enabled). |

### LSU Memory Interface (Slave)

`lsu_mem_if` is an array of LSU memory interfaces used for communication with the memory unit.

| Port Name         | Width                          | Direction | Description                                                                 |
|-------------------|--------------------------------|-----------|-----------------------------------------------------------------------------|
| `req_valid`       | 1                              | Input     | Valid signal for memory requests.                                          |
| `req_ready`       | 1                              | Output    | Ready signal for memory requests.                                          |
| `rsp_valid`       | 1                              | Output    | Valid signal for memory responses.                                         |
| `rsp_ready`       | 1                              | Input     | Ready signal for memory responses.                                         |
| `req_data.uuid`   | `UUID_WIDTH`                  | Input     | Universal Unique ID for the request.                                       |
| `req_data.addr`   | `ADDR_WIDTH`                  | Input     | Address of the memory request.                                             |
| `req_data.data`   | `DATA_SIZE*8`                 | Input     | Data payload for write operations.                                         |
| `req_data.byteen` | `DATA_SIZE`                   | Input     | Mask for selecting bytes in write requests.                                |
| `req_data.flags`  | `FLAGS_WIDTH`                 | Input     | Flags for the memory operation.                                            |
| `req_data.tag`    | `TAG_WIDTH`                  | Input     | Transaction tag for identifying responses.                                 |
| `rsp_data.data`   | `DATA_SIZE*8`                 | Output    | Data payload for read responses.                                           |
| `rsp_data.tag`    | `TAG_WIDTH`                  | Output    | Transaction tag for identifying responses.                                 |

### Data Cache Bus Interface (Master)

`dcache_bus_if` is an array of master interfaces for data cache communication.

| Port Name         | Width                          | Direction | Description                                                                 |
|-------------------|--------------------------------|-----------|-----------------------------------------------------------------------------|
| `req_valid`       | 1                              | Output    | Valid signal for memory requests.                                          |
| `req_ready`       | 1                              | Input     | Ready signal for memory requests.                                          |
| `rsp_valid`       | 1                              | Input     | Valid signal for memory responses.                                         |
| `rsp_ready`       | 1                              | Output    | Ready signal for memory responses.                                         |
| `req_data.uuid`   | `UUID_WIDTH`                  | Output    | Universal Unique ID for the request.                                       |
| `req_data.addr`   | `ADDR_WIDTH`                  | Output    | Address of the memory request.                                             |
| `req_data.data`   | `DATA_SIZE*8`                 | Output    | Data payload for write operations.                                         |
| `req_data.byteen` | `DATA_SIZE`                   | Output    | Mask for selecting bytes in write requests.                                |
| `req_data.flags`  | `FLAGS_WIDTH`                 | Output    | Flags for the memory operation.                                            |
| `req_data.tag`    | `TAG_WIDTH`                  | Output    | Transaction tag for identifying responses.                                 |
| `rsp_data.data`   | `DATA_SIZE*8`                 | Input     | Data payload for read responses.                                           |
| `rsp_data.tag`    | `TAG_WIDTH`                  | Input     | Transaction tag for identifying responses.                                 |

## Submodules

### 1. VX_lmem_switch

#### Description:
The `VX_lmem_switch` module arbitrates between local memory and global memory requests.

#### Instantiations:
- **Count:** `NUM_LSU_BLOCKS` times (e.g., one per LSU block).

#### Parameters:
| Parameter      | Value | Description |
|----------------|-------|-------------|
| `REQ0_OUT_BUF` | 1     | Enables output buffering for global memory requests. |
| `REQ1_OUT_BUF` | 0     | Disables output buffering for local memory requests. |
| `RSP_OUT_BUF`  | 1     | Enables output buffering for responses. |
| `ARBITER`      | "P"  | Configures the arbitration policy to priority-based. |

#### Connections via Interfaces:
- **Input:** `lsu_mem_if`
- **Outputs:** `lsu_dcache_if`, `lsu_lmem_if`

---

### 2. VX_lsu_adapter

#### Description:
The `VX_lsu_adapter` adapts LSU memory requests to the memory bus interface.

#### Instantiations:
- **Count:** `NUM_LSU_BLOCKS` times (one per LSU block).

#### Parameters:
| Parameter       | Value               | Description                                         |
|-----------------|---------------------|-----------------------------------------------------|
| `NUM_LANES`     | `NUM_LSU_LANES`     | Number of lanes for memory requests.               |
| `DATA_SIZE`     | `LSU_WORD_SIZE`     | Data size for each memory request.                 |
| `TAG_WIDTH`     | `LSU_TAG_WIDTH`     | Width of the transaction tag.                      |
| `TAG_SEL_BITS`  | `LSU_TAG_WIDTH - UUID_WIDTH` | Bits used for selecting the tag.                  |
| `ARBITER`       | "P"                | Configures the arbitration policy.                 |
| `REQ_OUT_BUF`   | 3                   | Number of buffers for outgoing requests.           |
| `RSP_OUT_BUF`   | 2                   | Number of buffers for incoming responses.          |

#### Connections via Interfaces:
- **Input:** `lsu_lmem_if`
- **Output:** `lmem_bus_if`

---

### 3. VX_local_mem

#### Description:
The `VX_local_mem` module implements local memory functionality.

#### Instantiations:
- **Count:** 1 instance.

#### Parameters:
| Parameter       | Value                    | Description                                       |
|-----------------|--------------------------|---------------------------------------------------|
| `INSTANCE_ID`   | `INSTANCE_ID-lmem`       | Unique identifier for the instance.               |
| `SIZE`          | `1 << LMEM_LOG_SIZE`     | Size of the local memory.                         |
| `NUM_REQS`      | `LSU_NUM_REQS`           | Number of requests supported.                     |
| `NUM_BANKS`     | `LMEM_NUM_BANKS`         | Number of memory banks.                           |
| `WORD_SIZE`     | `LSU_WORD_SIZE`          | Size of each memory word.                         |
| `ADDR_WIDTH`    | `LMEM_ADDR_WIDTH`        | Width of the memory address.                      |
| `UUID_WIDTH`    | `UUID_WIDTH`             | Width of the unique identifier.                   |
| `TAG_WIDTH`     | `LSU_TAG_WIDTH`          | Width of the transaction tag.                     |
| `OUT_BUF`       | 3                        | Number of buffers for output requests.            |

#### Connections via Interfaces:
- **Input:** `lmem_bus_if`

---

### 4. VX_mem_coalescer

#### Description:
The `VX_mem_coalescer` aggregates and optimizes memory access patterns by coalescing smaller memory requests.

#### Instantiations:
- **Count:** `NUM_LSU_BLOCKS` times (one per LSU block).

#### Parameters:
| Parameter         | Value                     | Description                                     |
|-------------------|---------------------------|-------------------------------------------------|
| `INSTANCE_ID`     | `INSTANCE_ID-coalescerX`  | Unique identifier for each instance (X = index).|
| `NUM_REQS`        | `NUM_LSU_LANES`           | Number of memory requests supported.            |
| `DATA_IN_SIZE`    | `LSU_WORD_SIZE`           | Input data size for requests.                   |
| `DATA_OUT_SIZE`   | `DCACHE_WORD_SIZE`        | Output data size after coalescing.              |
| `ADDR_WIDTH`      | `LSU_ADDR_WIDTH`          | Width of memory addresses.                      |
| `FLAGS_WIDTH`     | `MEM_REQ_FLAGS_WIDTH`     | Width of request flags.                         |
| `UUID_WIDTH`      | `UUID_WIDTH`          	| Width of the unique identifier for requests     |
| `QUEUE_SIZE`      | `LSUQ_OUT_SIZE`     	| Size of the request queue.                      |

#### Connections via Interfaces:
- **Input:** `lsu_dcache_if`
- **Outputs:** `dcache_coalesced_if`

---

### 5. VX_dcache_adapter

#### Description:
The VX_dcache_adapter translates coalesced memory requests into cache-level bus transactions.

#### Instantiations:
- **Count:** `NUM_LSU_BLOCKS` times (one per LSU block).

#### Parameters:
| Parameter       | Value               | Description                                         |
|-----------------|---------------------|-----------------------------------------------------|
| `NUM_LANES`     | `DCACHE_CHANNELS`     | Number of channels for memory requests.               |
| `DATA_SIZE`     | `DCACHE_WORD_SIZE`     | Data size for each memory request.                 |
| `TAG_WIDTH`     | `DCACHE_TAG_WIDTH`     | Width of the transaction tag.                      |
| `TAG_SEL_BITS`  | `DCACHE_TAG_WIDTH - `UUID_WIDTH` | Bits used for selecting the tag.                  |
| `ARBITER`       | "P"                | Configures the arbitration policy.                 |
| `REQ_OUT_BUF`   | 0                   | Number of buffers for outgoing requests.           |
| `RSP_OUT_BUF`   | 0                   | Number of buffers for incoming responses.          |

#### Connections via Interfaces:
- **Input:** `dcache_coalesced_if`
- **Output:** `dcache_bus_tmp_if`
