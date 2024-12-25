# Fetch Stage

## Overview

The **Fetch Stage** is responsible for retrieving instructions from the instruction cache, ensuring that the correct instructions are delivered to the pipeline for active warps. This stage employs buffering mechanisms to handle instruction requests and responses efficiently, maintaining smooth pipeline operation.

### Responsibilities

1. **Instruction Fetching**:  
   Requests instructions from the instruction cache (Icache) based on the Program Counter (PC) provided by the schedule stage.

2. **Warp Context Management**:  
   Maintains context information such as thread masks and PCs for each warp to ensure accurate handling of instruction data.

3. **Buffering and Flow Control**:  
   Utilizes buffering mechanisms to manage instruction requests and responses, preventing pipeline stalls due to cache latency.

4. **Deadlock Prevention**:  
   Incorporates logic to monitor buffer fullness and resolve potential deadlock situations caused by simultaneous memory requests.

## Interfaces

### Icache Interface

The Icache interface connects the fetch stage with the instruction cache, facilitating instruction retrieval. It manages request and response signals to ensure timely and accurate data transfer.

- **Request Signals**:  
  - `icache_req_valid`: Indicates a valid instruction fetch request.
  - `icache_req_addr`: Specifies the memory address of the instruction to be fetched.
  - `icache_req_tag`: Associates a unique identifier (warp ID and UUID) with each fetch request.

- **Response Signals**:  
  - `icache_bus_if.rsp_data`: Contains the instruction fetched from memory.
  - `icache_bus_if.rsp_valid`: Signals that the fetch response is ready for processing.

### Schedule Interface

The schedule interface enables the fetch stage to receive warp scheduling information, including the Program Counter (PC), warp ID, and thread mask. It ensures that the fetch stage retrieves instructions for the correct warp and maintains synchronization with the pipeline.

- **Inputs**:  
  - `schedule_if.valid`: Indicates if a warp is ready for fetching.  
  - `schedule_if.data.PC`: The Program Counter for the warp.  
  - `schedule_if.data.wid`: The Warp ID for identifying the request.  
  - `schedule_if.data.tmask`: The thread mask for active threads in the warp.

- **Outputs**:  
  - `schedule_if.ready`: Signals back to the schedule stage when the fetch stage can accept new requests.

### Fetch Interface

The fetch interface connects the fetch stage to subsequent stages in the pipeline, forwarding fetched instructions and associated metadata.

- **Outputs**:  
  - `fetch_if.valid`: Indicates that a fetched instruction is ready.  
  - `fetch_if.data`: Provides the instruction data, including the PC, thread mask, warp ID, and instruction opcode.
