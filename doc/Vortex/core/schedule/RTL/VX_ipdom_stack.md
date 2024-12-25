# VX_ipdom_stack

## Parameters

| Parameter   | Default Value | Description                                                               |
|-------------|---------------|---------------------------------------------------------------------------|
| `WIDTH`     | `1`           | Width of the data elements in the stack.                                  |
| `DEPTH`     | `1`           | Depth (size) of the stack.                                                |
| `OUT_REG`   | `0`           | Specifies whether to use an output register (1 for enabled, 0 for disabled).|
| `ADDRW`     | `LOG2UP(DEPTH)` | Address width required to address the stack depth.                        |

## Code

```verilog
always @(posedge clk) begin
    if (reset) begin
        rd_ptr  <= '0;
        wr_ptr  <= '0;
        empty_r <= 1;
        full_r  <= 0;
    end else begin
        `ASSERT(~push || ~full, ("%t: runtime error: writing to a full stack!", $time));
        `ASSERT(~pop || ~empty, ("%t: runtime error: reading an empty stack!", $time));
        `ASSERT(~push || ~pop,  ("%t: runtime error: push and pop in same cycle not supported!", $time));
        if (push) begin
            rd_ptr  <= wr_ptr;
            wr_ptr  <= wr_ptr + ADDRW'(1);
            empty_r <= 0;
            full_r  <= (ADDRW'(DEPTH-1) == wr_ptr);
        end else if (pop) begin
            wr_ptr  <= wr_ptr - ADDRW'(d_set_n);
            rd_ptr  <= rd_ptr - ADDRW'(d_set_n);
            empty_r <= (rd_ptr == 0) && (d_set_n == 1);
            full_r  <= 0;
        end
    end
end
```

- This block manages the read (`rd_ptr`) and write (`wr_ptr`) pointers of the stack, ensuring that data is correctly pushed and popped, with checks for overflow (full) and underflow (empty).

```verilog
VX_dp_ram #(
    .DATAW   (WIDTH * 2),
    .SIZE    (DEPTH),
    .OUT_REG (OUT_REG ? 1 : 0),
    .LUTRAM  (OUT_REG ? 0 : 1)
) store (
    .clk   (clk),
    .reset (reset),
    .read  (1'b1),
    .write (push),
    .wren  (1'b1),
    .waddr (wr_ptr),
    .wdata ({q1, q0}),
    .raddr (rd_ptr),
    .rdata ({d1, d0})
);
```

- This block uses a dual-port RAM (`VX_dp_ram`) to store data written to the stack, and to read data from the stack. Data is stored in the `wr_ptr` location and read from the `rd_ptr` location.

```verilog
always @(posedge clk) begin
    if (push) begin
        slot_set[wr_ptr] <= 0;
    end else if (pop) begin
        slot_set[rd_ptr] <= 1;
    end
end
```

- This block manages the status of stack slots, ensuring they are marked as set when they are popped.

```verilog
assign d     = d_set_r ? d0 : d1;
assign d_set = ~d_set_r;
assign q_ptr = wr_ptr;
assign empty = empty_r;
assign full  = full_r;
```

- These assignments control the output data (`d`), the `d_set` signal, and the stack pointer (`q_ptr`). Additionally, the `empty` and `full` flags are driven based on the stack status.

```verilog
VX_pipe_register #(
    .DATAW (1),
    .DEPTH (OUT_REG)
) pipe_reg (
    .clk      (clk),
    .reset    (reset),
    .enable   (1'b1),
    .data_in  (d_set_n),
    .data_out (d_set_r)
);
```

- This register stores the `d_set` signal, ensuring that data is either selected from `d0` or `d1` based on the state of `d_set_r`.
