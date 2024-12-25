# **decode.cpp**

## **Constructor**

### `Emulator::Emulator(const Arch& arch)`

- **Description**: Constructs an `Emulator` object and initializes its internal state.
- **Parameters**:
  - `arch`: The architecture reference used to access thread and lane information.
- **Behavior**:
  - Initializes the instruction table (`sc_instTable`) with opcode to instruction type mappings.
  - Sets up internal data structures for instruction decoding.

---

## **Destructor**

### `Emulator::~Emulator()`

- **Description**: Destroys the `Emulator` object.
- **Behavior**:
  - Performs cleanup tasks, if any.
  - Ensures proper destruction of the emulator object.

---

## **Methods**

### `std::shared_ptr<Instr> decode(uint32_t code) const`

- **Description**: Decodes a given instruction code into an `Instr` object.
- **Parameters**:
  - `code`: The instruction code to be decoded.
- **Return Value**:
  - A shared pointer to the decoded `Instr` object.
- **Behavior**:
  - Extracts various fields from the instruction code based on predefined bit widths and shifts.
  - Sets the destination register, source registers, immediate values, and function codes in the `Instr` object.
  - Handles different instruction types (`R`, `I`, `S`, `B`, `U`, `J`, `R4`) and sets the corresponding fields.
  - Logs debug information about the decoded instruction.

---

## **Private Members**

### `static const std::unordered_map<Opcode, InstType> sc_instTable`

- **Description**: Maps opcodes to their corresponding instruction types.
- **Initial Value**:
  - Initialized with opcode to instruction type mappings for various instruction types (`R`, `I`, `S`, `B`, `U`, `J`, `R4`).

---

## **Constants**

### `enum Constants`

- **Description**: Defines various constants used for instruction decoding.
- **Values**:
  - `width_opcode`: Width of the opcode field.
  - `width_reg`: Width of the register field.
  - `width_func2`: Width of the function2 field.
  - `width_func3`: Width of the function3 field.
  - `width_func7`: Width of the function7 field.
  - `width_i_imm`: Width of the immediate field for I-type instructions.
  - `width_j_imm`: Width of the immediate field for J-type instructions.
  - `shift_opcode`: Bit shift for the opcode field.
  - `shift_rd`: Bit shift for the destination register field.
  - `shift_func3`: Bit shift for the function3 field.
  - `shift_rs1`: Bit shift for the source register 1 field.
  - `shift_rs2`: Bit shift for the source register 2 field.
  - `shift_func2`: Bit shift for the function2 field.
  - `shift_func7`: Bit shift for the function7 field.
  - `mask_opcode`: Bit mask for the opcode field.
  - `mask_reg`: Bit mask for the register field.
  - `mask_func2`: Bit mask for the function2 field.
  - `mask_func3`: Bit mask for the function3 field.
  - `mask_func7`: Bit mask for the function7 field.
  - `mask_i_imm`: Bit mask for the immediate field for I-type instructions.
  - `mask_j_imm`: Bit mask for the immediate field for J-type instructions.

---

## **Pipeline Logic**

- The `decode` method performs the following steps:
  1. Extracts the opcode from the instruction code.
  2. Determines the instruction type based on the opcode using `sc_instTable`.
  3. Extracts and sets the destination register, source registers, immediate values, and function codes based on the instruction type.
  4. Handles special cases for different instruction types (`R`, `I`, `S`, `B`, `U`, `J`, `R4`).
  5. Logs the decoded instruction for debugging purposes.
