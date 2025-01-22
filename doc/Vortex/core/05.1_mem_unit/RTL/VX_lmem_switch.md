# VX_lmem_switch

The `VX_lmem_switch` module is a key component that arbitrates between global and local memory requests in a GPU's memory subsystem. This module ensures that memory requests are correctly routed to either local memory or global memory and handles responses accordingly.

## Overview

The `VX_lmem_switch` module:
1. Decides whether a memory request is intended for local or global memory.
2. Buffers requests and responses using elastic buffers to decouple the pipeline stages.
3. Uses an arbiter to prioritize and merge memory responses from local and global memory.

## Parameters

| Parameter      | Default Value | Description                                                         |
|----------------|---------------|---------------------------------------------------------------------|
| `REQ0_OUT_BUF` | 0             | Configures output buffering for global memory requests.             |
| `REQ1_OUT_BUF` | 0             | Configures output buffering for local memory requests.              |
| `RSP_OUT_BUF`  | 0             | Configures output buffering for memory responses.                   |
| `ARBITER`      | "R"          | Configures the arbitration policy for merging responses. Possible values include "R" for round-robin or "P" for priority-based arbitration. |

## Interfaces and Ports

### Inputs

| Port Name      | Width                         | Direction | Description                            |
|----------------|-------------------------------|-----------|----------------------------------------|
| `clk`          | 1                             | Input     | Clock signal.                          |
| `reset`        | 1                             | Input     | Reset signal.                          |
| `lsu_in_if`    | Structured (`VX_lsu_mem_if`)  | Input     | Slave memory interface for LSU requests and responses. |

### Outputs

| Port Name        | Width                         | Direction | Description                                  |
|------------------|-------------------------------|-----------|----------------------------------------------|
| `global_out_if`  | Structured (`VX_lsu_mem_if`)  | Output    | Master interface for global memory requests and responses. |
| `local_out_if`   | Structured (`VX_lsu_mem_if`)  | Output    | Master interface for local memory requests and responses. |

## Detailed Explanation

The `VX_lmem_switch` module is structured into three main parts:

### 1. Determining Request Type
The module checks whether a memory request is intended for local or global memory. 
- **Local memory requests:** Identified using the `flags` field in the request data (`MEM_REQ_FLAG_LOCAL`).
- **Global memory requests:** Identified when the `flags` field does not indicate local memory.

```verilog
for (genvar i = 0; i < `NUM_LSU_LANES; ++i) begin : g_is_addr_local_mask
    assign is_addr_local_mask[i] = lsu_in_if.req_data.flags[i][`MEM_REQ_FLAG_LOCAL];
end

wire is_addr_global = | (lsu_in_if.req_data.mask & ~is_addr_local_mask);
wire is_addr_local  = | (lsu_in_if.req_data.mask & is_addr_local_mask);

assign lsu_in_if.req_ready = (req_global_ready && is_addr_global)
                          || (req_local_ready && is_addr_local);
```
- **`is_addr_local_mask`:** Indicates which lanes in the request are for local memory.
- **`is_addr_global`:** Signals whether the request contains global memory accesses.
- **`is_addr_local`:** Signals whether the request contains local memory accesses.
- **`lsu_in_if.req_ready`:** Signals that the request can be accepted if either local or global memory is ready.

### 2. Request Buffers
Requests for both global and local memory are buffered using elastic buffers. This decouples the request stage from subsequent stages, enabling efficient pipelining.

#### Global Memory Request Buffer
```verilog
VX_elastic_buffer #(
    .DATAW   (REQ_DATAW),
    .SIZE    (`TO_OUT_BUF_SIZE(REQ0_OUT_BUF)),
    .OUT_REG (`TO_OUT_BUF_REG(REQ0_OUT_BUF))
) req_global_buf (
    .clk       (clk),
    .reset     (reset),
    .valid_in  (lsu_in_if.req_valid && is_addr_global),
    .data_in   ({
        lsu_in_if.req_data.mask & ~is_addr_local_mask,
        lsu_in_if.req_data.rw,
        lsu_in_if.req_data.addr,
        lsu_in_if.req_data.data,
        lsu_in_if.req_data.byteen,
        lsu_in_if.req_data.flags,
        lsu_in_if.req_data.tag
    }),
    .ready_in  (req_global_ready),
    .valid_out (global_out_if.req_valid),
    .data_out  (global_out_if.req_data),
    .ready_out (global_out_if.req_ready)
);
```
- Buffers requests destined for global memory.
- Uses `REQ0_OUT_BUF` to configure the buffer size and output register.

#### Local Memory Request Buffer
```verilog
VX_elastic_buffer #(
    .DATAW   (REQ_DATAW),
    .SIZE    (`TO_OUT_BUF_SIZE(REQ1_OUT_BUF)),
    .OUT_REG (`TO_OUT_BUF_REG(REQ1_OUT_BUF))
) req_local_buf (
    .clk       (clk),
    .reset     (reset),
    .valid_in  (lsu_in_if.req_valid && is_addr_local),
    .data_in   ({
        lsu_in_if.req_data.mask & is_addr_local_mask,
        lsu_in_if.req_data.rw,
        lsu_in_if.req_data.addr,
        lsu_in_if.req_data.data,
        lsu_in_if.req_data.byteen,
        lsu_in_if.req_data.flags,
        lsu_in_if.req_data.tag
    }),
    .ready_in  (req_local_ready),
    .valid_out (local_out_if.req_valid),
    .data_out  (local_out_if.req_data),
    .ready_out (local_out_if.req_ready)
);
```
- Buffers requests destined for local memory.
- Uses `REQ1_OUT_BUF` to configure the buffer size and output register.

### 3. Response Arbiter
Responses from local and global memory are merged using an arbiter. The arbiter ensures that only one response is forwarded to the LSU at a time, based on the specified arbitration policy.

```verilog
VX_stream_arb #(
    .NUM_INPUTS (2),
    .DATAW      (RSP_DATAW),
    .ARBITER    (ARBITER),
    .OUT_BUF    (RSP_OUT_BUF)
) rsp_arb (
    .clk       (clk),
    .reset     (reset),
    .valid_in  ({
        local_out_if.rsp_valid,
        global_out_if.rsp_valid
    }),
    .ready_in  ({
        local_out_if.rsp_ready,
        global_out_if.rsp_ready
    }),
    .data_in   ({
        local_out_if.rsp_data,
        global_out_if.rsp_data
    }),
    .data_out  (lsu_in_if.rsp_data),
    .valid_out (lsu_in_if.rsp_valid),
    .ready_out (lsu_in_if.rsp_ready),
    `UNUSED_PIN (sel_out)
);
```
- **Inputs:** Responses from `local_out_if` and `global_out_if`.
- **Output:** Merged response sent to `lsu_in_if`.
- **Arbiter Policy:** Configured using the `ARBITER` parameter.

## Key Signals

| Signal Name         | Width          | Description                                           |
|---------------------|----------------|-------------------------------------------------------|
| `is_addr_local_mask`| `NUM_LSU_LANES`| Indicates lanes with local memory requests.           |
| `is_addr_global`    | 1              | Indicates if the request contains global accesses.    |
| `is_addr_local`     | 1              | Indicates if the request contains local accesses.     |
| `req_global_ready`  | 1              | Ready signal for global memory requests.             |
| `req_local_ready`   | 1              | Ready signal for local memory requests.              |

## Summary

The `VX_lmem_switch` module effectively separates and routes memory requests to local or global memory using a combination of masking, elastic buffers, and arbitration. It plays a critical role in the memory subsystem by ensuring efficient routing and response handling for LSU memory operations.
