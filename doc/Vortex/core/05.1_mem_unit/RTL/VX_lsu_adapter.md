# VX_lsu_adapter

The `VX_lsu_adapter` module bridges the LSU memory interface (`VX_lsu_mem_if`) and the memory bus interface (`VX_mem_bus_if`). It facilitates memory requests and responses across multiple lanes by packing and unpacking data streams efficiently.

## Parameters

| Parameter       | Default Value | Description                                                                 |
|-----------------|---------------|-----------------------------------------------------------------------------|
| `NUM_LANES`     | 1             | Number of memory lanes handled by the adapter.                             |
| `DATA_SIZE`     | 1             | Size of the data in memory operations.                                      |
| `TAG_WIDTH`     | 1             | Width of the transaction tag used for identification.                      |
| `TAG_SEL_BITS`  | 0             | Bits used for tag selection during response packing.                       |
| `ARBITER`       | "P"          | Arbitration policy for response packing (e.g., priority-based).             |
| `REQ_OUT_BUF`   | 0             | Buffering configuration for outgoing requests.                             |
| `RSP_OUT_BUF`   | 0             | Buffering configuration for incoming responses.                            |

## Ports

### Inputs

| Port Name      | Width                 | Direction | Description                                  |
|----------------|-----------------------|-----------|----------------------------------------------|
| `clk`          | 1                     | Input     | Clock signal.                                |
| `reset`        | 1                     | Input     | Reset signal.                                |
| `lsu_mem_if`   | `VX_lsu_mem_if.slave` | Input     | LSU memory interface for handling requests. |

### Outputs

| Port Name      | Width                      | Direction | Description                                  |
|----------------|----------------------------|-----------|----------------------------------------------|
| `mem_bus_if`   | `VX_mem_bus_if.master` x `NUM_LANES` | Output    | Memory bus interface for handling responses. |

## Submodules

### VX_stream_unpack

#### Description
This submodule unpacks incoming LSU memory requests into individual lane-specific requests, distributing them across `NUM_LANES`.

#### Parameters

| Parameter       | Value           | Description                                     |
|-----------------|-----------------|-------------------------------------------------|
| `NUM_REQS`      | `NUM_LANES`     | Number of requests to unpack.                  |
| `DATA_WIDTH`    | Derived from `REQ_DATA_WIDTH` | Width of each request data.                    |
| `TAG_WIDTH`     | `TAG_WIDTH`     | Width of the tag associated with requests.     |
| `OUT_BUF`       | `REQ_OUT_BUF`   | Buffering configuration for outgoing requests. |

#### Connections

- **Inputs:**
  - `valid_in` connected to `lsu_mem_if.req_valid`.
  - `data_in` connected to packed `req_data_in` array.
  - `tag_in` connected to `lsu_mem_if.req_data.tag`.
  - `ready_in` connected to `lsu_mem_if.req_ready`.
- **Outputs:**
  - `valid_out`, `data_out`, and `tag_out` drive respective signals for `mem_bus_if`.

### VX_stream_pack

#### Description
This submodule packs incoming memory responses from individual lanes into a single LSU memory response.

#### Parameters

| Parameter       | Value           | Description                                    |
|-----------------|-----------------|------------------------------------------------|
| `NUM_REQS`      | `NUM_LANES`     | Number of requests to pack.                   |
| `DATA_WIDTH`    | Derived from `RSP_DATA_WIDTH` | Width of each response data.                  |
| `TAG_WIDTH`     | `TAG_WIDTH`     | Width of the tag associated with responses.   |
| `TAG_SEL_BITS`  | `TAG_SEL_BITS`  | Bits used for tag selection during packing.   |
| `ARBITER`       | `ARBITER`       | Arbitration policy for response packing.      |
| `OUT_BUF`       | `RSP_OUT_BUF`   | Buffering configuration for outgoing responses.|

#### Connections

- **Inputs:**
  - `valid_in`, `data_in`, and `tag_in` connected to respective outputs of `mem_bus_if`.
  - `ready_in` connected to `rsp_ready_out` signals.
- **Outputs:**
  - `valid_out` connected to `lsu_mem_if.rsp_valid`.
  - `data_out` and `tag_out` connected to `lsu_mem_if.rsp_data`.

## Detailed Code Explanation

### Request Handling

#### Code:
```verilog
for (genvar i = 0; i < NUM_LANES; ++i) begin : g_req_data_in
    assign req_data_in[i] = {
        lsu_mem_if.req_data.rw,
        lsu_mem_if.req_data.addr[i],
        lsu_mem_if.req_data.data[i],
        lsu_mem_if.req_data.byteen[i],
        lsu_mem_if.req_data.flags[i]
    };
end
```

- **Purpose:** Constructs the `req_data_in` array by combining `rw`, `addr`, `data`, `byteen`, and `flags` fields for each lane from the `lsu_mem_if` interface.

#### Code:
```verilog
VX_stream_unpack #(
    .NUM_REQS   (NUM_LANES),
    .DATA_WIDTH (REQ_DATA_WIDTH),
    .TAG_WIDTH  (TAG_WIDTH),
    .OUT_BUF    (REQ_OUT_BUF)
) stream_unpack (
    .clk        (clk),
    .reset      (reset),
    .valid_in   (lsu_mem_if.req_valid),
    .mask_in    (lsu_mem_if.req_data.mask),
    .data_in    (req_data_in),
    .tag_in     (lsu_mem_if.req_data.tag),
    .ready_in   (lsu_mem_if.req_ready),
    .valid_out  (req_valid_out),
    .data_out   (req_data_out),
    .tag_out    (req_tag_out),
    .ready_out  (req_ready_out)
);
```

- **Purpose:** Unpacks the LSU memory interface requests into individual lane requests.
- **Connections:**
  - `valid_in` and `ready_in` coordinate valid and ready signals with `lsu_mem_if`.
  - `data_in` and `tag_in` handle packed data and tags from the LSU memory interface.

### Response Handling

#### Code:
```verilog
VX_stream_pack #(
    .NUM_REQS     (NUM_LANES),
    .DATA_WIDTH   (RSP_DATA_WIDTH),
    .TAG_WIDTH    (TAG_WIDTH),
    .TAG_SEL_BITS (TAG_SEL_BITS),
    .ARBITER      (ARBITER),
    .OUT_BUF      (RSP_OUT_BUF)
) stream_pack (
    .clk        (clk),
    .reset      (reset),
    .valid_in   (rsp_valid_out),
    .data_in    (rsp_data_out),
    .tag_in     (rsp_tag_out),
    .ready_in   (rsp_ready_out),
    .valid_out  (lsu_mem_if.rsp_valid),
    .mask_out   (lsu_mem_if.rsp_data.mask),
    .data_out   (lsu_mem_if.rsp_data.data),
    .tag_out    (lsu_mem_if.rsp_data.tag),
    .ready_out  (lsu_mem_if.rsp_ready)
);
```

- **Purpose:** Packs memory responses from `mem_bus_if` lanes into a single LSU memory interface response.
- **Connections:**
  - `valid_in`, `data_in`, and `tag_in` accept responses from `mem_bus_if`.
  - `valid_out`, `data_out`, and `tag_out` provide the packed response to `lsu_mem_if`.
