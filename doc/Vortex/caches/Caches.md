# Cache System

## Stream Crossbar

### Stream Arbiter

The `VX_stream_arb` module is a versatile arbitration component designed to handle multiple input streams and arbitrate access to one or more output streams. It supports configurable arbitration policies, output buffering, and scaling for high fanout systems.

#### **Parameters**

| **Parameter**       | **Default Value**       | **Description**                                                                 |
|----------------------|-------------------------|---------------------------------------------------------------------------------|
| `NUM_INPUTS`        | `1`                     | Number of input streams.                                                        |
| `NUM_OUTPUTS`       | `1`                     | Number of output streams.                                                       |
| `DATAW`             | `1`                     | Width of the data in each stream (in bits).                                     |
| `ARBITER`           | `"R"`                   | Arbitration policy (e.g., "R" for round-robin).                                 |
| `MAX_FANOUT`        | ``MAX_FANOUT``          | Maximum fanout limit for arbitration.                                           |
| `OUT_BUF`           | `0`                     | Configures output buffering (size and type).                                    |
| `NUM_REQS`          | ``CDIV(NUM_INPUTS, NUM_OUTPUTS)`` | Number of requests per output.                                                   |
| `LOG_NUM_REQS`      | ``CLOG2(NUM_REQS)``     | Logarithmic size of requests for indexing.                                      |
| `NUM_REQS_W`        | ``UP(LOG_NUM_REQS)``    | Bit-width for the number of requests.                                           |

#### **Ports**

| **Port**           | **Direction** | **Width**                          | **Description**                                                                |
|---------------------|---------------|------------------------------------|--------------------------------------------------------------------------------|
| `valid_in`         | **input**     | `NUM_INPUTS`                       | Valid signals for each input stream.                                           |
| `data_in`          | **input**     | `NUM_INPUTS x DATAW`               | Data input for each stream, with `DATAW`-bit width per stream.                 |
| `ready_in`         | **output**    | `NUM_INPUTS`                       | Ready signals for each input stream, indicating the module can accept data.    |
| `valid_out`        | **output**    | `NUM_OUTPUTS`                      | Valid signals for each output stream, indicating the module has data ready.    |
| `data_out`         | **output**    | `NUM_OUTPUTS x DATAW`              | Data output for each stream, with `DATAW`-bit width per stream.                |
| `sel_out`          | **output**    | `NUM_OUTPUTS x NUM_REQS_W`         | Selected input stream index for each output stream.                            |
| `ready_out`        | **input**     | `NUM_OUTPUTS`                      | Ready signals for each output stream, indicating downstream readiness.         |

It will always use `.NUM_OUTPUTS (1)`, which effectively means that each bank will have its own arbiter, so this part in VX_stream_arb is instantiated:

#### Normal Operation

```verilog
    end else begin : g_one_output

    // (#inputs <= max_fanout) and (#outputs == 1)

    wire                    valid_in_w;
    wire [DATAW-1:0]        data_in_w;
    wire                    ready_in_w;

    wire                    arb_valid;
    wire [NUM_REQS_W-1:0]   arb_index;
    wire [NUM_REQS-1:0]     arb_onehot;
    wire                    arb_ready;

    VX_generic_arbiter #(
        .NUM_REQS (NUM_REQS),
        .TYPE     (ARBITER)
    ) arbiter (
        .clk          (clk),
        .reset        (reset),
        .requests     (valid_in),
        .grant_valid  (arb_valid),
        .grant_index  (arb_index),
        .grant_onehot (arb_onehot),
        .grant_ready  (arb_ready)
    );

    assign valid_in_w = arb_valid;
    assign data_in_w  = data_in[arb_index];
    assign arb_ready  = ready_in_w;

    for (genvar i = 0; i < NUM_REQS; ++i) begin : g_ready_in
        assign ready_in[i] = ready_in_w && arb_onehot[i];
    end

    VX_elastic_buffer #(
        .DATAW   (LOG_NUM_REQS + DATAW),
        .SIZE    (`TO_OUT_BUF_SIZE(OUT_BUF)),
        .OUT_REG (`TO_OUT_BUF_REG(OUT_BUF)),
        .LUTRAM  (`TO_OUT_BUF_LUTRAM(OUT_BUF))
    ) out_buf (
        .clk       (clk),
        .reset     (reset),
        .valid_in  (valid_in_w),
        .ready_in  (ready_in_w),
        .data_in   ({arb_index, data_in_w}),
        .data_out  ({sel_out, data_out}),
        .valid_out (valid_out),
        .ready_out (ready_out)
    );
end
```

1. VX_generic_arbiter

    It uses round robin as the generic arbiter `.ARBITER ("R")`.

    **Key Components**

    #### **1. Signals and Registers:**

    - **Inputs:**
    - `requests`: A vector of size `NUM_REQS` indicating active requests.
    - `grant_ready`: Indicates whether the arbiter can grant a new request.
    - `reset`: Resets internal state.
    - `clk`: Clock signal for synchronous logic.

    - **Outputs:**
    - `grant_onehot`: A one-hot vector of size `NUM_REQS` indicating which request was granted.
    - `grant_index`: Encoded index of the granted request.
    - `grant_valid`: Indicates if a valid grant was made.

    - **Internal Signals:**
    - `masked_reqs`: Current requests masked by `reqs_mask`.
    - `masked_pri_reqs` & `unmasked_pri_reqs`: Priority masks for the masked and unmasked requests.
    - `grant_masked` & `grant_unmasked`: One-hot grant signals for masked and unmasked requests.
    - `has_masked_reqs` & `has_unmasked_reqs`: Indicates if there are valid masked or unmasked requests.

    - **Registers:**
    - `reqs_mask`: Tracks the priority state for masking requests.

    ---

    **Behavior and Key Logic**

    **2. Generating Masked and Unmasked Priority Requests**

    - **Masked Requests (`masked_pri_reqs`):**
    - Iteratively calculates a priority mask for the `masked_reqs` vector (requests that pass the current `reqs_mask`).
    - For each bit, it propagates priority based on previous bits:

        ```verilog
        assign masked_pri_reqs[i] = masked_pri_reqs[i-1] | masked_reqs[i-1];
        ```

    - **Unmasked Requests (`unmasked_pri_reqs`):**
    - Similar logic applies to the original `requests` vector, generating a priority mask for all unmasked requests.

    **3. Grant Selection**

    - **Grant Masking Logic:**
    - The arbiter grants the highest priority request based on two conditions:
        1. **Masked Requests**: If there are valid `masked_reqs`, it grants the request with the highest priority:

        ```verilog
        wire [NUM_REQS-1:0] grant_masked = masked_reqs & ~masked_pri_reqs;
        ```

        2. **Unmasked Requests**: Otherwise, it grants the request with the highest priority among all requests:

        ```verilog
        wire [NUM_REQS-1:0] grant_unmasked = requests & ~unmasked_pri_reqs;
        ```

    - The final one-hot grant signal (`grant_onehot`) is chosen based on availability:

    ```verilog
    assign grant_onehot = has_masked_reqs ? grant_masked : grant_unmasked;
    ```

    **4. Updating the Mask**

    - The mask (`reqs_mask`) updates every clock cycle when `grant_ready` is asserted:
    - If a masked request is granted, the mask becomes the `masked_pri_reqs` vector.
    - If an unmasked request is granted, the mask becomes the `unmasked_pri_reqs` vector.
    - During a reset, the mask is initialized to allow all requests (`{NUM_REQS{1'b1}}`):

        ```verilog
        always @(posedge clk) begin
            if (reset) begin
                reqs_mask <= {NUM_REQS{1'b1}};
            end else if (grant_ready) begin
                if (has_masked_reqs) begin
                    reqs_mask <= masked_pri_reqs;
                end else if (has_unmasked_reqs) begin
                    reqs_mask <= unmasked_pri_reqs;
                end
            end
        end
        ```

    **5. Grant Index and Validity**

    - A `VX_encoder` module encodes the one-hot grant signal (`grant_onehot`) into the corresponding index (`grant_index`) and outputs a validity signal (`grant_valid`):

        ```verilog
        VX_encoder #(
            .N (NUM_REQS)
        ) onehot_encoder (
            .data_in  (grant_onehot),
            .data_out (grant_index),
            .valid_out(grant_valid)
        );
        ```

2. VX_elastic_buffer

    From VX_cache: `OUT_BUF` will be either 2 or 0

    ```verilog
        localparam REQ_XBAR_BUF = (NUM_REQS > 4) ? 2 : 0;
        .OUT_BUF     (REQ_XBAR_BUF)
    ```

    From VX_platform

    ```verilog
        // size(x): 0 -> 0, 1 -> 1, 2 -> 2, 3 -> 2, 4-> 2, 5 -> 2
        `define TO_OUT_BUF_SIZE(s)    `MIN(s & 7, 2)

        // reg(x): 0 -> 0, 1 -> 1, 2 -> 0, 3 -> 1, 4 -> 2, 5 > 3
        `define TO_OUT_BUF_REG(s)     (((s & 7) < 2) ? (s & 7) : ((s & 7) - 2))

        // lut(x): (x & 8) != 0
        `define TO_OUT_BUF_LUTRAM(s)  ((s & 8) != 0)
    ```

    The elastic buffer will be either a streaming buffer (size = 2) or a wire (size = 0)

    ```verilog
        .SIZE    (`TO_OUT_BUF_SIZE(OUT_BUF)),
    ```

    The output will not be buffered (`OUT_REG` = 0)

    ```verilog
        .OUT_REG (`TO_OUT_BUF_REG(OUT_BUF)),
    ```

    `LUTRAM` will be 0:

    ```verilog
        .LUTRAM  (`TO_OUT_BUF_LUTRAM(OUT_BUF))
    ```

#### Number of Requests > Maximum Fanout

When the number of input requests exceeds the `MAX_FANOUT` parameter, the arbitration logic splits the inputs into manageable slices. Each slice is handled by a separate instance of the `VX_stream_arb` module. This ensures that the crossbar design can scale efficiently without exceeding the maximum fanout limit for a single arbiter. The slicing process allows for parallel processing of smaller subsets of the inputs, which are then merged into a single output.

```verilog
    end else if (MAX_FANOUT != 0 && (NUM_INPUTS > (MAX_FANOUT + MAX_FANOUT /2))) begin : g_fanout

    // (#inputs > max_fanout) and (#outputs == 1)

    localparam NUM_SLICES    = `CDIV(NUM_INPUTS, MAX_FANOUT);
    localparam LOG_NUM_REQS2 = `CLOG2(MAX_FANOUT);
    localparam LOG_NUM_REQS3 = `CLOG2(NUM_SLICES);

    wire [NUM_SLICES-1:0]   valid_tmp;
    wire [NUM_SLICES-1:0][DATAW+LOG_NUM_REQS2-1:0] data_tmp;
    wire [NUM_SLICES-1:0]   ready_tmp;

    for (genvar i = 0; i < NUM_SLICES; ++i) begin : g_fanout_slice_arbs

        localparam SLICE_BEGIN = i * MAX_FANOUT;
        localparam SLICE_END   = `MIN(SLICE_BEGIN + MAX_FANOUT, NUM_INPUTS);
        localparam SLICE_SIZE  = SLICE_END - SLICE_BEGIN;

        wire [DATAW-1:0] data_tmp_u;
        wire [`LOG2UP(SLICE_SIZE)-1:0] sel_tmp_u;

        VX_stream_arb #(
            .NUM_INPUTS  (SLICE_SIZE),
            .NUM_OUTPUTS (1),
            .DATAW       (DATAW),
            .ARBITER     (ARBITER),
            .MAX_FANOUT  (MAX_FANOUT),
            .OUT_BUF     (3)
        ) fanout_slice_arb (
            .clk       (clk),
            .reset     (reset),
            .valid_in  (valid_in[SLICE_END-1: SLICE_BEGIN]),
            .data_in   (data_in[SLICE_END-1: SLICE_BEGIN]),
            .ready_in  (ready_in[SLICE_END-1: SLICE_BEGIN]),
            .valid_out (valid_tmp[i]),
            .data_out  (data_tmp_u),
            .sel_out   (sel_tmp_u),
            .ready_out (ready_tmp[i])
        );

        assign data_tmp[i] = {data_tmp_u, LOG_NUM_REQS2'(sel_tmp_u)};
    end

    wire [DATAW+LOG_NUM_REQS2-1:0] data_out_u;
    wire [LOG_NUM_REQS3-1:0] sel_out_u;

    VX_stream_arb #(
        .NUM_INPUTS  (NUM_SLICES),
        .NUM_OUTPUTS (1),
        .DATAW       (DATAW + LOG_NUM_REQS2),
        .ARBITER     (ARBITER),
        .MAX_FANOUT  (MAX_FANOUT),
        .OUT_BUF     (OUT_BUF)
    ) fanout_join_arb (
        .clk       (clk),
        .reset     (reset),
        .valid_in  (valid_tmp),
        .ready_in  (ready_tmp),
        .data_in   (data_tmp),
        .data_out  (data_out_u),
        .sel_out   (sel_out_u),
        .valid_out (valid_out),
        .ready_out (ready_out)
    );

    assign data_out = data_out_u[LOG_NUM_REQS2 +: DATAW];
    assign sel_out = {sel_out_u, data_out_u[0 +: LOG_NUM_REQS2]};
```

##### Key Steps in the Implementation

1. **Slicing the Inputs:**
   - The inputs are divided into `NUM_SLICES`, where each slice contains up to `MAX_FANOUT` inputs.
   - The slicing is calculated using:

     ```verilog
     localparam NUM_SLICES = `CDIV(NUM_INPUTS, MAX_FANOUT);
     ```

     This ensures that all input requests are evenly distributed among the slices, with the last slice handling any remaining inputs if `NUM_INPUTS` is not a multiple of `MAX_FANOUT`.

2. **Instantiating Slice Arbiters:**
   - For each slice, a separate `VX_stream_arb` instance arbitrates between the inputs within that slice. The parameters for these instances are dynamically calculated based on the slice size.
   - The `SLICE_BEGIN` and `SLICE_END` indices determine the range of inputs for each slice:

     ```verilog
     localparam SLICE_BEGIN = i * MAX_FANOUT;
     localparam SLICE_END   = `MIN(SLICE_BEGIN + MAX_FANOUT, NUM_INPUTS);
     ```

     - `SLICE_SIZE` is the number of inputs in the current slice.

3. **Data Encoding and Selection:**
   - The output data from each slice is augmented with the selection signal (`sel_tmp_u`) to indicate which input was selected.
   - This augmented data is stored in `data_tmp`, with the selection signal occupying the upper bits.

4. **Merging the Slices:**
   - After processing all slices, their outputs are merged using another `VX_stream_arb` instance (referred to as the **fanout join arbiter**). This arbiter consolidates the outputs from the slice arbiters into a single output.
   - The join arbiter:
     - Takes the `valid_tmp` signals as the input validity indicators.
     - Accepts the augmented `data_tmp` as the input data.
     - Outputs the final selected data (`data_out_u`) and selection (`sel_out_u`).

5. **Final Output Assignment:**
   - The final selected data and selection signals are extracted from the augmented data structure:

     ```verilog
     assign data_out = data_out_u[LOG_NUM_REQS2 +: DATAW];
     assign sel_out = {sel_out_u, data_out_u[0 +: LOG_NUM_REQS2]};
     ```
