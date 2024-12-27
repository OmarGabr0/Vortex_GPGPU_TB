# Schedule Stage

## Overview

The **Schedule Stage** is the initial stage in the pipeline, playing a pivotal role in the execution of warps. It ensures the smooth progression of instructions through the pipeline by carefully selecting and managing warps.

### Responsibilities

1. **Warp Selection**:  
   Chooses a warp to propagate to subsequent stages in the pipeline, prioritizing based on specific criteria such as readiness and resource availability.

2. **Warp Mask Management**:  
   Updates the warp masks to reflect active threads. This includes applying changes resulting from branch divergence or synchronization events.

3. **Program Counter (PC) Updates**:  
   Adjusts the program counters (PC) of warps to point to the correct instruction for execution, ensuring accurate control flow.

4. **Stall Handling**:  
   Identifies and resolves stalls by unlocking warps that were previously blocked due to resource conflicts, dependencies, or other pipeline constraints.

## Interfaces

### Warp Control Unit Interface

Modern GPUs employ the Single-Instruction Multiple-Thread (SIMT) execution model to provide the illusion of independent thread execution while maintaining the performance benefits of SIMD hardware. A critical component enabling this abstraction is the warp control unit, which is located in the Special Function Unit (SFU) in the execute stage, and it handles the GPU custom instructions.

#### Branch Divergence & Reconvergence

Recall that each warp has 32 threads moving in a lockstep executing the same instruction. However, **Branch Divergence** happens when there is a condition on a certain thread within a warp so that each thread can follow different execution paths.  The approach used is to serialize execution of threads following different paths within a given warp as shown below.

![Serialize](../images/schedule/serialize.png)

To achieve this serialization of divergent code paths, a **SIMT stack** is used.  Each entry on this stack contains three entries:

- A reconvergence program counter (RPC)
- The address of the next instruction to execute (Next PC)
- An active mask

The following example will help explain its operation.

```cpp
do {
    t1 = tid * N;        // A
    t2 = t1 + i;
    t3 = data1[t2];
    t4 = 0;

    if (t3 != t4) {
        t5 = data2[t2];  // B

        if (t5 != t4) {
            x += 1;      // C
        } else {
            y += 2;      // D
        }
    } else {
        z += 3;          // F
    }

    i++;  // G
} while (i < N);
```

- All threads move in lockstep during **Instruction `A`** with an **active mask = 1111**.  
- Upon encountering the first `if (t3 != t4)`:
  - A **split** instruction is executed.  
  - **Reconvergence point (`G`)** is pushed to the SIMT stack first.  
  - Divergent paths (`F` and `B`) are then pushed onto the stack.

- Upon encountering the second `if (t5 != t4)`:
  - Another **split** instruction is executed.  
  - **Reconvergence point (`E`)** is pushed to the stack first.  
  - Divergent paths (`D` and `C`) are then pushed onto the stack.  

- Upon reaching a reconvergence point:
  - A **join** instruction is encountered to **pop the stack entries**.  
  - The **active mask** of the reconvergence point must match the mask at the corresponding divergence point.  

- Note that:
  - Stack operates in **last-in, first-out (LIFO)** order.  
  - The path with more active threads is usually pushed last for efficiency.

![SIMT](../images/schedule/simt.png)

#### Barriers

Branch divergence can potentially lead to deadlocks. When a branch divergence occurs, we must choose whether to execute the `if` or `else` path first. This can cause issues if there is a dependency between the statements inside the `if` block and those inside the `else` block.  

Consider the following example:  

```cpp
if (condition)
{
    while (x != 1) {}
}
else
{
    x = 1;
}
```  

In this scenario, if we execute the `if` block first, the loop will never exit unless the `else` block is executed to assign `x = 1`. However, since the `else` block is dependent on not choosing the `if` path initially, a deadlock situation arises.

![barrier](../images/schedule/barrier.png)

The solution is to alternate execution between the `if` and `else` statements. To ensure proper synchronization and avoid deadlocks, we introduce barriers at the reconvergence point, allowing warps to synchronize before proceeding.

#### Other Custom Instructions

- **TMC / PRED** : Responsible for thread mask control (based on a predicate or not).
- **WSPAWN** : Responsible for spawning warps.

### Branch Control Interface

The branch control interface facilitates communication between the ALU unit in the execute stage and the schedule stage regarding branch instructions. It ensures accurate handling of branch outcomes, including determining whether a branch is taken, the target destination, and warp-level identification. The interface incorporates signals for branch validity and execution status, enabling synchronization and correct program flow.

### CSR Interface

The CSR interface between the schedule stage and the CSR unit enables the management and monitoring of warp-level activities within the processor. This interface facilitates operations such as unlocking stalled warps, checking pending instruction statuses, and exporting key metrics like active warps, thread masks, and execution cycles. It ensures smooth coordination by providing real-time information about warp readiness and resource availability. By linking scheduling decisions with the CSR unit, it plays a critical role in maintaining efficient pipeline operation and supporting dynamic adjustments based on runtime conditions.

### Schedule Interface

The interface between the schedule and fetch stages ensures seamless communication to support instruction fetching. It forwards critical information such as the Program Counter (PC), thread masks, and warp IDs, enabling the fetch stage to retrieve instructions for the correct warp and active threads.

### Decode Interface

The decode interface facilitates communication between the decode stage and the scheduling logic, focusing on warp management and timeout handling. When a warp is scheduled, it enters a stalled state until the decode stage unlocks it, signaling that the fetch was successful and the instruction is ready to proceed through the pipeline. This interface ensures the reactivation of stalled warps, maintaining the flow of execution. Additionally, it monitors warp activity and triggers timeout mechanisms when all active warps are stalled, enabling the timely resolution of potential deadlocks and ensuring pipeline efficiency.

### Commit Interface

The commit interface facilitates communication between the commit stage and the scheduling logic to manage warp-level instruction tracking. It decrements pending instructions for warps upon successful instruction completion, ensuring accurate accounting of in-flight operations. This interface is essential for detecting when a warp has completed all its instructions, enabling it to be marked as available for new scheduling.
