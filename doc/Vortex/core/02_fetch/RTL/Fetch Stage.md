# Fetch Stage

## Overview

The fetch stage manages communication between the scheduling stage and the instruction cache (ICache) using a dual-port RAM module (**tag_store**) and a streaming buffer module (**VX_elastic_buffer**).  

### Key Components and Workflow  

1. **Tag RAM (tag_store)**:  
   - A dual-port RAM module stores the **program counter (PC)** and **thread mask (tmask)**, collectively known as the **request tag**.  
   - It tracks the ongoing requests, matching responses to the appropriate warp while updating its data as new requests are issued.  

2. **VX_elastic_buffer**:  
   - A streaming buffer temporarily stores warp request data from the scheduling stage until the ICache is ready to process it.  
   - The buffer ensures proper alignment and synchronization of requests, including the **PC**, **UUID**, and **Warp ID**, while facilitating efficient data flow between stages.  

3. **Workflow Summary**:  
   - The scheduling stage sends the **PC**, **tag**, and **UUID** of the requested warp when ready.  
   - These are buffered until the ICache is ready to accept the request, at which point the data is forwarded, and the tag is saved in the **tag_store** for tracking purposes.  

This mechanism ensures seamless coordination between stages and efficient instruction fetching for warp execution.

![Connections](./images/fetch.png)

## Interfaces

| Interface Name         | Description                                    |
|------------------------|------------------------------------------------|
| [`schedule_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_schedule_if.sv)          | Slave interface for [VX_elastic_buffer](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_schedule.sv#L350) in schedule stage           |
| [`icache_bus_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/mem/VX_mem_bus_if.sv)        | Master interface for interacting with icache through [VX_elastic_buffer](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_fetch.sv#L104) |
| [`fetch_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_fetch_if.sv)             | Master interface for [VX_elastic_buffer](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_decode.sv#L542) in decode stage        |

### Schedule Interface

| Port Name    | Width                  | Direction | Description                          |
|--------------|------------------------|-----------|--------------------------------------|
| `data.uuid`  | `[UUID_WIDTH-1:0]`     | Input     | Universal Unique ID                  |
| `data.wid`   | `[NW_WIDTH-1:0]`       | Input     | Warp ID                              |
| `data.tmask` | `[NUM_THREADS:0]`      | Input     | Thread mask                          |
| `data.pc`    | `[PC_BITS-1:0]`        | Input     | Program counter                      |
| `valid`      | `1 bit`                | Input     | Schedule data is valid               |
| `ready`      | `1 bit`                | Output    | Fetch stage is ready to receive data |

### Icache Bus Interface

| Port              | Size                  | Direction     | Description                                                                |
|-------------------|-----------------------|---------------|----------------------------------------------------------------------------|
| `req_data.rw`     | 1 bit                 | Output        | 0 for read, 1 for write request                                            |
| `req_data.addr`   | `[ADDR_WIDTH-1:0]`    | Output        | Memory access address of the operation                                     |
| `req_data.data`   | `[DATA_SIZE*8-1:0]`   | Output        | Data to be written to memory in case of a write operation (`rw=1`)         |
| `req_data.byteen` | `[DATA_SIZE-1:0]`     | Output        | Byte enable                                                                |
| `req_data.flags`  | `[FLAGS_WIDTH-1:0]`   | Output        | Flags for additional request attributes                                    |
| `req_data.tag`    | `[TAG_WIDTH-1:0]`     | Output        | Unique identifier for the request. Helps match responses to requests       |
| `rsp_data.data`   | `[DATA_SIZE*8-1:0]`   | Input         | Data read from memory in response to a read request                        |
| `rsp_data.tag`    | `[TAG_WIDTH-1:0]`     | Input         | Matches the tag field of the corresponding request                         |
| `req_valid`       | 1 bit                 | Output        | Asserted by fetch module to indicate a valid memory request                |
| `req_ready`       | 1 bit                 | Input         | Indicates memory controller is ready to accept a request                   |
| `rsp_valid`       | 1 bit                 | Input         | Indicates a valid response is available from the memory controller         |
| `rsp_ready`       | 1 bit                 | Output        | Asserted by fetch module to indicate it is ready to accept a response      |

### Fetch Interface

| Port Name    | Width                   | Direction | Description                                                   |
|--------------|-------------------------|-----------|---------------------------------------------------------------|
| `data.uuid`  | `[UUID_WIDTH-1:0]`      | Output    | Universal Unique ID                                           |
| `data.wid`   | `[NW_WIDTH-1:0]`        | Output    | Warp ID                                                       |
| `data.tmask` | `[NUM_THREADS:0]`       | Output    | Thread mask                                                   |
| `data.pc`    | `[PC_BITS-1:0]`         | Output    | Program counter                                               |
|`data.instr`  | `[31:0]`                | Output    | Fetched instruction                                           |
| `valid`      | `1 bit`                 | Input     | Fetch data is valid                                           |
| `ready`      | `1 bit`                 | Input     | Decode stage is ready to receive data                         |
|`ibuf_pop`    | `1 bit`                 | Input     | [Signal](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/interfaces/VX_decode_if.sv#L57) from decode stage indicating that instruction buffer has popped an entry [Only when L1 cache is disabled]|

## Modules

### VX_elastic_buffer  

```verilog
    assign req_tag = schedule_if.data.wid;
    assign icache_req_valid = schedule_if.valid && ibuf_ready;
    assign icache_req_addr  = schedule_if.data.PC[1 +: ICACHE_ADDR_WIDTH];
    assign icache_req_tag   = {schedule_if.data.uuid, req_tag};
    assign schedule_if.ready = icache_req_ready && ibuf_ready;

    VX_elastic_buffer #(
        .DATAW   (ICACHE_ADDR_WIDTH + ICACHE_TAG_WIDTH),
        .SIZE    (2),
        .OUT_REG (1) // external bus should be registered
    ) req_buf (
        .clk       (clk),
        .reset     (reset),
        .valid_in  (icache_req_valid),
        .ready_in  (icache_req_ready),
        .data_in   ({icache_req_addr, icache_req_tag}),
        .data_out  ({icache_bus_if.req_data.addr, icache_bus_if.req_data.tag}),
        .valid_out (icache_bus_if.req_valid),
        .ready_out (icache_bus_if.req_ready)
    );
```  

The **VX_elastic_buffer** is a streaming buffer module designed to facilitate seamless communication between the scheduling stage and the instruction cache (ICache) through the fetch stage. Its primary function is to synchronize request signals and data flow, ensuring efficient interaction between pipeline stages.  

- **`valid_in`**: Indicates when the input data is valid, contingent on the scheduling stage providing data and the instruction buffer being ready.  
- **`data_in`**: Encodes the program counter (PC), UUID, and Warp ID for the requested instruction.  
- **`ready_in`**: Signals the readiness of the ICache to accept new requests.  
- Output signals (`data_out`, `valid_out`, `ready_out`) ensure that buffered data is transferred to the ICache when ready.  

```verilog
    assign icache_bus_if.req_data.flags  = '0;
    assign icache_bus_if.req_data.rw     = 0;
    assign icache_bus_if.req_data.byteen = '1;
    assign icache_bus_if.req_data.data   = '0;
```  

Additional configurations for the ICache request:  
- **`req_data.flags`**: No special flags are required.
- **`req_data.rw`**: Configured for read operations exclusively.  
- **`req_data.byteen`**: Enables access to all bytes of the memory word.  
- **`req_data.data`**: Not used for memory writes in this operation.  

### Operational Overview  

1. The scheduling stage initiates the process by sending the program counter (PC), tag, and UUID of the requested warp when its internal buffer is ready.  
2. These details are temporarily stored in the **VX_elastic_buffer** until the ICache signals its readiness to receive the request.  
3. Simultaneously, the request tag is written into the **dp_ram** module to track ongoing requests and ensure correct response matching with the corresponding warp.  

This mechanism ensures robust synchronization and precise tracking of requests, enabling efficient instruction fetching and warp management within the pipeline.  

### VX_dp_ram  

```verilog
    wire icache_req_fire = icache_req_valid && icache_req_ready;

    VX_dp_ram #(
        .DATAW  (`PC_BITS + `NUM_THREADS),
        .SIZE   (`NUM_WARPS),
        .LUTRAM (1)
    ) tag_store (
        .clk   (clk),
        .reset (reset),
        .read  (1'b1),
        .write (icache_req_fire),
        .wren  (1'b1),
        .waddr (req_tag),
        .wdata ({schedule_if.data.PC, schedule_if.data.tmask}),
        .raddr (rsp_tag),
        .rdata ({rsp_PC, rsp_tmask})
    );
```  

The **VX_dp_ram** is a dual-port RAM module used to store and retrieve the program counter (PC) and thread mask for each warp during instruction fetching. It enables efficient tracking of ongoing requests and associating responses to the correct warp.  

- **`write`**: Asserted when the scheduling stage provides valid data, and the ICache is ready to accept a new request.  
- **`waddr`**: Write address corresponds to the warp ID of the request (`req_tag`).  
- **`wdata`**: Includes the program counter (PC) and thread mask from the scheduling stage.  
- **`raddr`**: Read address is derived from the warp ID in the response (`rsp_tag`).  
- **`rdata`**: Outputs the PC and thread mask for the decode stage.  

### Operational Overview  

1. When the elastic buffer in the scheduling stage has data ready to send, and the request buffer in the fetch stage is not full, the write enable signal (`write`) is asserted. This allows the **VX_dp_ram** to store the PC and thread mask (tag) of the requested warp at the specified warp ID (`req_tag`).  
2. Upon receiving a response from the ICache, the response tag (`rsp_tag`) serves as the read address to access the stored tag.  
3. The instruction fetched from the ICache and the corresponding tag retrieved from the **VX_dp_ram** are forwarded to the decode stage for processing.  

This design ensures seamless synchronization between warp requests and responses, maintaining the integrity of instruction execution.

### VX_pending_size (Optional: Only when L1 Cache is Disabled)  

```verilog
`ifndef L1_ENABLE
    wire [`NUM_WARPS-1:0] pending_ibuf_full;
    for (genvar i = 0; i < `NUM_WARPS; ++i) begin : g_pending_reads
        VX_pending_size #(
            .SIZE (`IBUF_SIZE)
        ) pending_reads (
            .clk   (clk),
            .reset (reset),
            .incr  (icache_req_fire && schedule_if.data.wid == i),
            .decr  (fetch_if.ibuf_pop[i]),
            .full  (pending_ibuf_full[i])
        );
    end
    wire ibuf_ready = ~pending_ibuf_full[schedule_if.data.wid];
`else
    wire ibuf_ready = 1'b1;
`endif
```  

The **VX_pending_size** module manages the size of the instruction buffer (ibuffer) for each warp, ensuring that memory contention between the instruction and data caches does not cause deadlocks.  

- **`pending_ibuf_full`**: Indicates whether the instruction buffer for each warp is full.  
- **`incr`**: Incremented when a fetch request is issued for the corresponding warp.  
- **`decr`**: Decremented when an instruction is removed (popped) from the ibuffer.  
- **`ibuf_ready`**: Signals whether the instruction buffer for the current warp can accept new data. If L1 cache is enabled, `ibuf_ready` is hardcoded to `1'b1`.  

### Operational Overview  

1. For each warp, **VX_pending_size** tracks the number of instructions stored in the ibuffer.  
2. When a fetch request is issued (`icache_req_fire`), the buffer count for the respective warp is incremented.  
3. When an instruction is processed and removed (`ibuf_pop`), the buffer count is decremented.  
4. The `ibuf_ready` signal ensures that new fetch requests are only issued if the instruction buffer for the active warp is not full.  
5. If L1 caching is enabled, this functionality is bypassed, and `ibuf_ready` is always asserted, as memory contention management is not required.  

This mechanism optimizes warp execution flow by preventing stalls due to buffer overflow.
