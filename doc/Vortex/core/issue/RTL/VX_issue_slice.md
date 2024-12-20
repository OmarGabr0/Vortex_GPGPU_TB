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

