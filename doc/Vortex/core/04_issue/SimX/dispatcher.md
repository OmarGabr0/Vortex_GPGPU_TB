# **Dispatcher.h**

## **Constructor**

### `Dispatcher(const SimContext& ctx, const Arch& arch, uint32_t buf_size, uint32_t block_size, uint32_t num_lanes)`

- **Description**: Constructs a `Dispatcher` object and initializes its simulation ports, internal queues, and configuration parameters.
- **Parameters**:
  - `ctx`: A `SimContext` object that provides the simulation context for the dispatcher.
  - `arch`: The architecture reference used to access thread and lane information.
  - `buf_size`: The size of the buffer for storing instruction traces before dispatching.
  - `block_size`: The number of instructions processed in parallel during each dispatch cycle.
  - `num_lanes`: The number of lanes used for processing instructions in parallel.
- **Behavior**:
  - Registers the `Dispatcher` object with the simulation context.
  - Initializes the `Inputs_` and `Outputs` simulation ports to handle instruction traces.
  - Configures internal queues for instruction storage.
  - Sets the buffer size, block size, and the number of lanes for dispatching operations.

---

## **Destructor**

### `virtual ~Dispatcher()`

- **Description**: Destroys the `Dispatcher` object.
- **Behavior**:
  - Performs necessary cleanup tasks, if any, to ensure proper destruction of the simulation object.

---

## **Methods**

### `void reset()`

- **Description**: Resets the internal state of the `Dispatcher` object.
- **Behavior**:
  - Resets the batch index and the start pointers for each block of instructions.
  - Clears the queues and prepares the dispatcher for a fresh simulation cycle.

---

### `void tick()`

- **Description**: Executes the core logic of the `Dispatcher` during a simulation tick.
- **Behavior**:
  - Iterates through each issue port and processes any available instructions.
  - Sends instructions to the corresponding output ports if they are ready.
  - Manages instruction traces by adjusting their thread masks based on available lanes.
  - Updates the state of batch processing by managing block dispatches and tracking the progress of dispatched instructions.
  - Increments the batch index when all blocks have been dispatched.

---

### `bool push(uint32_t issue_index, instr_trace_t* trace)`

- **Description**: Pushes an instruction trace into the appropriate queue for dispatching.
- **Parameters**:
  - `issue_index`: The issue index of the execution unit to which the trace should be dispatched.
  - `trace`: A pointer to the instruction trace to be pushed.
- **Return Value**:
  - Returns `true` if the instruction was successfully pushed to the queue, or `false` if the queue is full.

---

## **Private Members**

### `std::vector<SimPort<instr_trace_t*>> Inputs_`

- **Description**: A vector of simulation ports used to receive instruction traces for each issue unit.
- **Behavior**:
  - Stores incoming instructions that are ready for dispatch.

### `std::vector<std::queue<instr_trace_t*>> queues_`

- **Description**: A vector of queues, one for each issue unit, to hold instruction traces before they are dispatched.
- **Behavior**:
  - Each queue stores the incoming instruction traces for a specific execution unit until they can be dispatched.

### `uint32_t buf_size_`

- **Description**: The maximum size of each queue for holding instruction traces before dispatch.
- **Value**:
  - The size is specified during the construction of the `Dispatcher` object.

### `uint32_t block_size_`

- **Description**: The number of instructions processed in parallel in each dispatch cycle.
- **Value**:
  - Defines how many instructions are dispatched together as a block.

### `uint32_t num_lanes_`

- **Description**: The number of processing lanes available for dispatching instructions in parallel.
- **Value**:
  - Determines how many threads are handled in parallel during instruction dispatch.

### `uint32_t batch_count_`

- **Description**: The number of batches that can be dispatched.
- **Value**:
  - Derived from the `block_size_` and the number of available lanes.

### `uint32_t pid_count_`

- **Description**: The number of process IDs, based on the architecture’s number of threads and lanes.
- **Value**:
  - Calculated by dividing the number of threads by the number of lanes.

### `uint32_t batch_idx_`

- **Description**: The current index of the batch being dispatched.
- **Value**:
  - Keeps track of which batch is being processed.

### `std::vector<int> start_p_`

- **Description**: A vector of start pointers, one for each block, used to track the dispatch progress.
- **Behavior**:
  - The start pointer indicates the first thread in a block that will be dispatched.

---

## **Simulation Ports**

### `SimPort<instr_trace_t*> Outputs`

- **Description**: Represents the output ports for sending dispatched instruction traces.
- **Behavior**:
  - Each output port corresponds to a specific execution unit and sends instructions that have been processed.

---

## **Pipeline Logic**

The `tick` method performs the following steps:

1. Checks each queue for available instructions.
2. If an instruction is available, it is pushed to the corresponding input port for processing.
3. Processes instructions by managing the thread masks and adjusting the instruction for the available processing lanes.
4. If a batch of instructions has been dispatched, updates the batch index and resets start pointers for the next batch.
5. Dispatches the instruction to the output port with any modifications based on the available processing resources.
