# Schedule Stage

## Overview

The schedule stage is responsible for scheduling instructions to be moved through the pipeline. It manages instruction stalls by handling the unlocking of stalled instructions and adjusting the program counter (PC) in response to branching. Additionally, the schedule stage processes Vortex custom instructions coming from the execute stage, ensuring that they are correctly handled and propagated through the pipeline for further execution.

## Interfaces

| Interface Name                     | Description                                                      |
|-------------------------------------|------------------------------------------------------------------|
| `base_dcrs`                       | Input configuration interface for base device control registers. |
| `warp_ctl_if`                       | Slave interface for [VX_wctl_unit](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_wctl_unit.sv#L16) in the [VX_sfu_unit](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_sfu_unit.sv#L16) in the execute stage                |
| `branch_ctl_if`                     | Slave interface for [alu_int](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_alu_int.sv#L16) to handle branching signals |
| `decode_sched_if`                 | Slave interface for receiving decoded schedule inputs.           |
| `commit_sched_if`                   | Slave interface for receiving commit schedule inputs.            |
| `schedule_if`                        | Master interface for sending scheduled instructions.             |
|`gbar_bus_if` (enabled with `GBAR_ENABLE`) | Master interface for the Global Barrier Bus (if GBAR is enabled). |
| `sched_csr_if`                     | Master interface for accessing the scheduling control/status registers. |
| `busy`                              | Output wire indicating the status of the scheduler (busy or idle). |
| `sched_perf`                        | Output interface for scheduling performance metrics (enabled with `PERF_ENABLE`). |

### [schedule_if](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_schedule_if.sv)

#### Pinout Table

| Port Name    | Width                   | Direction | Description                                                                                  |
|--------------|------------------------|--------|----------------------------------------------------------------------------------------------|
| `data.uuid`  | `[UUID_WIDTH-1:0]`     | Input  | Universal Unique ID                                                                          |
| `data.wid`   | `[NW_WIDTH-1:0]`       | Input  | Warp ID                                                                                      |
| `data.tmask` | `[NUM_THREADS:0]`      | Input  | Thread mask                                                                                  |
| `data.pc`    | `[PC_BITS-1:0]`        | Input  | Program counter                                                    |
| `valid`      | `1 bit`                | Input  | Indicates that the schedule data is valid |
| `ready`      | `1 bit`                | Output | Fetch stage is ready to receive data |

###  [`warp_ctl_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_warp_ctl_if.sv) 

#### Pinout Table


| Port Name     | Width                   | Direction | Description                                                                                   |
|---------------|-------------------------|-----------|-----------------------------------------------------------------------------------------------|
| `data.wid`    | `[NW_WIDTH-1:0]`       | Input     | Warp ID                                                                                       |
| `data.tmask`  | `[NUM_THREADS:0]`      | Input     | Thread mask                                                                                     |
| `data.pc`     | `[PC_BITS-1:0]`        | Input     | Program counter                                                                                 |
| `data.done`   | `1 bit`                | Input     | Indicates if the warp has completed execution                                                 |
| `data.barrier`| `1 bit`                | Input     | Indicates if the warp is waiting at a synchronization barrier                                 |
| `data.valid`  | `1 bit`                | Input     | Indicates that the warp control data is valid                                                 |
| `valid`       | `1 bit`                | Output    | Indicates that warp control logic is ready to proceed with the provided data                 |
| `ready`       | `1 bit`                | Input     | Indicates that the warp control interface is ready to receive data                           |



### [`branch_ctl_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_branch_ctl_if.sv) 
#### Pinout Table

| Port Name     | Width                   | Direction | Description                                                                                   |
|---------------|-------------------------|-----------|-----------------------------------------------------------------------------------------------|
| `data.wid`    | `[NW_WIDTH-1:0]`       | Input     | Warp ID                                                                                       |
| `data.pc`     | `[PC_BITS-1:0]`        | Input     | Program counter                                                                               |
| `data.target` | `[PC_BITS-1:0]`        | Input     | Branch target address                                                                         |
| `data.tmask`  | `[NUM_THREADS:0]`      | Input     | Thread mask indicating active threads for the branch                                          |
| `data.taken`  | `1 bit`                | Input     | Indicates if the branch was taken                                                            |
| `valid`       | `1 bit`                | Input     | Indicates that branch control data is valid                                                  |
| `ready`       | `1 bit`                | Output    | Indicates that the branch control interface is ready to receive data                         |

### [`decode_sched_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_decode_sched_if.sv)                   

### Pinout Table
| Port Name       | Width                   | Direction | Description                                                                                   |
|-----------------|-------------------------|-----------|-----------------------------------------------------------------------------------------------|
| `data.wid`      | `[NW_WIDTH-1:0]`       | Input     | Warp ID                                                                                       |
| `data.tmask`    | `[NUM_THREADS:0]`      | Input     | Thread mask indicating active threads for the instruction                                     |
| `data.pc`       | `[PC_BITS-1:0]`        | Input     | Program counter                                                                               |
| `data.instr`    | `[INSTR_WIDTH-1:0]`    | Input     | Decoded instruction                                                                           |
| `data.op_type`  | `[OP_TYPE_WIDTH-1:0]`  | Input     | Operation type or category of the instruction                                                |
| `valid`         | `1 bit`                | Input     | Indicates that decode and scheduling data is valid                                            |
| `ready`         | `1 bit`                | Output    | Indicates that the decode-scheduler interface is ready to receive data                       |
| `ibuf_pop` (enabled with `L1_ENABLE`)| `1 bit`| Output | flag to pop or remove an Entry from IBUF| 
### [`gbar_bus_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/mem/VX_gbar_bus_if.sv)

### Pinout Table
| Port Name      | Width                   | Direction | Description                                                                                   |
|----------------|-------------------------|-----------|-----------------------------------------------------------------------------------------------|
| `data.wid`     | `[NW_WIDTH-1:0]`       | Input     | Warp ID initiating the global barrier request                                                |
| `data.tmask`   | `[NUM_THREADS:0]`      | Input     | Thread mask indicating active threads participating in the barrier                           |
| `data.op`      | `[OP_WIDTH-1:0]`       | Input     | Barrier operation type                                             |
| `data.valid`   | `1 bit`                | Input     | Indicates that the barrier request data is valid                                             |
| `valid`        | `1 bit`                | Input     | Asserts that the global barrier data is ready for processing                                 |
| `ready`        | `1 bit`                | Output    | Indicates that the global barrier system is ready to accept new requests                    |
| `data.complete`| `1 bit`                | Output    | Signals that the barrier operation has been completed                                        |

### [`sched_csr_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_sched_csr_if.sv)

### Pinout Table

| Port Name       | Width                   | Direction | Description                                                                                   |
|-----------------|-------------------------|-----------|-----------------------------------------------------------------------------------------------|
| `data.wid`      | `[NW_WIDTH-1:0]`       | Input     | Warp ID associated with the CSR operation                                                    |
| `data.addr`     | `[CSR_ADDR_WIDTH-1:0]` | Input     | Address of the CSR to be accessed                                                            |
| `data.value`    | `[CSR_DATA_WIDTH-1:0]` | Input     | Value to be written to the CSR                                                               |
| `data.rw`       | `1 bit`                | Input     | Indicates the type of operation: 0 for read, 1 for write                                     |
| `data.valid`    | `1 bit`                | Input     | Indicates that the CSR operation data is valid                                               |
| `valid`         | `1 bit`                | Input     | Indicates that the scheduler CSR interface is ready for operation                            |
| `ready`         | `1 bit`                | Output    | Indicates that the CSR system is ready to accept data                                        |
| `data.result`   | `[CSR_DATA_WIDTH-1:0]` | Output    | Result of the CSR read operation                                                             |

### internal signals 
| signal  | usage in module |
|---------|-----------------|
| active_warps| 
|active_warps_n| 
