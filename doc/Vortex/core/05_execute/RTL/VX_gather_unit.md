# VX_gather_unit Documentation

The `VX_gather_unit` module consolidates commit responses from multiple execution blocks (`BLOCK_SIZE`) into a unified set of output commit interfaces (`ISSUE_WIDTH`). This module is critical for maintaining proper data alignment and mapping of execution results to the appropriate output lanes in the pipeline.

---

## Parameters

### General Parameters
| **Parameter** | **Description**                                                                                     |
|---------------|-----------------------------------------------------------------------------------------------------|
| `BLOCK_SIZE`  | Number of input execution blocks providing commit responses.                                         |
| `NUM_LANES`   | Number of parallel lanes in each execution block (defines the thread width).                         |
| `OUT_BUF`     | Size and configuration of the elastic buffers at the output stage to handle backpressure efficiently.|

### Internal Calculated Parameters
| **Parameter**      | **Description**                                                                                 |
|--------------------|-------------------------------------------------------------------------------------------------|
| `BLOCK_SIZE_W`     | Width of the block ID field for encoding the block size.                                         |
| `PID_BITS`         | Number of bits required for the partition ID.                                                   |
| `PID_WIDTH`        | Rounded-up width of the `PID_BITS`.                                                             |
| `DATAW`            | Width of the data fields in the commit interface, including all instruction-related metadata.    |
| `DATA_WIS_OFF`     | Offset in the data field where the warp ID (`wid`) and UUID are stored.                         |

---

## Interfaces

The module uses the `VX_commit_if` interface for both its input and output. Below are the details:

### VX_commit_if Interface
The `VX_commit_if` interface facilitates communication of commit data between pipeline stages. Each commit unit in `BLOCK_SIZE` provides data via this interface, and the output is aggregated into `ISSUE_WIDTH` commit interfaces.

#### **`VX_commit_if` Fields**
| **Field**    | **Width**                          | **Description**                                                                                                  |
|--------------|------------------------------------|------------------------------------------------------------------------------------------------------------------|
| `uuid`       | `UUID_WIDTH`                      | Unique identifier for the instruction.                                                                           |
| `wid`        | `NW_WIDTH`                        | Warp ID associated with the instruction.                                                                         |
| `tmask`      | `NUM_LANES`                       | Thread mask indicating active threads for this instruction.                                                      |
| `PC`         | `PC_BITS`                         | Program Counter (PC) value of the instruction.                                                                   |
| `wb`         | 1 bit                             | Write-back flag indicating if the instruction result should be written back.                                      |
| `rd`         | `NR_BITS`                         | Destination register ID for the instruction result.                                                              |
| `data`       | `NUM_LANES × XLEN`                | Execution results for each active thread in the instruction.                                                     |
| `pid`        | `PID_WIDTH`                       | Partition ID for this instruction (used for partitioned architectures).                                          |
| `sop`        | 1 bit                             | Start-of-packet flag, indicating the beginning of a transaction group.                                            |
| `eop`        | 1 bit                             | End-of-packet flag, indicating the end of a transaction group.                                                   |

---

## Ports

### Inputs
| **Port**               | **Width**                      | **Description**                                                                                                  |
|------------------------|---------------------------------|------------------------------------------------------------------------------------------------------------------|
| `clk`                  | 1 bit                          | Clock signal for synchronous operation.                                                                          |
| `reset`                | 1 bit                          | Reset signal to initialize the module.                                                                           |
| `commit_in_if`         | Array [`BLOCK_SIZE`]           | Array of `VX_commit_if.slave` interfaces providing commit data from execution blocks.                            |

#### **Input Structured Ports (`commit_in_if`)**
| **Field**    | **Width**                          | **Description**                                                                                                  |
|--------------|------------------------------------|------------------------------------------------------------------------------------------------------------------|
| `valid`      | 1 bit                             | Indicates if the commit data in `data` is valid.                                                                 |
| `data`       | Struct (`VX_commit_if.data_t`)    | Commit data fields described in the `VX_commit_if` interface.                                                    |
| `ready`      | 1 bit                             | Indicates if the module is ready to accept the commit data.                                                      |

---

### Outputs
| **Port**               | **Width**                      | **Description**                                                                                                  |
|------------------------|---------------------------------|------------------------------------------------------------------------------------------------------------------|
| `commit_out_if`        | Array [`ISSUE_WIDTH`]          | Array of `VX_commit_if.master` interfaces providing consolidated commit responses to the next pipeline stage.     |

#### **Output Structured Ports (`commit_out_if`)**
| **Field**    | **Width**                          | **Description**                                                                                                  |
|--------------|------------------------------------|------------------------------------------------------------------------------------------------------------------|
| `valid`      | 1 bit                             | Indicates if the commit data in `data` is valid.                                                                 |
| `data`       | Struct (`VX_commit_if.data_t`)    | Consolidated commit data fields described in the `VX_commit_if` interface.                                       |
| `ready`      | 1 bit                             | Indicates if the next pipeline stage is ready to accept the commit data.                                         |

---

## Functionality

### Input Handling
1. **Commit Input Processing:**
   - `commit_in_if.valid`: Each input interface's `valid` signal indicates the availability of data for processing.
   - `commit_in_if.data`: The structured commit data (`uuid`, `wid`, `tmask`, etc.) is read and stored for further mapping.

2. **Block-to-Lane Mapping:**
   - The input blocks (`BLOCK_SIZE`) are mapped to output lanes (`ISSUE_WIDTH`) based on the warp ID (`wid`) and thread mask (`tmask`).
   - Proper handling ensures that data from the correct execution block is aligned with the corresponding output lane.

---

### Output Handling
1. **Commit Output Aggregation:**
   - `commit_out_if.valid`: Generated based on the validity of aggregated commit data.
   - `commit_out_if.data`: Contains consolidated data for the next pipeline stage. Each lane (`ISSUE_WIDTH`) receives appropriate commit data.

2. **Elastic Buffers:**
   - `OUT_BUF`: Configurable buffer ensures that backpressure from the downstream stages does not disrupt data flow.

3. **Partition Handling:**
   - If `PID_BITS > 0`, thread mask (`tmask`) and data (`data`) are aligned based on partition ID (`pid`).

---

## Elastic Buffers

Elastic buffers are used at the output stage to handle backpressure:
- **Configuration (`OUT_BUF`)**: Specifies the size and type of buffers (e.g., depth, output register enable).
- **Purpose**: Ensure data integrity and prevent pipeline stalls when downstream stages are temporarily unable to accept data.

---

## Example Use Case

For an example configuration:
- `BLOCK_SIZE = 4`
- `NUM_LANES = 8`
- `OUT_BUF = 2`

The `VX_gather_unit`:
- Accepts data from 4 execution blocks, each with 8 lanes.
- Consolidates this data into 16 lanes (`ISSUE_WIDTH = 16`).
- Handles thread alignment based on warp ID (`wid`) and partition ID (`pid`).

```markdown
