# VX_local_mem

The `VX_local_mem` module implements local memory functionality, supporting multiple memory banks and handling word-based read/write operations. It offers configurability for memory size, request handling, and bank configuration.

## Parameters

| Parameter       | Default Value       | Description                                                                 |
|-----------------|---------------------|-----------------------------------------------------------------------------|
| `INSTANCE_ID`   | ""                  | Unique identifier for the module instance.                                 |
| `SIZE`          | (1024 * 16 * 8)     | Total size of the memory in bytes.                                         |
| `NUM_REQS`      | 4                   | Number of word-based memory requests handled per cycle.                    |
| `NUM_BANKS`     | 4                   | Number of memory banks.                                                    |
| `ADDR_WIDTH`    | `CLOG2(SIZE)`       | Address width for the memory.                                              |
| `WORD_SIZE`     | `XLEN / 8`          | Size of a memory word in bytes.                                            |
| `UUID_WIDTH`    | 0                   | Debug identifier width for tracking requests (not used in this module).    |
| `TAG_WIDTH`     | 16                  | Width of the tag for identifying memory requests.                          |
| `OUT_BUF`       | 0                   | Buffer depth for output responses.                                         |

## Interfaces and Ports

### Inputs

| Port Name | Width | Direction | Description          |
|-----------|-------|-----------|----------------------|
| `clk`     | 1     | Input     | Clock signal.        |
| `reset`   | 1     | Input     | Reset signal.        |

### Outputs

| Port Name   | Width          | Direction | Description                          |
|-------------|----------------|-----------|--------------------------------------|
| `lmem_perf` | `cache_perf_t` | Output    | Performance counters for local memory (if enabled). |

### Memory Bus Interface (Slave)

`mem_bus_if` is an array of slave interfaces used to handle memory requests from multiple sources.

| Port Name             | Width               | Direction | Description                                           |
|-----------------------|---------------------|-----------|-------------------------------------------------------|
| `req_valid`           | 1                   | Input     | Valid signal for memory requests.                    |
| `req_ready`           | 1                   | Output    | Ready signal for memory requests.                    |
| `rsp_valid`           | 1                   | Output    | Valid signal for memory responses.                   |
| `rsp_ready`           | 1                   | Input     | Ready signal for memory responses.                   |
| `req_data.rw`         | 1                   | Input     | Read/Write operation flag (1 for write, 0 for read). |
| `req_data.addr`       | `ADDR_WIDTH`        | Input     | Memory address for the request.                      |
| `req_data.data`       | `WORD_SIZE * 8`     | Input     | Data payload for write operations.                   |
| `req_data.byteen`     | `WORD_SIZE`         | Input     | Byte enable mask for write operations.               |
| `req_data.tag`        | `TAG_WIDTH`         | Input     | Tag for identifying memory requests.                 |
| `rsp_data.data`       | `WORD_SIZE * 8`     | Output    | Data payload for read responses.                     |
| `rsp_data.tag`        | `TAG_WIDTH`         | Output    | Tag for identifying responses.                       |

## Internal Signals

### Derived Local Parameters

| Parameter            | Derived From               | Description                                         |
|----------------------|----------------------------|-----------------------------------------------------|
| `REQ_SEL_BITS`       | `CLOG2(NUM_REQS)`          | Bits required to select a request.                 |
| `REQ_SEL_WIDTH`      | `UP(REQ_SEL_BITS)`         | Aligned width for request selection.               |
| `WORD_WIDTH`         | `WORD_SIZE * 8`           | Width of a memory word in bits.                    |
| `NUM_WORDS`          | `SIZE / WORD_SIZE`         | Total number of words in the memory.               |
| `WORDS_PER_BANK`     | `NUM_WORDS / NUM_BANKS`    | Number of words per memory bank.                   |
| `BANK_ADDR_WIDTH`    | `CLOG2(WORDS_PER_BANK)`    | Address width for a bank.                          |
| `BANK_SEL_BITS`      | `CLOG2(NUM_BANKS)`         | Bits required to select a bank.                    |
| `BANK_SEL_WIDTH`     | `UP(BANK_SEL_BITS)`        | Aligned width for bank selection.                  |
| `REQ_DATAW`          | `1 + BANK_ADDR_WIDTH + WORD_SIZE + WORD_WIDTH + TAG_WIDTH` | Width of the request data payload. |
| `RSP_DATAW`          | `WORD_WIDTH + TAG_WIDTH`   | Width of the response data payload.                |

## Key Functional Blocks

### Bank Selection

Bank selection identifies the memory bank associated with each request using the address bits.

### Crossbar for Request Dispatch

A crossbar (`VX_stream_xbar`) dispatches incoming requests to appropriate memory banks based on the bank index.

#### Parameters:
| Parameter        | Value       | Description                                      |
|------------------|-------------|--------------------------------------------------|
| `NUM_INPUTS`     | `NUM_REQS`  | Number of request inputs.                       |
| `NUM_OUTPUTS`    | `NUM_BANKS` | Number of memory banks.                         |
| `DATAW`          | `REQ_DATAW` | Width of the request data.                      |
| `PERF_CTR_BITS`  | `PERF_CTR_BITS` | Width for performance counter signals.       |
| `ARBITER`        | "P"         | Priority arbiter for request selection.         |
| `OUT_BUF`        | 3           | Depth of the output buffer for requests.        |

#### Connections:
- **Input:** `req_valid_in`, `req_data_in`, `req_bank_idx`
- **Output:** `per_bank_req_valid`, `per_bank_req_data_aos`, `per_bank_req_ready`

### Local Memory Banks

Each memory bank is implemented using an instance of `VX_sp_ram` to store memory contents.

#### Parameters:
| Parameter   | Value             | Description                        |
|-------------|-------------------|------------------------------------|
| `DATAW`     | `WORD_WIDTH`      | Width of a memory word in bits.    |
| `SIZE`      | `WORDS_PER_BANK`  | Number of words in the bank.       |
| `WRENW`     | `WORD_SIZE`       | Number of write enable signals.    |
| `OUT_REG`   | 1                 | Enables output register for data.  |
| `RDW_MODE`  | "R"               | Read-during-write behavior.        |

### Crossbar for Response Gathering

A second crossbar (`VX_stream_xbar`) gathers responses from memory banks and routes them to the appropriate requesters.

#### Parameters:
| Parameter        | Value        | Description                                      |
|------------------|--------------|--------------------------------------------------|
| `NUM_INPUTS`     | `NUM_BANKS`  | Number of response inputs.                      |
| `NUM_OUTPUTS`    | `NUM_REQS`   | Number of response outputs.                     |
| `DATAW`          | `RSP_DATAW`  | Width of the response data.                     |
| `ARBITER`        | "P"          | Priority arbiter for response selection.        |
| `OUT_BUF`        | `OUT_BUF`    | Depth of the output buffer for responses.       |

#### Connections:
- **Input:** `per_bank_rsp_valid`, `per_bank_rsp_data_aos`, `per_bank_rsp_idx`
- **Output:** `rsp_valid_out`, `rsp_data_out`, `rsp_ready_out`

## Features and Notes

1. **Read-During-Write Hazard Detection**:
   - Implements logic to detect and handle read-during-write hazards within the same memory bank.
   - Prevents invalid data being read while a write operation is in progress.

2. **Performance Counters**:
   - Optional performance counters (`PERF_ENABLE`) for tracking memory access metrics such as collisions.

3. **Highly Configurable**:
   - Flexible parameters for number of requests, memory size, bank configuration, and buffering enable optimal performance across a wide range of use cases.

4. **Pipeline Buffers**:
   - Implements pipeline buffers to ensure timing closure and improve throughput in critical paths.
