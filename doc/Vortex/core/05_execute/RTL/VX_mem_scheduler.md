# VX_mem_scheduler Documentation

The `VX_mem_scheduler` is a configurable memory scheduler responsible for handling memory requests from the core, managing coalescing (if enabled), and interacting with the memory system. Its behavior is determined by the provided parameters, particularly whether coalescing is enabled and the size of request and response queues.

---

## Key Configuration Parameters

| Parameter           | Value in `VX_lsu_slice` | Description                                                                 |
|---------------------|--------------------------|-----------------------------------------------------------------------------|
| `COALESCE_ENABLE`   | `0` (disabled)          | Determines whether coalescing of memory requests is enabled.                |
| `CORE_REQS`         | Number of LSU lanes     | Number of memory requests supported by the core simultaneously.             |
| `MEM_CHANNELS`      | Number of LSU lanes     | Number of memory channels for parallel memory requests.                     |
| `WORD_SIZE`         | `LSU_WORD_SIZE`         | Size of each memory word in bytes.                                          |
| `LINE_SIZE`         | `LSU_WORD_SIZE`         | Size of each memory line (no coalescing, so this equals `WORD_SIZE`).       |
| `CORE_QUEUE_SIZE`   | `LSUQ_IN_SIZE`          | Number of entries in the core request queue.                                |
| `MEM_QUEUE_SIZE`    | `LSUQ_OUT_SIZE`         | Number of entries in the memory request queue.                              |
| `UUID_WIDTH`        | `UUID_WIDTH`            | Width of the unique identifier for each memory request.                     |
| `CORE_OUT_BUF`      | `0`                     | Output buffering for core responses.                                        |
| `MEM_OUT_BUF`       | `0`                     | Output buffering for memory responses.                                      |
| `RSP_PARTIAL`       | `1` (enabled)           | Enables partial responses for memory requests, allowing out-of-order replies.|

---

## Overview of Behavior

### Coalescing Disabled
In this configuration:
- **Memory requests are handled directly.** Each request corresponds to a single word (`WORD_SIZE` equals `LINE_SIZE`).
- **Request splitting and merging are skipped.** The `COALESCE_ENABLE` parameter is set to `0`.
- **Simpler memory interaction:** The scheduler bypasses the `VX_mem_coalescer` logic and directly connects core requests to memory channels.

---

## Functionality

### 1. **Core Request Handling**
- Accepts memory requests from the core (`core_req_valid`) and manages them through an internal request queue (`CORE_QUEUE_SIZE`).
- Ensures only valid requests with non-zero thread masks are processed.

### 2. **Memory Request Management**
- Each core request is directly mapped to memory channels without grouping or coalescing.
- Memory addresses are calculated and sent directly to the memory system.

### 3. **Response Management**
- **Partial responses (`RSP_PARTIAL` enabled):** Allows memory responses to arrive out-of-order and processes them as they are received.
- **Tag mapping:** Uses the `UUID_WIDTH` and internal indexing to track responses back to their originating core requests.

---

## Instantiation in `VX_lsu_slice`

### Parameters
The following parameters are passed to the `VX_mem_scheduler` instance in `VX_lsu_slice`:
- **No coalescing (`COALESCE_ENABLE = 0`):** Ensures memory requests are handled on a per-word basis, aligning with the LSU configuration.
- **Request and response queue sizes:** Configured via `LSUQ_IN_SIZE` and `LSUQ_OUT_SIZE` to match the needs of the LSU.
- **Memory system width:** Matches the LSU word size (`LSU_WORD_SIZE`) for both requests and responses.

### Connections
- **Core Request Interface:** Directly maps `VX_execute_if` signals to the `core_req_*` signals of the scheduler.
- **Memory Response Interface:** Maps memory responses back to the LSU via `VX_commit_if`.

---

## Summary

The `VX_mem_scheduler` in this configuration is tailored for non-coalescing behavior, with each memory request corresponding to a single word. This simplifies the interaction between the LSU and the memory system, ensuring compatibility with the design constraints of `VX_lsu_slice`.
