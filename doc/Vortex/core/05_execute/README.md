# VX_execute

The `VX_execute` module is a core component of the pipeline responsible for managing instruction execution in a GPU architecture. It integrates multiple execution units, including ALU, LSU, SFU, and optionally, FPU. Each unit interacts with its respective dispatch, commit, and memory interfaces, as well as the overall control logic.

---

## Features
- Supports multiple execution units:
  - **ALU Unit**: Handles arithmetic and logical operations.
  - **LSU Unit**: Manages load/store instructions and interacts with the memory subsystem.
  - **SFU Unit**: Performs special function operations, including control flow and scheduling.
  - **FPU Unit** (optional): Executes floating-point operations if enabled.
- Compatible with configurable execution widths (`ISSUE_WIDTH`).
- Provides a comprehensive set of interfaces for dispatch, commit, memory, and control.
