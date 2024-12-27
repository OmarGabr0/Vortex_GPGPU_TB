# Commit Stage

## Overview

The **Commit Stage** is responsible for finalizing the execution of instructions, updating architectural state, and tracking performance metrics. It plays a crucial role in ensuring instructions are correctly retired and results are committed to the register file.

### Responsibilities

1. **Arbitration and Prioritization**:  
   Resolves contention among execution units by arbitrating between valid instructions from multiple sources.

2. **Writeback Data Handling**:  
   Manages the transfer of execution results to the register file in the issue stage.

3. **Instruction Retirement**:  
   Marks instructions as completed and retires them from the pipeline, and updates the CSR with such performance counters.

4. **Warp Management**:  
   Signals the schedule stage about completed warps, enabling efficient management of pipeline resources.
