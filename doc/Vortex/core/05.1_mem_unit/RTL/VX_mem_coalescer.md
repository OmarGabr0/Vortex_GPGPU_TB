# VX_mem_coalescer

The `VX_mem_coalescer` module aggregates smaller memory requests into larger ones to optimize memory access patterns. It handles input requests and responses, coalesces them, and forwards them to the memory subsystem. 

## Parameters

| Parameter          | Default Value   | Description                                                                 |
|--------------------|-----------------|-----------------------------------------------------------------------------|
| `INSTANCE_ID`      | ""              | Unique identifier for the module instance.                                 |
| `NUM_REQS`         | 1               | Number of input requests processed in parallel.                            |
| `ADDR_WIDTH`       | 32              | Address width of input requests.                                           |
| `FLAGS_WIDTH`      | 0               | Width of the flags in memory requests.                                     |
| `DATA_IN_SIZE`     | 4               | Size of the input data (in bytes).                                         |
| `DATA_OUT_SIZE`    | 64              | Size of the output data (in bytes).                                        |
| `TAG_WIDTH`        | 8               | Width of the tag used for memory requests.                                 |
| `UUID_WIDTH`       | 0               | Upper section of the request tag contains the UUID.                        |
| `QUEUE_SIZE`       | 8               | Number of entries in the internal request buffer.                          |
| `DATA_IN_WIDTH`    | `DATA_IN_SIZE * 8` | Bit-width of input data.                                                  |
| `DATA_OUT_WIDTH`   | `DATA_OUT_SIZE * 8` | Bit-width of output data.                                                |
| `DATA_RATIO`       | `DATA_OUT_SIZE / DATA_IN_SIZE` | Ratio between output and input data sizes.                             |
| `DATA_RATIO_W`     | `LOG2UP(DATA_RATIO)` | Logarithmic representation of `DATA_RATIO`.                               |
| `OUT_REQS`         | `NUM_REQS / DATA_RATIO` | Number of output requests.                                               |
| `OUT_ADDR_WIDTH`   | `ADDR_WIDTH - DATA_RATIO_W` | Address width for output requests.                                       |
| `QUEUE_ADDRW`      | `CLOG2(QUEUE_SIZE)` | Address width for indexing the internal buffer.                          |
| `OUT_TAG_WIDTH`    | `UUID_WIDTH + QUEUE_ADDRW` | Total tag width for output requests.                                      |

## Interfaces and Ports

### Inputs

| Port Name             | Width                      | Description                                              |
|-----------------------|----------------------------|----------------------------------------------------------|
| `clk`                 | 1                          | Clock signal.                                            |
| `reset`               | 1                          | Reset signal.                                            |
| `in_req_valid`        | 1                          | Indicates if the input request is valid.                |
| `in_req_rw`           | 1                          | Read/Write flag for the input request.                  |
| `in_req_mask`         | `NUM_REQS`                 | Mask indicating active input requests.                  |
| `in_req_byteen`       | `NUM_REQS x DATA_IN_SIZE`  | Byte enable signals for the input requests.             |
| `in_req_addr`         | `NUM_REQS x ADDR_WIDTH`    | Addresses of the input requests.                        |
| `in_req_flags`        | `NUM_REQS x FLAGS_WIDTH`   | Flags associated with the input requests.               |
| `in_req_data`         | `NUM_REQS x DATA_IN_WIDTH` | Data payloads for the input requests.                   |
| `in_req_tag`          | `TAG_WIDTH`               | Tags for the input requests.                            |
| `in_rsp_ready`        | 1                          | Indicates readiness for the input response.             |

### Outputs

| Port Name             | Width                       | Description                                              |
|-----------------------|-----------------------------|----------------------------------------------------------|
| `in_req_ready`        | 1                           | Indicates readiness to accept input requests.            |
| `in_rsp_valid`        | 1                           | Indicates if the input response is valid.                |
| `in_rsp_mask`         | `NUM_REQS`                  | Mask indicating active input responses.                  |
| `in_rsp_data`         | `NUM_REQS x DATA_IN_WIDTH`  | Data payloads for the input responses.                   |
| `in_rsp_tag`          | `TAG_WIDTH`                | Tags for the input responses.                            |
| `out_req_valid`       | 1                           | Indicates if the output request is valid.                |
| `out_req_rw`          | 1                           | Read/Write flag for the output request.                  |
| `out_req_mask`        | `OUT_REQS`                  | Mask indicating active output requests.                  |
| `out_req_byteen`      | `OUT_REQS x DATA_OUT_SIZE`  | Byte enable signals for the output requests.             |
| `out_req_addr`        | `OUT_REQS x OUT_ADDR_WIDTH` | Addresses of the output requests.                        |
| `out_req_flags`       | `OUT_REQS x FLAGS_WIDTH`    | Flags associated with the output requests.               |
| `out_req_data`        | `OUT_REQS x DATA_OUT_WIDTH` | Data payloads for the output requests.                   |
| `out_req_tag`         | `OUT_TAG_WIDTH`            | Tags for the output requests.                            |
| `out_rsp_ready`       | 1                           | Indicates readiness to accept output responses.          |

### Inputs (Response)

| Port Name             | Width                       | Description                                              |
|-----------------------|-----------------------------|----------------------------------------------------------|
| `out_rsp_valid`       | 1                           | Indicates if the output response is valid.               |
| `out_rsp_mask`        | `OUT_REQS`                  | Mask indicating active output responses.                 |
| `out_rsp_data`        | `OUT_REQS x DATA_OUT_WIDTH` | Data payloads for the output responses.                  |
| `out_rsp_tag`         | `OUT_TAG_WIDTH`            | Tags for the output responses.                           |

## Features

### 1. Input Request Handling

The module accepts multiple parallel input requests, validates them, and identifies overlapping or coalescable requests based on their addresses. This reduces redundant requests to downstream memory units.

### 2. Output Request Generation

Input requests are aggregated and merged to form larger output requests. Each output request represents multiple coalesced input requests, optimizing memory bandwidth.

### 3. Response Distribution

Responses from the memory subsystem are decomposed and distributed back to the respective input requests. This ensures data integrity and proper tag alignment for all requests.

### 4. Configurable Buffering

The module supports configurable buffer sizes for both input and output data. This provides flexibility to accommodate varying workloads and memory latencies.

### 5. Debug and Assertions

- **Static Assertions:** Validate parameters such as `NUM_REQS`, `DATA_RATIO`, and `ADDR_WIDTH` during synthesis.
- **Runtime Assertions:** Ensure proper mask and validity signals during runtime.

### 6. Tag Management

The tags for output requests include both UUIDs and queue addresses, ensuring unique identification of each request in the memory subsystem.

### 7. Pipelined Design

The use of pipeline registers ensures high throughput and minimal impact on timing.

## Code Snippet

Below is an example of how input requests are coalesced:

```verilog
for (genvar i = 0; i < OUT_REQS; ++i) begin : g_data_merged
    reg [DATA_RATIO-1:0][DATA_IN_SIZE-1:0] byteen_merged;
    reg [DATA_RATIO-1:0][DATA_IN_WIDTH-1:0] data_merged;
    always @(*) begin
        byteen_merged = '0;
        data_merged = 'x;
        for (integer j = 0; j < DATA_RATIO; ++j) begin
            for (integer k = 0; k < DATA_IN_SIZE; ++k) begin
                if (current_pmask[i * DATA_RATIO + j] && in_req_byteen[DATA_RATIO * i + j][k]) begin
                    byteen_merged[in_addr_offset[DATA_RATIO * i + j]][k] = 1'b1;
                    data_merged[in_addr_offset[DATA_RATIO * i + j]][k * 8 +: 8] = in_req_data[DATA_RATIO * i + j][k * 8 +: 8];
                end
            end
        end
    end
    assign req_byteen_merged[i] = byteen_merged;
    assign req_data_merged[i]   = data_merged;
end
