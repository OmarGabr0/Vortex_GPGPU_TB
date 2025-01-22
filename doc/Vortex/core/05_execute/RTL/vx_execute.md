# VX_execute

The `VX_execute` module represents the execution stage of a GPU pipeline. It integrates multiple functional units, including ALU, LSU, SFU, and optionally FPU, to execute dispatched instructions. This module interfaces with memory, dispatch, and commit units to ensure proper instruction flow and result management.

## Parameters

| Parameter       | Default Value | Description                                         |
|-----------------|---------------|-----------------------------------------------------|
| `INSTANCE_ID`   | ""            | Unique identifier for the instance.                |
| `CORE_ID`       | 0             | Identifier for the core this execution unit belongs to. |

## Interfaces and Ports

### Inputs

| Port Name          | Width                       | Description                                           |
|--------------------|-----------------------------|-------------------------------------------------------|
| `clk`              | 1                           | Clock signal.                                         |
| `reset`            | 1                           | Reset signal.                                         |
| `base_dcrs`        | `base_dcrs_t`               | Base control and status registers.                   |
| `dispatch_if`      | [`NUM_EX_UNITS` * `ISSUE_WIDTH`] | Dispatch interface for instruction delivery.         |
| `sched_csr_if`     | `VX_sched_csr_if.slave`     | Scheduler CSR interface.                             |

### Outputs

| Port Name          | Width                       | Description                                           |
|--------------------|-----------------------------|-------------------------------------------------------|
| `lsu_mem_if`       | [`NUM_LSU_BLOCKS`]          | LSU memory interface for memory operations.           |
| `commit_if`        | [`NUM_EX_UNITS` * `ISSUE_WIDTH`] | Commit interface for instruction results.            |
| `branch_ctl_if`    | [`NUM_ALU_BLOCKS`]          | Branch control interface for branch decisions.        |
| `warp_ctl_if`      | `VX_warp_ctl_if.master`     | Warp control interface for managing active warps.     |
| `commit_csr_if`    | `VX_commit_csr_if.slave`    | Commit CSR interface.                                 |

### Optional Interfaces

| Port Name           | Condition            | Description                                           |
|---------------------|----------------------|-------------------------------------------------------|
| `mem_perf_if`       | `PERF_ENABLE` defined | Performance counters for memory operations.          |
| `pipeline_perf_if`  | `PERF_ENABLE` defined | Performance counters for pipeline operations.        |
| `fpu_csr_if`        | `EXT_F_ENABLE` defined | FPU CSR interface for floating-point operations.     |

## Submodules

### 1. VX_alu_unit

#### Description
Handles integer arithmetic, logic, and branch-related instructions.

#### Parameters
| Parameter       | Value                          | Description                       |
|-----------------|--------------------------------|-----------------------------------|
| `INSTANCE_ID`   | `INSTANCE_ID-alu`             | Unique identifier for the ALU.   |

#### Connections
| Port Name         | Connected Interface                   |
|-------------------|---------------------------------------|
| `clk`             | `clk`                                |
| `reset`           | `reset`                              |
| `dispatch_if`     | `dispatch_if[EX_ALU * ISSUE_WIDTH +: ISSUE_WIDTH]` |
| `commit_if`       | `commit_if[EX_ALU * ISSUE_WIDTH +: ISSUE_WIDTH]` |
| `branch_ctl_if`   | `branch_ctl_if`                      |

---

### 2. VX_lsu_unit

#### Description
Manages load and store instructions, interacting with memory.

#### Parameters
| Parameter       | Value                          | Description                       |
|-----------------|--------------------------------|-----------------------------------|
| `INSTANCE_ID`   | `INSTANCE_ID-lsu`             | Unique identifier for the LSU.   |

#### Connections
| Port Name         | Connected Interface                   |
|-------------------|---------------------------------------|
| `clk`             | `clk`                                |
| `reset`           | `reset`                              |
| `dispatch_if`     | `dispatch_if[EX_LSU * ISSUE_WIDTH +: ISSUE_WIDTH]` |
| `commit_if`       | `commit_if[EX_LSU * ISSUE_WIDTH +: ISSUE_WIDTH]` |
| `lsu_mem_if`      | `lsu_mem_if`                         |

---

### 3. VX_fpu_unit (Optional)

#### Description
Executes floating-point instructions when floating-point support is enabled.

#### Parameters
| Parameter       | Value                          | Description                       |
|-----------------|--------------------------------|-----------------------------------|
| `INSTANCE_ID`   | `INSTANCE_ID-fpu`             | Unique identifier for the FPU.   |

#### Connections
| Port Name         | Connected Interface                   |
|-------------------|---------------------------------------|
| `clk`             | `clk`                                |
| `reset`           | `reset`                              |
| `dispatch_if`     | `dispatch_if[EX_FPU * ISSUE_WIDTH +: ISSUE_WIDTH]` |
| `commit_if`       | `commit_if[EX_FPU * ISSUE_WIDTH +: ISSUE_WIDTH]` |
| `fpu_csr_if`      | `fpu_csr_if`                         |

---

### 4. VX_sfu_unit

#### Description
Handles special functional unit instructions such as transcendental and other complex operations.

#### Parameters
| Parameter       | Value                          | Description                       |
|-----------------|--------------------------------|-----------------------------------|
| `INSTANCE_ID`   | `INSTANCE_ID-sfu`             | Unique identifier for the SFU.   |
| `CORE_ID`       | `CORE_ID`                     | Identifier for the core.          |

#### Connections
| Port Name         | Connected Interface                   |
|-------------------|---------------------------------------|
| `clk`             | `clk`                                |
| `reset`           | `reset`                              |
| `base_dcrs`       | `base_dcrs`                          |
| `dispatch_if`     | `dispatch_if[EX_SFU * ISSUE_WIDTH +: ISSUE_WIDTH]` |
| `commit_if`       | `commit_if[EX_SFU * ISSUE_WIDTH +: ISSUE_WIDTH]` |
| `sched_csr_if`    | `sched_csr_if`                       |
| `warp_ctl_if`     | `warp_ctl_if`                        |
| `commit_csr_if`   | `commit_csr_if`                      |

---

## Features

1. **Integrated Functional Units:**
   - The module incorporates ALU, LSU, SFU, and optionally FPU, enabling diverse instruction execution.
   
2. **Scalable Design:**
   - The number of execution units (`NUM_EX_UNITS`) and their width (`ISSUE_WIDTH`) are configurable, making the design flexible for different architectures.

3. **High-Performance Metrics:**
   - Optional performance monitoring interfaces provide insights into memory and pipeline behavior.

4. **Efficient Instruction Flow:**
   - Dedicated dispatch and commit interfaces ensure a smooth flow of instructions and results across the pipeline.

5. **Branch and Warp Management:**
   - Integration with branch and warp control interfaces enhances control over execution flow and active warps.

---

## Code Example

### ALU Unit Connection

```verilog
VX_alu_unit #(
    .INSTANCE_ID (`SFORMATF(("%s-alu", INSTANCE_ID)))
) alu_unit (
    .clk            (clk),
    .reset          (reset),
    .dispatch_if    (dispatch_if[`EX_ALU * `ISSUE_WIDTH +: `ISSUE_WIDTH]),
    .commit_if      (commit_if[`EX_ALU * `ISSUE_WIDTH +: `ISSUE_WIDTH]),
    .branch_ctl_if  (branch_ctl_if)
);
