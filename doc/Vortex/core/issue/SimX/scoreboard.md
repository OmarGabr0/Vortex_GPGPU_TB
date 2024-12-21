# scoreboard.h

## **Constructor**

### `Scoreboard(const Arch &arch)`

- **Description**: Initializes the scoreboard using the architecture's parameters.
- **Parameters**:
  - `arch`: An object of type `Arch` containing architecture-specific details such as the number of warps.
- **Behavior**:
  - Creates a set of register usage masks for each warp and register type.
  - Clears all initial states, preparing the scoreboard for use.

---

## **Methods**

### `void clear()`

- **Description**: Resets all tracked register usage states.
- **Behavior**:
  - Empties the `owners_` map.
  - Clears the register usage masks for all warps.

---

### `bool in_use(instr_trace_t* trace) const`

- **Description**: Checks if any register involved in the instruction is currently in use.
- **Parameters**:
  - `trace`: A pointer to an `instr_trace_t` object representing an instruction.
- **Return Value**:
  - Returns `true` if any source or destination register is already in use; otherwise, `false`.

---

### `std::vector<reg_use_t> get_uses(instr_trace_t* trace) const`

- **Description**: Retrieves details about registers currently in use by other instructions.
- **Parameters**:
  - `trace`: A pointer to an `instr_trace_t` object representing an instruction.
- **Return Value**:
  - A vector of `reg_use_t` structures, each representing a register currently in use by another instruction.
- **Behavior**:
  - Checks the destination and source registers of the instruction.
  - For each register in use, retrieves the owning instruction's functional unit type (`fu_type`), specialized functional unit type (`sfu_type`), and unique identifier (`uuid`).

---

### `void reserve(instr_trace_t* trace)`

- **Description**: Reserves the destination register of an instruction.
- **Parameters**:
  - `trace`: A pointer to an `instr_trace_t` object representing an instruction.
- **Behavior**:
  - Marks the register as in use in the `in_use_regs_` mask for the instruction's warp.
  - Records the instruction as the owner of the register in the `owners_` map.

---

### `void release(instr_trace_t* trace)`

- **Description**: Releases the destination register of an instruction.
- **Parameters**:
  - `trace`: A pointer to an `instr_trace_t` object representing an instruction.
- **Behavior**:
  - Clears the usage mark for the register in the `in_use_regs_` mask for the instruction's warp.
  - Removes the ownership entry from the `owners_` map.

---

## **Internal Data Structures**

### `struct reg_use_t`

- **Description**: Represents usage information for a specific register.
- **Fields**:
  - `reg_type`: Type of the register (e.g., general-purpose, special-purpose).
  - `reg_id`: ID of the register.
  - `fu_type`: Functional unit type utilizing the register.
  - `sfu_type`: Specialized functional unit type utilizing the register.
  - `uuid`: Unique identifier for the instruction using the register.

---

## **Private Members**

### `std::vector<std::vector<RegMask>> in_use_regs_`

- **Description**: Tracks the usage status of registers for each warp and each register type.
- **Structure**:
  - Outer vector: One entry per warp.
  - Inner vector: One `RegMask` per register type within the warp.

---

### `std::unordered_map<uint32_t, instr_trace_t*> owners_`

- **Description**: Maps registers to the instruction currently using them.
- **Structure**:
  - The key is a unique tag combining register index, warp ID, and register type.
  - The value is a pointer to the `instr_trace_t` object representing the owning instruction.

---

## **Tag Construction**

- Tags are 32-bit identifiers for each register, constructed as:

  ```cpp
  tag = (reg_idx << 16) | (wid << 4) | (int)reg_type;
  ```

  - `reg_idx`: Index of the register.
  - `wid`: Warp ID.
  - `reg_type`: Type of the register.
