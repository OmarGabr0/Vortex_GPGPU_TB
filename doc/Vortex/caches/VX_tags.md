# VX_cache_tags Module Documentation

The `VX_cache_tags` module is responsible for managing tag storage for a set-associative cache. It supports initialization, flushing, tag matching, filling, reading, writing, and eviction. The module employs single-port RAM (`VX_sp_ram`) instances to store and retrieve tag metadata for each cache way.

## Parameter Table

| **Parameter**      | **Description**                                        | **Default Value**  |
|--------------------|--------------------------------------------------------|--------------------|
| `CACHE_SIZE`       | Size of the cache in bytes                             | 1024               |
| `LINE_SIZE`        | Size of a line inside a bank in bytes                  | 16                 |
| `NUM_BANKS`        | Number of banks in the cache                           | 1                  |
| `NUM_WAYS`         | Number of associative ways in the cache                | 1                  |
| `WORD_SIZE`        | Size of a word in bytes                                | 1                  |
| `WRITEBACK`        | Enable cache writeback (1 = enabled, 0 = disabled)     | 0                  |

## Ports Table

| **Port Name**                | **Direction**   | **Description**                                                                                                                                           |
|------------------------------|-----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| `clk`                         | input           | Clock signal                                                                                                                                             |
| `reset`                       | input           | Reset signal                                                                                                                                             |
| `init`                        | input           | Initializes the cache (clears all tags and valid bits)                                                                                                  |
| `flush`                       | input           | Clears or writes back cache contents based on the cache write policy                                                                                     |
| `fill`                        | input           | Stores a new tag into the cache and sets the valid bit (and optionally dirty bit in writeback mode)                                                     |
| `read`                        | input           | Retrieves tag, valid, and dirty information for all ways at the specified line index                                                                    |
| `write`                       | input           | Updates the dirty bit for a matching tag in writeback mode                                                                                              |
| `line_idx`                    | input           | Line index for the cache operation (address of the cache line)                                                                                         |
| `line_tag`                    | input           | Tag to be checked or stored in the cache                                                                                                                 |
| `evict_way`                   | input           | Identifies the cache way for eviction                                                                                                                    |
| `tag_matches`                 | output          | Array of match results for each cache way indicating if the requested tag matches the stored tag for each way                                           |
| `evict_dirty`                 | output          | Dirty bit of the cache line to be evicted (only valid in writeback mode)                                                                                |
| `evict_tag`                   | output          | Tag of the cache line to be evicted                                                                                                                      |

## Initialization

- **Purpose:** Resets the cache by clearing all tags and valid bits.
- **Trigger:** `init`
- **Code:**
  ```verilog
  wire do_init = init; // init all ways
  wire line_write = do_init || do_fill || do_flush || do_write;
  ```

---

## Flush
- **Purpose:** Clears or writes back cache contents based on the cache write policy.
- **Trigger:** `flush`
- **Code:**
  ```verilog
  wire do_flush = flush && (!WRITEBACK || way_en); // flush the whole line in writethrough mode
  wire line_write = do_init || do_fill || do_flush || do_write;
  ```

---

## Tag Matching
- **Purpose:** Determines if the requested `line_tag` matches any stored tag for the specified `line_idx`.
- **Trigger:** `line_tag`
- **Code:**
  ```verilog
  assign tag_matches[i] = read_valid[i] && (line_tag == read_tag[i]);
  ```

---

## Fill
- **Purpose:** Stores a new tag into the cache and sets the valid bit (and optionally dirty bit in writeback mode).
- **Trigger:** `fill`
- **Code:**
  ```verilog
  wire do_fill = fill && way_en;
  wire line_valid = fill || write;
  wire [TAG_WIDTH-1:0] line_wdata;
  if (WRITEBACK) begin : g_wdata
      assign line_wdata = {line_valid, write, line_tag};
  end else begin : g_wdata
      assign line_wdata = {line_valid, line_tag};
  end
  ```

---

## Read
- **Purpose:** Retrieves tag, valid, and dirty information for all ways at the specified `line_idx`.
- **Trigger:** `read`
- **Code:**
  ```verilog
  wire line_read = read || write || (WRITEBACK && (fill || flush));
  VX_sp_ram #(
      .DATAW (TAG_WIDTH),
      .SIZE  (`CS_LINES_PER_BANK),
      .RDW_MODE ("W")
  ) tag_store (
      .clk   (clk),
      .reset (reset),
      .read  (line_read),
      .write (line_write),
      .addr  (line_idx),
      .wdata (line_wdata),
      .rdata (line_rdata)
  );
  ```

---

## Write
- **Purpose:** Updates the dirty bit for a matching tag in writeback mode.
- **Trigger:** `write`
- **Code:**
  ```verilog
  wire do_write = WRITEBACK && write && tag_matches[i];
  wire line_write = do_init || do_fill || do_flush || do_write;
  ```

---

## Eviction
- **Purpose:** Identifies the tag and dirty state of a cache line for eviction.
- **Trigger:** `evict_way`
- **Code:**
  ```verilog
  if (WRITEBACK) begin : g_evict_tag_wb
      assign evict_dirty = read_dirty[evict_way];
      assign evict_tag = read_tag[evict_way];
  end else begin : g_evict_tag_wt
      assign evict_dirty = 1'b0;
      assign evict_tag = '0;
  end
  ```

---

## SRAM Integration

The `VX_cache_tags` module relies on **single-port RAM** (`VX_sp_ram`) to store metadata for each cache way. Metadata includes the tag bits, valid bit, and optional dirty bit. Each way uses an independent SRAM instance.

### **Key Details**
1. **Metadata Width:** 
   - The stored data (`TAG_WIDTH`) includes:
     - Valid bit
     - Dirty bit (only in writeback mode)
     - Tag bits
   - Defined as:
     ```verilog
     localparam TAG_WIDTH = 1 + WRITEBACK + `CS_TAG_SEL_BITS;
     ```

2. **Single Port RAM Instantiation:**
   Each way uses a single-port RAM for storing metadata:
   ```verilog
   VX_sp_ram #(
       .DATAW (TAG_WIDTH),             // Width of each memory entry
       .SIZE  (`CS_LINES_PER_BANK),    // Number of lines in the bank
       .RDW_MODE ("W")                 // Read/Write mode
   ) tag_store (
       .clk   (clk),                   // Clock signal
       .reset (reset),                 // Reset signal
       .read  (line_read),             // Read enable signal
       .write (line_write),            // Write enable signal
       .addr  (line_idx),              // Line index for read/write access
       .wdata (line_wdata),            // Data to be written to the RAM
       .rdata (line_rdata)             // Data read from the RAM
   );
   ```

3. **Read and Write Operations:**
   - **Read:** Triggered by the `line_read` signal, outputs stored metadata for a specific line index.
   - **Write:** Triggered by the `line_write` signal, updates metadata at the specified line index.