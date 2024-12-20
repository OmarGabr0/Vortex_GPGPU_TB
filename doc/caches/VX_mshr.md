# MSHR

## Allocate

The allocation process involves:

1. Finding a free MSHR entry.
2. Checking for pending requests for the same address.
3. Linking the new entry to any previous request for the same address.
4. Marking the new entry as valid and recording its address, data, and request type.

### **Inputs/Outputs and Parameters**

```verilog
input wire                          allocate_valid,
input wire [`CS_LINE_ADDR_WIDTH-1:0] allocate_addr,
input wire                          allocate_rw,
input wire [DATA_WIDTH-1:0]         allocate_data,
output wire [MSHR_ADDR_WIDTH-1:0]   allocate_id,
output wire                         allocate_pending,
output wire [MSHR_ADDR_WIDTH-1:0]   allocate_previd,
output wire                         allocate_ready,
```

- **Inputs:**
  - `allocate_valid`: Indicates if a new allocation request is valid.
  - `allocate_addr`: The cache line address for which an entry needs to be allocated.
  - `allocate_rw`: Specifies if the request is a read (0) or write (1).
  - `allocate_data`: Data associated with the request.

- **Outputs:**
  - `allocate_id`: The ID of the allocated MSHR entry.
  - `allocate_pending`: Indicates if there are pending requests for the same address.
  - `allocate_previd`: The ID of the previous request for the same address.
  - `allocate_ready`: Indicates if the allocation is ready to proceed.

### **Allocation Logic**

1. **Detecting Free MSHR Entry**

   ```verilog
   VX_lzc #(
       .N (MSHR_SIZE),
       .REVERSE (1)
   ) allocate_sel (
       .data_in   (~valid_table_n),
       .data_out  (allocate_id_n),
       .valid_out (allocate_rdy_n)
   );
   ```

   - This logic uses a **leading-zero counter (LZC)** to find the first free entry in the `valid_table_n`.
   - `allocate_id_n` holds the ID of the next free slot, and `allocate_rdy_n` indicates if a free slot is available.

2. **Finding the Previous Request for the Same Address**

   ```verilog
   wire [MSHR_SIZE-1:0] addr_matches;
   for (genvar i = 0; i < MSHR_SIZE; ++i) begin : g_addr_matches
       assign addr_matches[i] = valid_table[i] && (addr_table[i] == allocate_addr);
   end
   ```

   - This loop compares `allocate_addr` with addresses in the `addr_table` for valid entries. The result is stored in `addr_matches`, a bit vector where each bit corresponds to an entry in the MSHR.

   ```verilog
   VX_priority_encoder #(
       .N (MSHR_SIZE)
   ) prev_sel (
       .data_in (addr_matches & ~next_table_x),
       .index_out (prev_idx),
       `UNUSED_PIN (onehot_out),
       `UNUSED_PIN (valid_out)
   );
   ```

   - A **priority encoder** is used to find the ID of the most recent entry (`prev_idx`) for the same address that does not have a `next_table_x` pointer.

3. **Allocate Request Fired**

   ```verilog
   wire allocate_fire = allocate_valid && allocate_ready;
   ```

   - `allocate_fire` triggers when a valid allocation request is received, and there is a free slot available.

4. **Updating Tables on Allocation**

   ```verilog
   always @(*) begin
       if (allocate_fire) begin
           valid_table_n[allocate_id] = 1;
           next_table_n[allocate_id] = 0;
       end
   end
   ```

   - When an allocation occurs:
     - The `valid_table_n` is updated to mark the new entry as valid.
     - The `next_table_n` entry for the allocated slot is cleared to indicate that it does not yet point to another request.

   ```verilog
   always @(posedge clk) begin
       if (allocate_fire) begin
           addr_table[allocate_id] <= allocate_addr;
           write_table[allocate_id] <= allocate_rw;
       end
   end
   ```

   - At the clock's positive edge, if an allocation occurs:
     - The `addr_table` stores the address associated with the new entry.
     - The `write_table` records whether the request is a read or write.

5. **Pending and Previous Entry Outputs**

   ```verilog
   if (WRITEBACK) begin : g_pending_wb
       assign allocate_pending = |addr_matches;
   end else begin : g_pending_wt
       assign allocate_pending = |(addr_matches & ~write_table);
   end
   ```

   - If **write-back** is enabled, `allocate_pending` is set if any valid request matches the address.
   - If **write-through** is enabled, write requests are excluded from pending checks.

   ```verilog
   assign allocate_previd = prev_idx;
   ```

   - The ID of the most recent request for the same address is passed as `allocate_previd`.

6. **Allocate Outputs**

   ```verilog
   assign allocate_ready = allocate_rdy;
   assign allocate_id = allocate_id_r;
   ```

   - `allocate_ready` indicates if the MSHR is ready to accept a new request.
   - `allocate_id` provides the ID of the allocated entry.

Here is a detailed breakdown of the **dequeue** process, following the style of the **allocate** section:

## Dequeue

The dequeue process involves:

1. Detecting a valid fill request and marking the corresponding MSHR entry for dequeuing.
2. Iteratively releasing entries for a cache line and following the linked list to process all pending requests for the same address.
3. Managing valid entries in the MSHR and clearing them when processed.

### **Inputs/Outputs and Parameters**

```verilog
output wire                         dequeue_valid,
output wire [`CS_LINE_ADDR_WIDTH-1:0] dequeue_addr,
output wire                         dequeue_rw,
output wire [DATA_WIDTH-1:0]        dequeue_data,
output wire [MSHR_ADDR_WIDTH-1:0]   dequeue_id,
input wire                          dequeue_ready,
```

- **Outputs:**
  - `dequeue_valid`: Indicates if there is a valid MSHR entry ready for dequeuing.
  - `dequeue_addr`: The cache line address of the entry being dequeued.
  - `dequeue_rw`: Specifies if the request is a read (0) or write (1).
  - `dequeue_data`: Data associated with the dequeued request.
  - `dequeue_id`: The ID of the MSHR entry being dequeued.

- **Inputs:**
  - `dequeue_ready`: Indicates if the downstream pipeline is ready to accept the dequeued request.

### **Dequeue Logic**

1. **Initiating Dequeue**

   ```verilog
   always @(*) begin
       if (fill_valid) begin
           dequeue_val_n = 1;
           dequeue_id_n = fill_id;
       end
   end
   ```

   - The `fill_valid` signal starts the dequeue process by marking the entry specified by `fill_id` for dequeuing.

2. **Releasing Entries**

   ```verilog
   if (dequeue_fire) begin
       valid_table_n[dequeue_id] = 0;
       if (next_table[dequeue_id]) begin
           dequeue_id_n = next_index[dequeue_id];
       end else if (finalize_valid && finalize_is_pending && (finalize_previd == dequeue_id)) begin
           dequeue_id_n = finalize_id;
       end else begin
           dequeue_val_n = 0;
       end
   end
   ```

   - When a dequeue operation is fired:
     - The `valid_table_n` is updated to mark the entry as invalid.
     - If the entry has a next pointer (`next_table`), the ID is updated to the next entry.
     - If a pending finalize request is linked to the current entry, it is processed.
     - If no further entries are linked, the dequeue process ends.

3. **Updating Tables and State**

   ```verilog
   always @(posedge clk) begin
       if (reset) begin
           valid_table  <= '0;
           dequeue_val  <= 0;
       end else begin
           valid_table  <= valid_table_n;
           dequeue_val  <= dequeue_val_n;
       end

       dequeue_id_r <= dequeue_id_n;
   end
   ```

   - On a clock edge, the valid table and dequeue state are updated:
     - `valid_table` reflects the updated entry states.
     - `dequeue_val` indicates if dequeuing is active.
     - `dequeue_id_r` holds the ID of the current entry being dequeued.

4. **Outputs**

   ```verilog
   assign dequeue_valid = dequeue_val;
   assign dequeue_addr  = addr_table[dequeue_id_r];
   assign dequeue_rw    = write_table[dequeue_id_r];
   assign dequeue_id    = dequeue_id_r;
   ```

   - `dequeue_valid`: Indicates if a valid request is ready for dequeuing.
   - `dequeue_addr`: Outputs the address of the current dequeued entry.
   - `dequeue_rw`: Outputs the type of the request (read/write).
   - `dequeue_id`: Outputs the ID of the dequeued entry.

### **Dequeue Data Handling**

1. **Fetching Data for Dequeue**

   ```verilog
   VX_dp_ram #(
       .DATAW (DATA_WIDTH),
       .SIZE  (MSHR_SIZE),
       .RDW_MODE ("R")
   ) mshr_store (
       .clk   (clk),
       .reset (reset),
       .read  (1'b1),
       .write (allocate_valid),
       .wren  (1'b1),
       .waddr (allocate_id_r),
       .wdata (allocate_data),
       .raddr (dequeue_id_r),
       .rdata (dequeue_data)
   );
   ```

   - The `mshr_store` module retrieves the data associated with the dequeued entry based on `dequeue_id_r`.

2. **Final Outputs**

   ```verilog
   assign dequeue_data = mshr_store.rdata;
   ```

   - The `dequeue_data` output provides the data for the current dequeued entry.
