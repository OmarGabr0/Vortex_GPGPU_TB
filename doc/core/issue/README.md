# Issue Stage

## Overview

The **Issue Stage** introduces a second and third scheduling mechanism to efficiently manage instruction dependencies while optimizing data access. These mechanisms work to ensure that instructions are issued in an order that minimizes stalls and maximizes parallelism, enhancing overall performance. Additionally, they aim to maximize bank hits during data fetching, reducing memory access latency and improving throughput.

### Responsibilities

1. **Instruction Buffer Management**:  
   Stores multiple instructions fetched from memory which enables the scheduler to select from several instructions for issuing, improving warp-level throughput.

2. **Dependency Tracking**:  
   Utilizes the scoreboard to identify and manage data and structural hazards between instructions, ensuring that issued instructions do not introduce pipeline hazards. This tracking allows overlapping the execution of instructions within the same warp.

3. **Instruction Selection**:  
   Selects eligible instructions from the instruction buffer for issuing based on readiness, dependency clearance, and resource availability. This step ensures efficient pipeline utilization and minimizes stalls.

4. **Operand Access Optimization**:  
   Relies on the operand collector to increase parallelism by maximizing register bank hits. This reduces access contention and improves throughput for source operands during instruction execution.

## Structure

The total number of warps is divided into slices, where each slice is equal to 8 warps and share the following:

### Instruction Buffer

The instruction buffer is a FIFO (First-In, First-Out) structure that holds multiple decoded instructions, allowing the scheduler to pick instructions that have no dependencies. This helps improve the flow of instructions through the pipeline. The instruction buffer also helps reduce delays caused by instruction cache misses by working with instruction miss-status holding registers (MSHRs), making sure that memory delays don't slow down the pipeline too much.

### Scoreboard

The scoreboard manages data dependencies between instructions in a GPU core. It uses a simple in-order design to track the readiness of operands and registers for each warp. When an instruction enters the instruction buffer, the scoreboard is accessed to check for dependencies between operands and previously issued instructions. If dependencies are detected, the instruction is stalled until the required operands are available. This design prevents read-after-write (RAW) and write-after-write (WAW) hazards by ensuring that:

- **RAW hazards** are prevented by checking if an instruction is trying to read a register that is currently being written to by a previous instruction. If the register is being written, the instruction will be stalled until the write completes.
- **WAW hazards** are avoided by ensuring that two instructions do not write to the same register simultaneously. The scoreboard tracks which instructions are writing to each register and stalls any subsequent instructions that attempt to write to the same register before the previous write is completed.

### Operand Collector
