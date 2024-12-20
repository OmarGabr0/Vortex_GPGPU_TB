# Schedule Stage

## Overview

The schedule stage is responsible for scheduling instructions to be moved through the pipeline. It manages instruction stalls by handling the unlocking of stalled instructions and adjusting the program counter (PC) in response to branching. Additionally, the schedule stage processes Vortex custom instructions (split, join, tmc, pred, barrier) coming from the execute stage, ensuring that they are correctly handled and propagated through the pipeline for further execution.

## Interfaces & Ports

| Interface Name                     | Description                                                      |
|-------------------------------------|------------------------------------------------------------------|
| `base_dcrs`                       | Input configuration interface for base device control registers. |
| [`warp_ctl_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_warp_ctl_if.sv)                       | Slave interface for [VX_wctl_unit](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_wctl_unit.sv#L16) in the [VX_sfu_unit](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_sfu_unit.sv#L16) in the execute stage                |
| [`branch_ctl_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_branch_ctl_if.sv)                     | Slave interface for [alu_int](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_alu_int.sv#L16) to handle branching signals |
| [`decode_sched_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_decode_sched_if.sv)                 | Slave interface for [decode](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_decode.sv#L41) stage to unlock stalled warps           |
| [`commit_sched_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_commit_sched_if.sv)                   | Slave interface for [commit](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_commit.sv#L28) stage to help track pending instructions per warp           |
| [`schedule_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_schedule_if.sv)                        | Master interface for sending schedule data to fetch stage via [VX_elastic_buffer](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_schedule.sv#L350)             |
|[`gbar_bus_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/mem/VX_gbar_bus_if.sv)  | Master interface for the Global Barrier Bus (enabled with `GBAR_ENABLE`) |
| [`sched_csr_if`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_sched_csr_if.sv)                     | Master interface for sending schedule data to [csr_unit](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_csr_unit.sv#L36) |
| `busy`                              | Output wire indicating the status of the scheduler (busy or idle). |
| [`sched_perf`](https://github.com/RISC-V-Based-Accelerators/vortex/blob/master/hw/rtl/interfaces/VX_pipeline_perf_if.sv)                        | Output interface for scheduling performance metrics (enabled with `PERF_ENABLE`). |

### Schedule Interface

| Port Name    | Width                   | Direction | Description                                                                                  |
|--------------|------------------------|--------|----------------------------------------------------------------------------------------------|
| `data.uuid`  | `[UUID_WIDTH-1:0]`     | Input  | Universal Unique ID                                                                          |
| `data.wid`   | `[NW_WIDTH-1:0]`       | Input  | Warp ID                                                                                      |
| `data.tmask` | `[NUM_THREADS:0]`      | Input  | Thread mask                                                                                  |
| `data.pc`    | `[PC_BITS-1:0]`        | Input  | Program counter                                                    |
| `valid`      | `1 bit`                | Input  | Indicates that the schedule data is valid |
| `ready`      | `1 bit`                | Output | Fetch stage is ready to receive data |

### Warp Control Interface

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

### Branch Control Interface

| Port Name     | Width                   | Direction | Description                                                                                   |
|---------------|-------------------------|-----------|-----------------------------------------------------------------------------------------------|
| `data.wid`    | `[NW_WIDTH-1:0]`       | Input     | Warp ID                                                                                       |
| `data.pc`     | `[PC_BITS-1:0]`        | Input     | Program counter                                                                               |
| `data.target` | `[PC_BITS-1:0]`        | Input     | Branch target address                                                                         |
| `data.tmask`  | `[NUM_THREADS:0]`      | Input     | Thread mask indicating active threads for the branch                                          |
| `data.taken`  | `1 bit`                | Input     | Indicates if the branch was taken                                                            |
| `valid`       | `1 bit`                | Input     | Indicates that branch control data is valid                                                  |
| `ready`       | `1 bit`                | Output    | Indicates that the branch control interface is ready to receive data                         |

### Decode Interface

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

### Global Barrier Bus Interface

| Port Name      | Width                   | Direction | Description                                                                                   |
|----------------|-------------------------|-----------|-----------------------------------------------------------------------------------------------|
| `data.wid`     | `[NW_WIDTH-1:0]`       | Input     | Warp ID initiating the global barrier request                                                |
| `data.tmask`   | `[NUM_THREADS:0]`      | Input     | Thread mask indicating active threads participating in the barrier                           |
| `data.op`      | `[OP_WIDTH-1:0]`       | Input     | Barrier operation type                                             |
| `data.valid`   | `1 bit`                | Input     | Indicates that the barrier request data is valid                                             |
| `valid`        | `1 bit`                | Input     | Asserts that the global barrier data is ready for processing                                 |
| `ready`        | `1 bit`                | Output    | Indicates that the global barrier system is ready to accept new requests                    |
| `data.complete`| `1 bit`                | Output    | Signals that the barrier operation has been completed                                        |

### CSR Interface

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


```verilog
wire schedule_fire = schedule_valid && schedule_ready; 
wire schedule_if_fire = schedule_if.valid && schedule_if.ready;  

    VX_elastic_buffer #(
        .DATAW (`NUM_THREADS + `PC_BITS + `NW_WIDTH + `UUID_WIDTH),
        .SIZE  (2),  // need to buffer out ready_in
        .OUT_REG (1) // should be registered for BRAM acces in fetch unit
    ) out_buf (
        .clk       (clk),
        .reset     (reset),
        .valid_in  (schedule_valid),
        .ready_in  (schedule_ready),
        .data_in   ({schedule_tmask, schedule_pc, schedule_wid, instr_uuid}),
        .data_out  ({schedule_if.data.tmask, schedule_if.data.PC, schedule_if.data.wid, schedule_if.data.uuid}),
        .valid_out (schedule_if.valid),
        .ready_out (schedule_if.ready)
    );

```
schedule_fire dtat flag is set when elastic buffer not full and have valid data to recive, schedule_if_fire is set when having data in buffer and ready to send to next buffer  

``` verilog 
 // branch
    wire [`NUM_ALU_BLOCKS-1:0]                  branch_valid;
    wire [`NUM_ALU_BLOCKS-1:0][`NW_WIDTH-1:0]   branch_wid;
    wire [`NUM_ALU_BLOCKS-1:0]                  branch_taken;
    wire [`NUM_ALU_BLOCKS-1:0][`PC_BITS-1:0]    branch_dest;
    for (genvar i = 0; i < `NUM_ALU_BLOCKS; ++i) begin : g_branch_init
        assign branch_valid[i] = branch_ctl_if[i].valid;
        assign branch_wid[i]   = branch_ctl_if[i].wid;
        assign branch_taken[i] = branch_ctl_if[i].taken;
        assign branch_dest[i]  = branch_ctl_if[i].dest;
    end
```
`branch_valid` :Flag for branch operation if valid for each ALU block, array corresponds to one ALU block

`branch_wid` :hold warp id associated with the branch operation issued by each ALU block,Each element branch_wid[i] contains the warp ID for the branch in ALU block i, to track wich waro is affected by branch operation, to allow schedule sage to update PC for correct warp 

`branch_taken` :This signal indicates whether the branch condition was satisfied (taken) for each ALU block, used by the scheduler to determine whether to update the warp's PC to the branch destination 

`branch_dest` :or to continue with sequential instruction execution

`branch_dest`:If a branch is taken (branch_taken[i] == 1), the scheduler will update the warp's PC to branch_dest[i]. This ensures that the warp begins execution from the correct address after a branch operation

Then used for loop to collect signals from `branch_if` for each ALU block.
# Barrier control 
``` verilog 
  // barriers
    reg [`NUM_BARRIERS-1:0][`NUM_WARPS-1:0] barrier_masks, barrier_masks_n;
    reg [`NUM_BARRIERS-1:0][`NW_WIDTH-1:0] barrier_ctrs, barrier_ctrs_n;
    reg [`NUM_WARPS-1:0] barrier_stalls, barrier_stalls_n;
    reg [`NUM_WARPS-1:0] curr_barrier_mask_p1;
`ifdef GBAR_ENABLE
    reg gbar_req_valid;
    reg [`NB_WIDTH-1:0] gbar_req_id;
    reg [`NC_WIDTH-1:0] gbar_req_size_m1;
`endif
```
`barrier_masks`:Mask used to track which thread needs reconvergance, It is two dimentional array, `NUM_BARRIERS` corresponds to the number of available barriers, `NUM_WARPS` indicates which warps are participating in each barrier , 

`barrier_masks_n` : holds next state of the `barrier_masks` mask 

`barrier_ctrs` : Used to count how many warps reached the reconvergance point, Ensures all warps participating in a barrier reach the synchronization point before proceeding.
`NUM_BARRIERS` corresponds to the number of available barriers, `NW_WIDTH` keeps track of the number of warps that have not yet arrived at the barrier.

`barrier_ctrs_n`: is the next-state version of `barrier_ctrs`.

`barrier_stalls`: bit array where each bit corresponds to a warp,If `barrier_stalls[warp_id]` is high (1), the warp is stalled due to an incomplete barrier.

`barrier_stalls_n`: is the next-state version of barrier_stalls.

`curr_barrier_mask_p1`: holds a one-cycle delayed mask of the warps associated with the current barrier being processed.

 * usage in [always block](https://github.com/RISC-V-Based-Accelerators/vortex/blob/ce1396346e2f69a569352fda6f490dd7dad13056/hw/rtl/core/VX_schedule.sv#L155)  
```verilog 
 // barrier handling
        curr_barrier_mask_p1 = barrier_masks[warp_ctl_if.barrier.id];
        curr_barrier_mask_p1[warp_ctl_if.wid] = 1;
        if (warp_ctl_if.valid && warp_ctl_if.barrier.valid) begin
            if (~warp_ctl_if.barrier.is_noop) begin
                if (~warp_ctl_if.barrier.is_global
                 && (barrier_ctrs[warp_ctl_if.barrier.id] == `NW_WIDTH'(warp_ctl_if.barrier.size_m1))) begin
                    barrier_ctrs_n[warp_ctl_if.barrier.id] = '0; // reset barrier counter
                    barrier_masks_n[warp_ctl_if.barrier.id] = '0; // reset barrier mask
                    stalled_warps_n &= ~barrier_masks[warp_ctl_if.barrier.id]; // unlock warps
                    stalled_warps_n[warp_ctl_if.wid] = 0; // unlock warp
                end else begin
                    barrier_ctrs_n[warp_ctl_if.barrier.id] = barrier_ctrs[warp_ctl_if.barrier.id] + `NW_WIDTH'(1);
                    barrier_masks_n[warp_ctl_if.barrier.id] = curr_barrier_mask_p1;
                end
            end else begin
                stalled_warps_n[warp_ctl_if.wid] = 0; // unlock warp
            end
        end
    `ifdef GBAR_ENABLE
        if (gbar_bus_if.rsp_valid && (gbar_req_id == gbar_bus_if.rsp_id)) begin
            barrier_ctrs_n[warp_ctl_if.barrier.id] = '0; // reset barrier counter
            barrier_masks_n[gbar_bus_if.rsp_id] = '0; // reset barrier mask
            stalled_warps_n = '0; // unlock all warps
        end
    `endif

```
 assigning the current barrier mask to barrier mask with barrier id  for example: If `barrier_masks[3] = 8'b00001111`, it indicates that warps 0, 1, 2, 3 are participating in barrier ID 3, and then activate the corressponding barrier `curr_barrier_mask_p1[warp_ctl_if.wid] = 1`to mark current warp as participating in barrier

 when warp control unit output valid signal and barrier is valid, this compinational block starts to work,and skip processing if barrer operation is noop wich means no synchronization needs to be processed.

 Then filter operation only to handel local operations  as global operation spans across all warps in the GPU 

 then check if all requierd warps have reached the barrier by Comparing the count of currently arrived warps `barrier_ctrs` to the expected number of warps `size_m1`. When equal, all required warps have reached the barrier.
 
When all required warps have reached the barrier, the barrier is reset, and all stalled warps participating in this barrier are unlocked to proceed with execution.

If the barrier is not yet complete, the counter and mask for the barrier are updated to reflect the current warp’s participation.

if The barrier is marked as a no-op (is_noop), The current warp is simply unlocked, allowing it to proceed without waiting for synchronization.

`GBAR_ENABLE` it's just the same but when having multible cores in device, it processes the barrier i core level 

# [Warp spawn handling](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_schedule.sv#L116)
``` verilog 
 // wspawn
    wspawn_t wspawn;
    reg [`NW_WIDTH-1:0] wspawn_wid;
    reg is_single_warp;

    wire [`CLOG2(`NUM_WARPS+1)-1:0] active_warps_cnt;
    `POP_COUNT(active_warps_cnt, active_warps);

```
`wspawn_t wspawn`: holds information related to the warp spawning process in the scheduling stage. The wspawn_t type would be a struct that includes the necessary data for managing warp creation and scheduling.

``` verilog 
   typedef struct packed {
        logic                   valid;
        logic [`NUM_WARPS-1:0]  wmask;
        logic [`PC_BITS-1:0]    pc;
    } wspawn_t;
```

`wspawn_wid`: holds the warp identifier (ID) for the warp being spawned, represented as a bit vector of width NW_WIDTH
which help schedule stage to uniquely idenitify which warp is beaing scheduled 

`reg is_single_warp`: flag to indicate whether the scheduling process is handling a single warp or multiple warps.

`active_warps_cnt`: tracks the number of active warps in the system, which informs the scheduler about the current load and helps in making

`POP_COUNT(active_warps_cnt, active_warps)`: counts the number of active warps,so that the scheduler can decide whether to issue new warps, stall the pipeline, or wait for resources to become available. It also helps in load balancing between available execution units.

usage in [always block](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_schedule.sv#L116)
``` verilog 
  // wspawn handling
        if (wspawn.valid && is_single_warp) begin
            active_warps_n |= wspawn.wmask;
            for (integer i = 0; i < `NUM_WARPS; ++i) begin
                if (wspawn.wmask[i]) begin
                    thread_masks_n[i][0] = 1;
                    warp_pcs_n[i] = wspawn.pc;
                end
            end
            stalled_warps_n[wspawn_wid] = 0; // unlock warp
        end
```
checking if warp spwan is valid and hanlding single warp ,
then update active warps with the new generated mask 

for loop to check if warp at index i is beinig spwaned to so that the actions is only applied for spawned warps, 

sets the thread mask for index `i` warp to `1` to indicate the warp is active and would be scheduled for excution, that assigning all thread in mask to 1 indicates that all threads in warp are ready for eexcution `thread_masks_n[i][0] = 1;` 

`warp_pcs_n[i] = wspawn.pc;`: : The program counter (PC) points to the instruction to be executed next by the warp. By setting the program counter to wspawn.pc, the system ensures that the spawned warp will start execution at the correct instruction.

`stalled_warps_n[wspawn_wid] = 0;`:  This unlocks the warp identified by wspawn_wid. 
# [TMC handling](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_schedule.sv#L128) 
 logic that updates the status of warps and their associated threads, using the thread mask provided by the warp_ctl_if interface.
```verilog 
        // TMC handling
        if (warp_ctl_if.valid && warp_ctl_if.tmc.valid) begin
            active_warps_n[warp_ctl_if.wid]  = (warp_ctl_if.tmc.tmask != 0);
            thread_masks_n[warp_ctl_if.wid]  = warp_ctl_if.tmc.tmask;
            stalled_warps_n[warp_ctl_if.wid] = 0; // unlock warp
        end
```
if both the warp control interface (warp_ctl_if) and its associated TMC (warp_ctl_if.tmc) are valid.

then update active warps,thread mask and unlock this warp so that it can proceed to eccution unit once it's threads are ready.

# [split handling](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_schedule.sv#L135)
manages the state of warps when they are split into different execution paths or subwarps, allowing the system to control which threads are active in each split
```verilog
  // split handling
        if (warp_ctl_if.valid && warp_ctl_if.split.valid) begin
            if (warp_ctl_if.split.is_dvg) begin
                thread_masks_n[warp_ctl_if.wid] = warp_ctl_if.split.then_tmask;
            end
            stalled_warps_n[warp_ctl_if.wid] = 0; // unlock warp
        end
```
checks if both the warp control unit data are valid and its associated split control data is valid.

if divergance happen, ensures that the thread mask (then_tmask) is applied to the warp only if the split is of this type, then update thread mask register for that warp (using wid) with new thread mask provided by split operation from [ VX_split_join ](https://github.com/vortexgpgpu/vortex/blob/master/hw/rtl/core/VX_split_join.sv) 

`then_tmask` represents the thread mask that determines which threads are active after the split. By updating `thread_masks_n` with `then_tmask`, the system ensures that the correct subset of threads in the warp is activated for execution after the split.

`stalled_warps_n[warp_ctl_if.wid] = 0`: unlocks the warp by setting its entry in the stalled_warps_n register to 0, indicating that the warp is no longer stalled and can proceed with execution.

# [Join_handling](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_schedule.sv#L143)

``` verilog 
 // join handling
        if (join_valid) begin
            if (join_is_dvg) begin
                if (join_is_else) begin
                    warp_pcs_n[join_wid] = join_pc;
                end
                thread_masks_n[join_wid] = join_tmask;
            end
            stalled_warps_n[join_wid] = 0; // unlock warp
        end
```
checks if the join operation is valid, meaning that there is a join request that needs to be processed.

checks if the join operation involves a diverance, indicating that the warp was previously split and is now being joined back together.

`warp_pcs_n[join_wid] = join_pc;`: updates the PC to the join path 

`thread_masks_n[join_wid] = join_tmask;`: update thread mask after join operation 
If some threads were inactive during the split, this mask will determine which threads are resumed

`stalled_warps_n[join_wid] = 0;`: unlock the warp to be ecxuted  

# [Branch handling](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_schedule.sv#L181)

```verilog 
  // Branch handling
        for (integer i = 0; i < `NUM_ALU_BLOCKS; ++i) begin
            if (branch_valid[i]) begin
                if (branch_taken[i]) begin
                    warp_pcs_n[branch_wid[i]] = branch_dest[i];
                end
                stalled_warps_n[branch_wid[i]] = 0; // unlock warp
            end
        end
```

 Loop Over ALU Blocks: The code loops over each ALU block (NUM_ALU_BLOCKS) to handle potential branches in different blocks.

Branch Validity Check: For each ALU block, it checks if the branch is valid (branch_valid[i]), indicating that a branch operation has occurred.

 `warp_pcs_n[branch_wid[i]] = branch_dest[i];`:  update the PC for warp i with new branch destination to ensure continue excution after branching 

Unlocking Warps: The warp is unlocked (stalled_warps_n[branch_wid[i]] = 0) to allow further execution after processing the branch.
# [control warp stalls](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_schedule.sv#L191)
``` verilog 
   // decode unlock
        if (decode_sched_if.valid && decode_sched_if.unlock) begin
            stalled_warps_n[decode_sched_if.wid] = 0;
        end

        // CSR unlock
        if (sched_csr_if.unlock_warp) begin
            stalled_warps_n[sched_csr_if.unlock_wid] = 0;
        end

        // stall the warp until decode stage
        if (schedule_fire) begin
            stalled_warps_n[schedule_wid] = 1;
        end

        // advance PC
        if (schedule_if_fire) begin
            warp_pcs_n[schedule_if.data.wid] = schedule_if.data.PC + `PC_BITS'(2);
        end
 ```

1- check the decude is valid and have unlock signal to ulock the warp and warp can proceed

2-  checks if the CSR (Control and Status Register) interface has been triggered to unlock a warp., 

3- handles the advancement of the program counter (PC) for the warp when it's ready to execute.

#[VX_split_join](https://github.com/vortexgpgpu/vortex/blob/master/hw/rtl/core/VX_split_join.sv)

``` verilog 
// split/join handling
    VX_split_join #(
        .INSTANCE_ID (`SFORMATF(("%s-splitjoin", INSTANCE_ID)))
    ) split_join (
        .clk        (clk),
        .reset      (reset),
        .valid      (warp_ctl_if.valid),
        .wid        (warp_ctl_if.wid),
        .split      (warp_ctl_if.split),
        .sjoin      (warp_ctl_if.sjoin),
        .join_valid (join_valid),
        .join_is_dvg(join_is_dvg),
        .join_is_else(join_is_else),
        .join_wid   (join_wid),
        .join_tmask (join_tmask),
        .join_pc    (join_pc),
        .stack_wid  (warp_ctl_if.dvstack_wid),
        .stack_ptr  (warp_ctl_if.dvstack_ptr)
    );
```
this module handle join and split, and instantiate the [IPDOM stack](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_split_join.sv#L49) inside it 

# [pending_size](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_schedule.sv#L350)
```verilog
  // Track pending instructions per warp

    wire [`NUM_WARPS-1:0] pending_warp_empty;
    wire [`NUM_WARPS-1:0] pending_warp_alm_empty;

    for (genvar i = 0; i < `NUM_WARPS; ++i) begin : g_pending_sizes
        VX_pending_size #(
            .SIZE      (4096),
            .ALM_EMPTY (1)
        ) counter (
            .clk       (clk),
            .reset     (reset),
            .incr      (schedule_if_fire && (schedule_if.data.wid == `NW_WIDTH'(i))),
            .decr      (commit_sched_if.committed_warps[i]),
            .empty     (pending_warp_empty[i]),
            .alm_empty (pending_warp_alm_empty[i]),
            `UNUSED_PIN (full),
            `UNUSED_PIN (alm_full),
            `UNUSED_PIN (size)
        );
	end

    assign sched_csr_if.alm_empty = pending_warp_alm_empty[sched_csr_if.alm_empty_wid];

    wire no_pending_instr = (& pending_warp_empty);
```
responsible for tracking pending instructions per warp. It uses a counter to monitor the number of instructions that are yet to be completed for each warp. The scheduler uses this information to determine when a warp is idle or close to being idle.

instantaited for each warp to track number of pending instructions 

Increments the pending counter when an instruction is scheduled for the current warp

Decrements the counter when instructions are committed

`empty`: Indicates whether the counter is empty (no pending instructions).

`alm_empty`: Indicates the "almost empty" condition.

`wire no_pending_instr`: This signal is high (1) when all warps have no pending instructions 


# [leading zero counter](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_schedule.sv#L315)
```verilog

    // schedule the next ready warp

    wire [`NUM_WARPS-1:0] ready_warps = active_warps & ~stalled_warps;

    VX_lzc #(
        .N (`NUM_WARPS),
        .REVERSE (1)
    ) wid_select (
        .data_in   (ready_warps),
        .data_out  (schedule_wid),
        .valid_out (schedule_valid)
    );
```
handles selecting the next ready warp to be scheduled for execution. The process ensures that warps that are both active and not stalled are considered for scheduling

`ready_warps`: Identifies the warps that are eligible for scheduling

`REVERSE`: When set to 1, the LZC logic searches from the least significant bit (LSB) instead of the most significant bit (MSB). This ensures that lower-priority warps (based on bit index) are scheduled first.

`data_in`: The ready_warps signal, indicating which warps are eligible for scheduling.

`data_out`: The ID of the next warp to be scheduled (schedule_wid).

`valid_out`: Indicates whether there is a valid warp ready to schedule (schedule_valid).
``` verilog
    wire [`UUID_WIDTH-1:0] instr_uuid;
`ifdef UUID_ENABLE
    VX_uuid_gen #(
        .CORE_ID    (CORE_ID),
        .UUID_WIDTH (`UUID_WIDTH)
    ) uuid_gen (
        .clk   (clk),
        .reset (reset),
        .incr  (schedule_fire),
        .wid   (schedule_wid),
        .uuid  (instr_uuid)
    );
`else
    assign instr_uuid = '0;
`endif
```

optional to give id for each warp 