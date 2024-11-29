# Schedule Stage

## Overview

The schedule stage is responsible for scheduling instructions to be moved through the pipeline. It manages instruction stalls by handling the unlocking of stalled instructions and adjusting the program counter (PC) in response to branching. Additionally, the schedule stage processes Vortex custom instructions coming from the execute stage, ensuring that they are correctly handled and propagated through the pipeline for further execution.

## Interfaces

| Interface Name                     | Description                                                      |
|-------------------------------------|------------------------------------------------------------------|
| `base_dcrs`                         | Input configuration interface for base device control registers. |
| `warp_ctl_if`                       | Slave interface for [VX_wctl_unit](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_wctl_unit.sv#L16) in the [VX_sfu_unit](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_sfu_unit.sv#L16) in the execute stage                |
| `branch_ctl_if`                     | Slave interface for [alu_int](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_alu_int.sv#L16) to handle branching signals |
| `decode_sched_if`                   | Slave interface for receiving decoded schedule inputs.           |
| `commit_sched_if`                   | Slave interface for receiving commit schedule inputs.            |
| `schedule_if`                        | Master interface for sending scheduled instructions.             |
| `gbar_bus_if` (enabled with `GBAR_ENABLE`) | Master interface for the Global Barrier Bus (if GBAR is enabled). |
| `sched_csr_if`                      | Master interface for accessing the scheduling control/status registers. |
| `busy`                               | Output wire indicating the status of the scheduler (busy or idle). |
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
