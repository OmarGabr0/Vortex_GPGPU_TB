# ibuffer.h

## Includes

- `instr_trace.h`: Defines `instr_trace_t`.
- `<queue>`: Provides the `std::queue` container.

## Class Overview

### Namespace

```cpp
namespace vortex {
```

- Encapsulates the `IBuffer` class.

### Constructor

```cpp
IBuffer(uint32_t size) : capacity_(size) {}
```

- Initializes the buffer with a specified size.

### Public Methods

- **`empty`**: Returns `true` if the buffer is empty.
- **`full`**: Returns `true` if the buffer is full.
- **`top`**: Returns a pointer to the first element (`instr_trace_t*`).
- **`push`**: Adds a new instruction trace to the buffer.
- **`pop`**: Removes the first element from the buffer.
- **`clear`**: Clears all elements by swapping with an empty queue.

### Private Members

```cpp
std::queue<instr_trace_t*> entries_;
uint32_t capacity_;
```

- **`entries_`**: Stores the instruction traces.
- **`capacity_`**: Specifies the buffer's maximum size.
