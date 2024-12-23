# **Operand.h**

## **Constructor**

### `Operand(const SimContext& ctx)`

- **Description**: Constructs an `Operand` object and initializes its simulation ports and internal state.
- **Parameters**:
  - `ctx`: A `SimContext` object that provides simulation context for the operand.
- **Behavior**:
  - Registers the `Operand` object with the simulation context.
  - Initializes the `Input` and `Output` simulation ports.
  - Sets the total stall counter (`total_stalls_`) to 0.

---

## **Destructor**

### `virtual ~Operand()`

- **Description**: Destroys the `Operand` object.
- **Behavior**:
  - Performs cleanup tasks, if any.
  - Ensures proper destruction of the simulation object.

---

## **Methods**

### `void reset()`

- **Description**: Resets the internal state of the `Operand` object.
- **Behavior**:
  - Resets the total stall counter (`total_stalls_`) to 0.

---

### `void tick()`

- **Description**: Executes the main logic of the `Operand` object during a simulation tick.
- **Behavior**:
  - Checks if there is an instruction in the `Input` port.
  - If an instruction is available:
    - Analyzes the source registers (`src_regs`) of the instruction to detect bank conflicts.
    - Computes the number of stalls caused by bank conflicts and increments the total stall counter (`total_stalls_`).
    - Pushes the instruction to the `Output` port with an added delay based on the number of stalls.
    - Logs debug information about the instruction.
  - Removes the processed instruction from the `Input` port.

---

### `uint32_t total_stalls() const`

- **Description**: Retrieves the total number of stalls encountered by the `Operand` object.
- **Return Value**:
  - The cumulative number of stalls caused by bank conflicts during the simulation.

---

## **Private Members**

### `static constexpr uint32_t NUM_BANKS`

- **Description**: Defines the number of banks used for detecting bank conflicts.
- **Value**:
  - A constant value of `4`.

---

### `uint32_t total_stalls_`

- **Description**: Tracks the total number of stalls caused by bank conflicts.
- **Initial Value**:
  - Initialized to `0` in the constructor.

---

## **Simulation Ports**

### `SimPort<instr_trace_t*> Input`

- **Description**: Represents the input port for receiving instruction traces.
- **Behavior**:
  - Stores incoming instructions for processing.

### `SimPort<instr_trace_t*> Output`

- **Description**: Represents the output port for sending processed instruction traces.
- **Behavior**:
  - Outputs instructions with delays based on detected bank conflicts.

---

## **Pipeline Logic**

- The `tick` method performs the following steps:
  1. Checks if the `Input` port is empty. If empty, exits the method.
  2. Retrieves the instruction at the front of the `Input` port.
  3. Analyzes the source registers of the instruction:
     - Compares register indices modulo the number of banks to detect conflicts.
     - Increments the stall counter for each detected conflict.
  4. Updates the total stall counter (`total_stalls_`) with the newly computed stalls.
  5. Pushes the instruction to the `Output` port with a delay equal to `2 + stalls`.
  6. Logs the instruction for debugging purposes.
  7. Removes the instruction from the `Input` port.
