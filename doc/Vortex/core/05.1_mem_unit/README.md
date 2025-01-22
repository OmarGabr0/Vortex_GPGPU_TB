# VX_mem_unit

## Overview

The **VX_mem_unit** is a highly parameterized memory unit designed to handle a wide range of memory operations for GPUs. It manages memory interactions across local memory (LMEM) and data cache (DCACHE) while supporting multi-lane and multi-block configurations. The module ensures high performance through arbitration, coalescing, and efficient memory access strategies.

### Responsibilities

1. **Local Memory Management (Optional):**
   - Implements a local memory system for faster data access and reduced latency.
   - Supports multi-bank memory architectures with configurable sizes and buffering.

2. **Data Cache Interaction:**
   - Interfaces with a data cache to handle global memory requests efficiently.
   - Implements coalescing mechanisms to optimize memory traffic.

3. **Arbitration Between Memory Systems:**
   - Uses configurable arbitration schemes to prioritize requests between local and global memory.
   - Includes switches and adapters for efficient communication.


## Structure

The memory unit is divided into the following key components:

### 1. Local Memory System
The optional **local memory (LMEM)** enables faster data access for workloads that require high throughput. This system supports multiple load-store unit (LSU) blocks and provides configurable parameters for banks, size, and buffer management. When LMEM is enabled:

- Each LSU block interacts with a corresponding LMEM switch.
- Arbitration between local and global memory is handled dynamically.
- The LMEM adapter ensures compatibility between LMEM and other system interfaces.

### 2. Data Cache Interaction
The **data cache (DCACHE)** system handles global memory requests. It includes features like:

- Coalescing memory requests to reduce memory traffic.
- Multi-channel support for handling high throughput.
- Adapters for seamless integration with LSU blocks.

### 3. Arbitration and Switching
The **VX_lmem_switch** and **VX_lsu_adapter** modules form the backbone of the arbitration system. They ensure efficient routing of memory requests between LMEM and DCACHE.


## Parameters

The following parameters control the functionality and configuration of the `VX_mem_unit`:

| Parameter      | Type    | Description                                           |
|----------------|---------|-------------------------------------------------------|
| `INSTANCE_ID`  | STRING  | Unique identifier for the module instance.            |

## Interfaces

The `VX_mem_unit` communicates with other modules via the following interfaces:

### Inputs

| Signal Name | Width | Description                 |
|-------------|-------|-----------------------------|
| `clk`       | 1     | Clock signal.              |
| `reset`     | 1     | Reset signal.              |



### LSU Memory Interface (Slave)

`lsu_mem_if` is an array of LSU memory interfaces used for communication.

### Data Cache Bus Interface (Master)

`dcache_bus_if` is an array of master interfaces for data cache communication.

For more details about the structure and interfaces of submodules, refer to their specific documentation.
