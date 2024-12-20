# Deocode stage 
## Overview 
Decoding stage responsible for interpreting the binary instruction fetched from icachee in fetch stage, It identifies the type of operation to be performed ( arithmetic, logical, memory access, control flow)

## Interfaces 
|Interface Name | Description | 
|----------------|-------------|
| [fetch_if](https://github.com/vortexgpgpu/vortex/blob/master/hw/rtl/interfaces/VX_fetch_if.sv)|slave interface, transfere data from [icache memory](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_fetch.sv#L126) in fetch stage|
|[decode_if](https://github.com/vortexgpgpu/vortex/blob/master/hw/rtl/interfaces/VX_decode_if.sv)|Master interface, transfere decoded instructions to [scoreboard](https://github.com/vortexgpgpu/vortex/blob/master/hw/rtl/core/VX_scoreboard.sv)|
|[decode_sched_if](https://github.com/vortexgpgpu/vortex/blob/master/hw/rtl/interfaces/VX_decode_sched_if.sv)|Master interface, for the [unlocking](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_schedule.sv#L191) and [timeout](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/core/VX_schedule.sv#L398) handling between the decode and schedule stages, which are essential for warp control|
### Fetch Interface - Slave Modport

| Port Name        | Width                        | Direction | Description                                                                                   |
|------------------|------------------------------|-----------|-----------------------------------------------------------------------------------------------|
| `valid`          | `1 bit`                       | Input     | Indicates that the fetch interface has valid instruction data available to be decoded.        |
| `data.uuid`      | `UUID_WIDTH bits`             | Input     | Unique identifier for the instruction, used to track and differentiate between instructions.  |
| `data.wid`       | `NW_WIDTH bits`               | Input     | Warp ID of the fetched instruction. This associates the instruction with a specific warp.     |
| `data.tmask`     | `NUM_THREADS bits`            | Input     | Thread mask indicating which threads within the warp are active and participating in the instruction fetch. |
| `data.PC`        | `PC_BITS bits`                | Input     | The program counter value of the fetched instruction, representing its memory address.         |
| `data.instr`     | `32 bits`                     | Input     | The fetched instruction itself, ready to be decoded and processed.                            |
| `ready`          | `1 bit`                       | Output    | Signals that the slave module is ready to accept the fetched instruction data.                |
| `ibuf_pop`       | `NUM_WARPS bits`             | Output    | (Optional) Indicates which instruction in the instruction buffer should be popped for further processing, used when `L1_ENABLE` is not defined. |

### Decode Interface - Master Modport
| Port Name        | Width                        | Direction | Description                                                                                   |
|------------------|------------------------------|-----------|-----------------------------------------------------------------------------------------------|
| `valid`          | `1 bit`                      | Output    | Indicates whether the `data` structure contains valid decoded instruction data.               |
| `data.uuid`      | `UUID_WIDTH bits`             | Output    | Unique identifier for the instruction, used to track and differentiate between instructions.  |
| `data.wid`       | `NW_WIDTH bits`               | Output    | Warp ID of the decoded instruction. This associates the instruction with a specific warp in the pipeline. |
| `data.tmask`     | `NUM_THREADS bits`            | Output    | Thread mask indicating which threads within the warp are active, i.e., participating in the execution. |
| `data.PC`        | `PC_BITS bits`                | Output    | The program counter value of the decoded instruction, representing its memory address.        |
| `data.ex_type`   | `EX_BITS bits`                | Output    | Execution type of the decoded instruction (e.g., ALU, memory access, etc.).                    |
| `data.op_type`   | `INST_OP_BITS bits`           | Output    | Encodes the specific operation (instruction) being executed by the GPU.                        |
| `data.op_args`   | [`op_args_t`](https://github.com/vortexgpgpu/vortex/blob/8230b37411dfe28fe1b59a25a5de4c7de276cf90/hw/rtl/VX_gpu_pkg.sv#L130)                   | Output    |Operation arguments, including excution options to the excution unit used (ALU_args, FPU_args,etc)                     |
| `data.wb`        | `1 bit`                       | Output    | Write-back flag indicating whether the instruction writes to a register.                      |
| `data.rd`        | `NR_BITS bits`                | Output    | The destination register number for the decoded instruction.                                  |
| `data.rs1`       | `NR_BITS bits`                | Output    | The first source register number for the decoded instruction.                                 |
| `data.rs2`       | `NR_BITS bits`                | Output    | The second source register number for the decoded instruction.                                |
| `data.rs3`       | `NR_BITS bits`                | Output    | The third source register number for the decoded instruction.                                 |
| `ready`          | `1 bit`                      | Input     | Signals that the receiving module or stage is ready to accept the decoded instruction data.    |
| `ibuf_pop`       | `NUM_WARPS bits`             | Input     | (Optional) Controls popping of the instruction buffer, included only if `L1_ENABLE` is not defined. |

##### Visual explaination 
![alt text](https://github.com/RISC-V-Based-Accelerators/ASU_GP25_RISC-V_NTT/blob/main/doc/RTL/Core/images/args.png)
#### Breaking down of options
##### ALU Args

| Field Name   | Description                                                                 |
|--------------|-----------------------------------------------------------------------------|
| `Use_Pc`     | A flag indicating if the Program Counter (PC) is used in the operation.     |
| `Use_imm`    | A flag indicating if an immediate value is used.                            |
| `Is_W`       | A flag indicating if the operation is a write operation.                    |
| `Xtype`      | Specifies the type of ALU operation (e.g., addition, subtraction, etc.).    |
| `imm`        | An immediate value used in the operation.                                   |

##### FPU Args

| Field Name   | Description                                                                 |
|--------------|-----------------------------------------------------------------------------|
| `__padding`  | Ensures the alignment of `frm` and `fmt`. The size is determined dynamically based on the size of `alu_args_t`. |
| `frm`        | Floating-point rounding mode field.                                         |
| `fmt`        | Floating-point format field (e.g., single, double precision).               |

##### LSU Args

| Field Name   | Description                                                                 |
|--------------|-----------------------------------------------------------------------------|
| `__padding`  | Aligns the `is_store`, `is_float`, and `offset` fields to the correct size. |
| `Is_store`   | A flag indicating if the operation is a store (write to memory).            |
| `Is_float`   | A flag indicating if the operation involves floating-point data.            |
| `Offset`     | The offset in memory for the load or store operation.                       |

##### CSR Args

| Field Name   | Description                                                                 |
|--------------|-----------------------------------------------------------------------------|
| `__padding`  | Ensures alignment for the other fields.                                     |
| `Use_imm`    | A flag indicating if an immediate value is used.                            |
| `addr`       | The address of the CSR being accessed.                                      |
| `Imm`        | An immediate value used for CSR operations (possibly for control or status updates). |

##### WCTL Args

| Field Name   | Description                                                                 |
|--------------|-----------------------------------------------------------------------------|
| `__padding`  | Ensures correct alignment of the `is_neg` field.                            |
| `Is_neg`     | A flag indicating whether the operation involves a negative result or condition. |

### Decode Schedule Interface - Master Modport

| Port Name     | Width                   | Direction | Description                                                                                   |
|---------------|-------------------------|-----------|-----------------------------------------------------------------------------------------------|
| `valid`       | `1 bit`                  | Output    | Indicates that the decode stage has valid scheduling data to be used by the schedule stage.    |
| `unlock`      | `1 bit`                  | Output    | Signals that the decode stage has unlocked a warp and it can proceed with scheduling.          |
| `wid`         | `NW_WIDTH bits`          | Output    | Warp ID that identifies the warp being scheduled, allowing the scheduler to target specific warps. |

## Instruction feild 
``` verilog
wire [31:0] instr = fetch_if.data.instr;
    wire [6:0] opcode = instr[6:0];
    wire [1:0] func2  = instr[26:25];
    wire [2:0] func3  = instr[14:12];
    wire [4:0] func5  = instr[31:27];
    wire [6:0] func7  = instr[31:25];
    wire [11:0] u_12  = instr[31:20];

    wire [4:0] rd  = instr[11:7];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rs3 = instr[31:27];
```
|  feild | Description                        | 
|--------|------------------------------------|
| opcode |  It defines the type of instruction.|
| func2  | used for distinguishing instructions with the same opcode.|
| func3  | refines the instruction type within an opcode category (e.g., ALU operation, branch condition).|
| func5 | used for additional instruction encoding or to further specify the operation type.|
|func7 |  used to distinguish between variations of instructions with the same opcode and func3.|
| u_12 | immediate or address field, used in various instruction types, such as U-type or J-type instructions.| 
|rd | represents the destination register, which is located in bits 11 to 7. |
|rs1 | first source register, located in bits 19 to 15. | 
|rs2 | is the second source register, located in bits 24 to 20. | 
|rs3 | is an additional source register, located in bits 31 to 27.| 

## Type registers 
``` verilog
 reg [`INST_ALU_BITS-1:0] r_type;  //INST_ALU_BITS =4
    always @(*) begin
        case (func3)
            3'h0: r_type = (opcode[5] && func7[5]) ? `INST_ALU_SUB : `INST_ALU_ADD; //INST_ALU_SUB         4'b0111 , INST_ALU_ADD         4'b0000
            3'h1: r_type = `INST_ALU_SLL;
            3'h2: r_type = `INST_ALU_SLT;
            3'h3: r_type = `INST_ALU_SLTU;
            3'h4: r_type = `INST_ALU_XOR;
            3'h5: r_type = func7[5] ? `INST_ALU_SRA : `INST_ALU_SRL;
            3'h6: r_type = `INST_ALU_OR;
            3'h7: r_type = `INST_ALU_AND;
        endcase
    end

    reg [`INST_BR_BITS-1:0] b_type;
    always @(*) begin
        case (func3)
            3'h0: b_type = `INST_BR_EQ;
            3'h1: b_type = `INST_BR_NE;
            3'h4: b_type = `INST_BR_LT;
            3'h5: b_type = `INST_BR_GE;
            3'h6: b_type = `INST_BR_LTU;
            3'h7: b_type = `INST_BR_GEU;
            default: b_type = 'x;
        endcase
    end

    reg [`INST_BR_BITS-1:0] s_type;
    always @(*) begin
        case (u_12)
            12'h000: s_type = `INST_OP_BITS'(`INST_BR_ECALL);
            12'h001: s_type = `INST_OP_BITS'(`INST_BR_EBREAK);
            12'h002: s_type = `INST_OP_BITS'(`INST_BR_URET);
            12'h102: s_type = `INST_OP_BITS'(`INST_BR_SRET);
            12'h302: s_type = `INST_OP_BITS'(`INST_BR_MRET);
            default: s_type = 'x;
        endcase
    end

`ifdef EXT_M_ENABLE
    reg [`INST_M_BITS-1:0] m_type;
    always @(*) begin
        case (func3)
            3'h0: m_type = `INST_M_MUL;
            3'h1: m_type = `INST_M_MULH;
            3'h2: m_type = `INST_M_MULHSU;
            3'h3: m_type = `INST_M_MULHU;
            3'h4: m_type = `INST_M_DIV;
            3'h5: m_type = `INST_M_DIVU;
            3'h6: m_type = `INST_M_REM;
            3'h7: m_type = `INST_M_REMU;
        endcase
    end
```
The `r_type` register is used to determine the ALU operation type. The func3 and func7 fields are used to select the ALU operation from a set of possible operations.

The `b_type` register determines the branch instruction type based on the func3 value.
 
The `m_type` register is used to store the type of M-extension operation (multiplication or division), the corresponding operation is selected based on func3.

The `s_type` register is used for determining system operations like ecall, ebreak, and return instructions (e.g., ureturn, sret, mret), based on u_12 

## 
``` verilog 
`ifdef EXT_F_ENABLE
    `define USED_IREG(x) \
        x``_v = {1'b0, ``x}; \
        use_``x = 1

    `define USED_FREG(x) \
        x``_v = {1'b1, ``x}; \
        use_``x = 1
`else
    `define USED_IREG(x) \
        x``_v = ``x; \
        use_``x = 1
`endif
```

This macros simplify the process of handling different types of registers (integer vs. floating-point)

## decoding based on opcode 
first multiblixur 
```verilog 
case (opcode)
```
![alt text](https://github.com/RISC-V-Based-Accelerators/ASU_GP25_RISC-V_NTT/blob/main/doc/RTL/Core/images/flowchart.png)

###  I-Type
``` verilog 
`INST_I: begin                           // INST_I = 7'b0010011 immediate instructions 
                ex_type = `EX_ALU;                   // EX_ALU =  0
                op_type = `INST_OP_BITS'(r_type);    // 
                op_args.alu.xtype = `ALU_TYPE_ARITH;
                op_args.alu.is_w = 0;                 // not write operation 
                op_args.alu.use_PC = 0;               // pc is not used in this operation 
                op_args.alu.use_imm = 1;              // using immediate field 
                op_args.alu.imm = `SEXT(`IMM_BITS, i_imm); //sign  extention for immediated bit

                use_rd = 1;                         // flag to sude distenation reg 
                `USED_IREG (rd);                   
                `USED_IREG (rs1);
```
#### alu_args options
| **Field**          | **Value/Description**                     |
|---------------------|-------------------------------------------|
| **Ex_type**         | `ALU`                                    |
| **Op_type**         | `r_type`                                 |
| **Is_w**            | `0` (Not a write operation)              |
| **Use_pc**          | `0` (Program Counter not used)           |
| **Use_imm**         | `1` (Uses the immediate field)           |
| **Imm**             | Sign-extended value of `i_imm`           |
| **Use_rd**          | `1` (Uses destination register `rd`)     |
| **x_type**          | `ALU_TYPE_ARITH`                         |

#### instruction formate 
| Field         | Bits       | Description                                      |
|---------------|------------|--------------------------------------------------|
| `opcode`      | [6:0]      | Specifies the type of instruction.               |
| `rd`          | [11:7]     | Destination register address.                    |
| `funct3`      | [14:12]    | Specifies the operation category.                |
| `rs1`         | [19:15]    | Source register 1 address.                       |
| `imm`         | [31:20]    | Immediate value, sign-extended to 32 bits.       |
### I-type (JALR)
``` verilog 
`INST_JALR: begin
    ex_type = `EX_ALU;
    op_type = `INST_OP_BITS'(`INST_BR_JALR);
    op_args.alu.xtype = `ALU_TYPE_BRANCH;
    op_args.alu.is_w = 0;
    op_args.alu.use_PC = 0;
    op_args.alu.use_imm = 1;
    op_args.alu.imm = `SEXT(`IMM_BITS, u_12);
    use_rd  = 1;
    is_wstall = 1;
    `USED_IREG (rd);
    `USED_IREG (rs1);
end
```
#### Instruction Format

| Field        | Bit Range    | Description                                         |
|--------------|--------------|-----------------------------------------------------|
| `u_12`       | [11:0]       | Immediate value used to calculate the jump offset   |
| `rs1`        | [19:15]      | Source register 1                                  |
| `rd`         | [11:7]       | Destination register                                |
| `opcode`     | [6:0]        | Opcode indicating the JALR instruction              |

#### alu_args Options

| **Field**          | **Value/Description**                                      |
|--------------------|------------------------------------------------------------|
| **Ex_type**        | `ALU` (Execution type for ALU operations)                  |
| **Op_type**        | `INST_BR_JALR` (JALR operation)                            |
| **Is_w**           | `0` (Not a write operation)                                |
| **Use_pc**         | `0` (Program Counter is not used in this operation)        |
| **Use_imm**        | `1` (Uses the immediate field)                             |
| **Imm**            | Sign-extended value of `u_12`                              |
| **Use_rd**         | `1` (Destination register `rd` is used)                    |
| **x_type**         | `ALU_TYPE_BRANCH` (Branch type operation)                  |

#### Opcode Details

| Instruction | `func3`   | `func7`    | `op_type`      | Description                           |
|-------------|-----------|------------|----------------|---------------------------------------|
| JALR        | `000`     | `0000000`  | `INST_BR_JALR` | Jump and Link Register: `rd = PC + 4`, jump to `rs1 + imm` |

The `JALR` instruction performs a jump to the address `rs1 + imm` and stores the return address (`PC + 4`) in the destination register `rd`. The immediate value `u_12` is sign-extended before being added to `rs1` to calculate the jump address.


### R_type  
```verilog 
`INST_R: begin
            ex_type = `EX_ALU;            
            op_args.alu.is_w = 0;    
            op_args.alu.use_PC = 0;
            op_args.alu.use_imm = 0;
            use_rd = 1;
            `USED_IREG (rd);
            `USED_IREG (rs1);
            `USED_IREG (rs2);
            case (func7)
            `ifdef EXT_M_ENABLE
                `INST_R_F7_MUL: begin
                    // MUL, MULH, MULHSU, MULHU
                    op_type = `INST_OP_BITS'(m_type);
                    op_args.alu.xtype = `ALU_TYPE_MULDIV;
                end
            `endif
            `ifdef EXT_ZICOND_ENABLE
                `INST_R_F7_ZICOND: begin
                    // CZERO-EQZ, CZERO-NEZ
                    op_type = func3[1] ? `INST_OP_BITS'(`INST_ALU_CZNE) : `INST_OP_BITS'(`INST_ALU_CZEQ);
                    op_args.alu.xtype = `ALU_TYPE_ARITH;
                end
            `endif
                default: begin
                    op_type = `INST_OP_BITS'(r_type);
                    op_args.alu.xtype = `ALU_TYPE_ARITH;
                end
            endcase
```
#### alu_args Options

| **Field**          | **Value/Description**                         |
|--------------------|-----------------------------------------------|
| **Ex_type**        | `ALU` (Execution type for ALU operations)     |
| **Op_type**        | `r_type` (R-type instruction format)          |
| **Is_w**           | `0` (Not a write operation)                   |
| **Use_pc**         | `0` (Program Counter is not used in this operation) |
| **Use_imm**        | `0` don't use immediate field |
| **Use_rd**         | `1` (Destination register `rd` is used)      |
| **x_type**         | `ALU_TYPE_ARITH` (Arithmetic type operation) for traditional R types and M extension  `ALU_TYPE_MULDIV` (Arithmetic multiblication devision unit) |


#### instruction formate 
| Field     | Bit Range        | Description                                    |
|-----------|------------------|------------------------------------------------|
| `imm[11:0]` | [31:20]          | 12-bit Immediate value (signed)              |
| `rs1`      | [19:15]          | Source register 1                             |
| `funct3`   | [14:12]          | Function code (for specific operation)        |
| `rd`       | [11:7]           | Destination register                          |
| `opcode`   | [6:0]            | Opcode indicating the type of operation       |

opcode extensions are seen here in this part,

| func7                       | op_type                     | 
|-----------------------------|-----------------------------|
|INST_R_F7_MUL  =  7'b0000001 | M Extension                 | 
|INST_R_F7_ZICOND  =  7'b0000111 | Z Extension              |
| non of them                | R-type                       | 

based on these extension the decoder would determine wich op_type option would be assigned to 
m_type for mul type, `INST_ALU_CZNE ` or   `INST_ALU_CZEQ ` for  Zicond based on func3 value , or traditional r_type if non of extension

##### RISC-V M Extension Instructions

| Instruction | Description                            | `func3` | `func7`   |                | 
|-------------|----------------------------------------|---------|-----------|----------------| 
| `MUL`       | Multiply                               | `000`   | `0000001` |rd=(rs1*rs2)[31:0]|
| `MULH`      | Multiply high (signed)                | `001`   | `0000001` |rd=(rs1*rs2)[63:32]|
| `MULHSU`    | Multiply high (signed × unsigned)     | `010`   | `0000001` |rd=(rs1*rs2)[63:32]|
| `MULHU`     | Multiply high (unsigned)              | `011`   | `0000001` |rd=(rs1*rs2)[63:32]|
| `DIV`       | Divide (signed)                       | `100`   | `0000001` |rd=rs1/rs2|
| `DIVU`      | Divide (unsigned)                     | `101`   | `0000001` |rd=rs1/rs2|
| `REM`       | Remainder (signed)                    | `110`   | `0000001` |rd=rs1%rs2|
| `REMU`      | Remainder (unsigned)                  | `111`   | `0000001` |rd=rs1%rs2|

##### RISC-V Zicond Extension Instructions

- **CZERO.EQZ** : This instruction sets the target register to zero if the source register is zero.

- **CZERO.NEZ** : This sets the target register to zero if the source register is not zero.

| Instruction    | Description                             | `func3` | `func7`   | Operation                |
|----------------|-----------------------------------------|---------|-----------|--------------------------|
| `CZERO-EQZ`    | Compare Zero for Equal                  | `01`    | `0000000` | rd = (rs1 == 0) ? 1 : 0   |
| `CZERO-NEZ`    | Compare Zero for Not Equal              | `00`    | `0000000` | rd = (rs1 != 0) ? 1 : 0   |


### U-type (LUI)
``` verilog 
`INST_LUI: begin
    ex_type = `EX_ALU;
    op_type = `INST_OP_BITS'(`INST_ALU_LUI);
    op_args.alu.xtype = `ALU_TYPE_ARITH;
    op_args.alu.is_w = 0;
    op_args.alu.use_PC = 0;
    op_args.alu.use_imm = 1;
    op_args.alu.imm = {{`IMM_BITS-31{ui_imm[19]}}, ui_imm[18:0], 12'(0)};
    use_rd  = 1;
    `USED_IREG (rd);
end
```
#### Instruction Format

| Field        | Bit Range    | Description                                         |
|--------------|--------------|-----------------------------------------------------|
| `ui_imm`     | [31:12]      | Upper immediate value (sign-extended to 32-bits)    |
| `rd`         | [11:7]       | Destination register                                |
| `opcode`     | [6:0]        | Opcode indicating the LUI instruction               |

#### alu_args Options

| **Field**          | **Value/Description**                                      |
|--------------------|------------------------------------------------------------|
| **Ex_type**        | `ALU` (Execution type for ALU operations)                  |
| **Op_type**        | `INST_ALU_LUI` (LUI operation)                             |
| **Is_w**           | `0` (Not a write operation)                                |
| **Use_pc**         | `0` (Program Counter is not used in this operation)        |
| **Use_imm**        | `1` (Uses the immediate field)                             |
| **Imm**            | Concatenation of the immediate value (`ui_imm[18:0]`) and zeroed upper 12 bits |
| **Use_rd**         | `1` (Destination register `rd` is used)                    |
| **x_type**         | `ALU_TYPE_ARITH` (Arithmetic type operation)               |

#### Opcode Details

|instruction | `func3`   | `func7`    | `op_type`      | Description                    |
|-----|-----------|------------|----------------|--------------------------------|
|lui  | `000`     | `0000000`  | `INST_ALU_LUI` | Load Upper Immediate (LUI) rd=imm<<12     |

The LUI instruction is used to load a 20-bit immediate value into the upper 20 bits of a register (`rd`). The immediate value is zero-extended for the lower 12 bits.

### U-type ( auipc)
``` verilog 
`INST_AUIPC: begin
                ex_type = `EX_ALU;
                op_type = `INST_OP_BITS'(`INST_ALU_AUIPC);
                op_args.alu.xtype = `ALU_TYPE_ARITH;
                op_args.alu.is_w = 0;
                op_args.alu.use_PC = 1;
                op_args.alu.use_imm = 1;
                op_args.alu.imm = {{`IMM_BITS-31{ui_imm[19]}}, ui_imm[18:0], 12'(0)};
                use_rd = 1;
                `USED_IREG (rd);
            end
```
#### Instruction Format

| Field        | Bit Range    | Description                                         |
|--------------|--------------|-----------------------------------------------------|
| `ui_imm`     | [31:12]      | Upper immediate value (sign-extended to 32-bits)    |
| `rd`         | [11:7]       | Destination register                                |
| `opcode`     | [6:0]        | Opcode indicating the AUIPC instruction             |

#### alu_args Options

| **Field**          | **Value/Description**                                      |
|--------------------|------------------------------------------------------------|
| **Ex_type**        | `ALU` (Execution type for ALU operations)                  |
| **Op_type**        | `INST_ALU_AUIPC` (AUIPC operation)                         |
| **Is_w**           | `0` (Not a write operation)                                |
| **Use_pc**         | `1` (Program Counter is used in this operation)            |
| **Use_imm**        | `1` (Uses the immediate field)                             |
| **Imm**            | Concatenation of the immediate value (`ui_imm[18:0]`) and zeroed upper 12 bits |
| **Use_rd**         | `1` (Destination register `rd` is used)                    |
| **x_type**         | `ALU_TYPE_ARITH` (Arithmetic type operation)               |

#### Opcode Details

| Instruction | `func3`   | `func7`    | `op_type`      | Description                           |
|-------------|-----------|------------|----------------|---------------------------------------|
| AUIPC       | `001`     | `0000000`  | `INST_ALU_AUIPC` | Add Upper Immediate to PC: `rd = PC + (imm << 12)` |

The `AUIPC` instruction adds an upper immediate to the current value of the program counter (`PC`). The 20-bit immediate value is sign-extended to 32-bits, shifted left by 12 bits, and added to the current PC. The result is written into the destination register `rd`.

### J-type
``` verilog 
`INST_JAL: begin
            ex_type = `EX_ALU;
            op_type = `INST_OP_BITS'(`INST_BR_JAL);
            op_args.alu.xtype = `ALU_TYPE_BRANCH;
            op_args.alu.is_w = 0;
            op_args.alu.use_PC = 1;
            op_args.alu.use_imm = 1;
            op_args.alu.imm = `SEXT(`IMM_BITS, jal_imm);
            use_rd  = 1;
            is_wstall = 1;
            `USED_IREG (rd);
end
```
#### Instruction Format

| Field        | Bit Range    | Description                                         |
|--------------|--------------|-----------------------------------------------------|
| `jal_imm`    | [20:1]       | Immediate value used to calculate the jump offset   |
| `rd`         | [11:7]       | Destination register                                |
| `opcode`     | [6:0]        | Opcode indicating the JAL instruction               |

#### alu_args Options

| **Field**          | **Value/Description**                                      |
|--------------------|------------------------------------------------------------|
| **Ex_type**        | `ALU` (Execution type for ALU operations)                  |
| **Op_type**        | `INST_BR_JAL` (JAL operation)                              |
| **Is_w**           | `0` (Not a write operation)                                |
| **Use_pc**         | `1` (Program Counter is used in this operation)            |
| **Use_imm**        | `1` (Uses the immediate field)                             |
| **Imm**            | Sign-extended value of `jal_imm`                           |
| **Use_rd**         | `1` (Destination register `rd` is used)                    |
| **x_type**         | `ALU_TYPE_BRANCH` (Branch type operation)                  |

#### Opcode Details

| Instruction | `func3`   | `func7`    | `op_type`      | Description                           |
|-------------|-----------|------------|----------------|---------------------------------------|
| JAL         | `110`     | `0000000`  | `INST_BR_JAL`  | Jump and Link: `rd = PC + 4`, jump to `PC + imm` |

The `JAL` instruction performs an unconditional jump to the address `PC + imm`. It stores the return address (the next instruction address, `PC + 4`) in the destination register `rd`. The jump address is computed by sign-extending `jal_imm` and adding it to the current `PC`.

### B-type 
``` verilog 
`INST_B: begin  // branch instructions
        ex_type = `EX_ALU;
        op_type = `INST_OP_BITS'(b_type);
        op_args.alu.xtype = `ALU_TYPE_BRANCH;
        op_args.alu.is_w = 0;
        op_args.alu.use_PC = 1;
        op_args.alu.use_imm = 1;
        op_args.alu.imm = `SEXT(`IMM_BITS, b_imm);
        is_wstall = 1;
        `USED_IREG (rs1);
        `USED_IREG (rs2);
    end
```
#### Instruction Format

| Field        | Bit Range    | Description                                         |
|--------------|--------------|-----------------------------------------------------|
| `b_imm`      | [12:1]       | Immediate value for branch offset (sign-extended)   |
| `rs1`        | [19:15]      | Source register 1                                  |
| `rs2`        | [24:20]      | Source register 2                                  |
| `opcode`     | [6:0]        | Opcode indicating the Branch instruction            |

#### alu_args Options

| **Field**          | **Value/Description**                                      |
|--------------------|------------------------------------------------------------|
| **Ex_type**        | `ALU` (Execution type for ALU operations)                  |
| **Op_type**        | `b_type` (Branch type operation)  specify which B-type instruction would be excuted based on func3                         |
| **Is_w**           | `0` (Not a write operation)                                |
| **Use_pc**         | `1` (Program Counter is used to compute branch target)     |
| **Use_imm**        | `1` (Uses the immediate field)                             |
| **Imm**            | Sign-extended value of `b_imm`                             |
| **Use_rd**         | `0` (No destination register used, as it's a branch)       |
| **x_type**         | `ALU_TYPE_BRANCH` (Branch type operation)                  |



The `B` instruction type is used for branching operations. It computes the target address based on the immediate value (`b_imm`) and the program counter, and then decides whether to branch or not based on the condition encoded in the instruction.
### Fence operation 
```verilog
 `INST_FENCE: begin /////////////////////////////////////////////////
                ex_type = `EX_LSU;
                op_type = `INST_LSU_FENCE;
                op_args.lsu.is_store = 0;
                op_args.lsu.is_float = 0;
                op_args.lsu.offset = 0;
            end
```
#### Instruction Format

| Field        | Bit Range    | Description                                     |
|--------------|--------------|-------------------------------------------------|
| `pred`       | [27:24]      | Predecessor memory access ordering              |
| `succ`       | [23:20]      | Successor memory access ordering                |
| `rs1`        | [19:15]      | Reserved (typically unused in `FENCE`)          |
| `rd`         | [11:7]       | Reserved (typically unused in `FENCE`)          |
| `opcode`     | [6:0]        | Opcode indicating the FENCE instruction         |

#### lsu_args Options

| **Field**          | **Value/Description**                                     |
|--------------------|-----------------------------------------------------------|
| **Ex_type**        | `LSU` (Load/Store Unit operation)                         |
| **Op_type**        | `INST_LSU_FENCE` (Fence operation for memory ordering)    |
| **Is_store**       | `0` (Not a store operation)                               |
| **Is_float**       | `0` (Not a floating-point operation)                      |
| **Offset**         | `0` (No offset required for FENCE operation)              |

The `FENCE` instruction is used to ensure memory ordering between loads, stores, and other operations. It enforces memory consistency by guaranteeing that prior memory operations are completed before subsequent ones, based on the `pred` and `succ` fields.

### System instruction 
```verilog
`INST_SYS : begin ////////////////////
                if (func3[1:0] != 0) begin
                    ex_type = `EX_SFU;
                    op_type = `INST_OP_BITS'(`INST_SFU_CSR(func3[1:0])); // (4'h6 + 4'(f3[1:0]) - 4'h1)
                    op_args.csr.addr = u_12;
                    op_args.csr.use_imm = func3[2];
                    use_rd  = 1;
                    is_wstall = is_fpu_csr; // only stall for FPU CSRs
                    `USED_IREG (rd);
                    if (func3[2]) begin
                        op_args.csr.imm = rs1;
                    end else begin
                        `USED_IREG (rs1);
                    end
                end else begin
                    ex_type = `EX_ALU;
                    op_type = `INST_OP_BITS'(s_type);
                    op_args.alu.xtype = `ALU_TYPE_BRANCH;
                    op_args.alu.is_w = 0;
                    op_args.alu.use_imm = 1;
                    op_args.alu.use_PC  = 1;
                    op_args.alu.imm = `IMM_BITS'd4;
                    use_rd  = 1;
                    is_wstall = 1;
                    `USED_IREG (rd);
                end
            end
```

#### Instruction Format

| Field        | Bit Range    | Description                                         |
|--------------|--------------|-----------------------------------------------------|
| `u_12`       | [31:20]      | 12-bit unsigned immediate value                     |
| `rs1`        | [19:15]      | Source register 1                                   |
| `rd`         | [11:7]       | Destination register                                |
| `func3`      | [14:12]      | Function code defining the type of system operation|
| `opcode`     | [6:0]        | Opcode indicating the SYSTEM instruction            |

#### CSR Operation (`func3[1:0] != 0`)

##### CSR Operation Details

| **Field**          | **Value/Description**                                     |
|--------------------|-----------------------------------------------------------|
| **Ex_type**        | `SFU` (Special Function Unit for CSR operations)          |
| **Op_type**        | `INST_SFU_CSR(func3[1:0])` (CSR instruction type)         |
| **Csr_addr**       | `u_12` (CSR address)                                      |
| **Use_imm**        | `func3[2]` (Determines if immediate or register is used)  |
| **Imm**            | `rs1` if `func3[2] == 1`                                  |
| **Use_rd**         | `1` (Destination register `rd` is used)                   |
| **Is_wstall**      | `1` for FPU CSR (stall on floating-point CSR operations)  |

#### ALU Operation (`func3[1:0] == 0`)

##### ALU Operation Details

| **Field**          | **Value/Description**                                     |
|--------------------|-----------------------------------------------------------|
| **Ex_type**        | `ALU` (Arithmetic Logic Unit operation)                   |
| **Op_type**        | `s_type` (System ALU operation type)                      |
| **Alu_xtype**      | `ALU_TYPE_BRANCH` (Branch operation type)                 |
| **Alu_is_w**       | `0` (Not a write operation)                               |
| **Alu_use_PC**     | `1` (Program Counter is used in the operation)            |
| **Alu_use_imm**    | `1` (Immediate value is used in the operation)            |
| **Alu_imm**        | 4 (Immediate value for the operation)                     |
| **Use_rd**         | `1` (Destination register `rd` is used)                   |
| **Is_wstall**      | `1` (Pipeline stall for system instructions)              |

#### CSR Opcode Details

| Instruction  | `func3`   |  `op_type`            | Description                        |
|--------------|-----------|----------------------|------------------------------------|
| `CSRRW`      | `001`     |  `INST_SFU_CSR(1)`    | Write to CSR with `rs1` value      |
| `CSRRS`      | `010`     | `INST_SFU_CSR(2)`    | Set bits in CSR using `rs1` value  |
| `CSRRC`      | `011`     |  `INST_SFU_CSR(3)`    | Clear bits in CSR using `rs1` value|
| `CSRRWI`     | `101`     |  `INST_SFU_CSR(5)`    | Write immediate value to CSR       |
| `CSRRSI`     | `110`     |  `INST_SFU_CSR(6)`    | Set bits in CSR using immediate    |
| `CSRRCI`     | `111`     |  `INST_SFU_CSR(7)`    | Clear bits in CSR using immediate  |


The `INST_SYS` instruction handles system operations such as environment calls, breakpoints, and CSR (Control and Status Register) manipulations. Depending on the `func3` field, the operation type is determined as either a CSR operation (`SFU`) or an ALU operation for system management.

## I-type (Load instructions) 
``` verilog
    `ifdef EXT_F_ENABLE
            `INST_FL, //7'b0000111          // same branch used for floating point extension 
        `endif
            `INST_L: begin  // 7'b0000011   //load instruction 
                ex_type = `EX_LSU;
                op_type = `INST_OP_BITS'({1'b0, func3});
                op_args.lsu.is_store = 0;
                op_args.lsu.is_float = opcode[2];
                op_args.lsu.offset = u_12;
                use_rd  = 1;
            `ifdef EXT_F_ENABLE
                if (opcode[2]) begin
                    `USED_FREG (rd);
                end else
            `endif
                `USED_IREG (rd);
                `USED_IREG (rs1);
            end
```
#### Instruction Format

| Field        | Bit Range    | Description                                         |
|--------------|--------------|-----------------------------------------------------|
| `u_12`       | [31:20]      | 12-bit unsigned immediate value                     |
| `rs1`        | [19:15]      | Source register 1                                   |
| `rd`         | [11:7]       | Destination register                                |
| `func3`      | [14:12]      | Function code defining the type of load operation  |
| `opcode`     | [6:0]        | Opcode indicating the LOAD instruction             |

#### LSU Arguments

| **Field**          | **Value/Description**                                     |
|--------------------|-----------------------------------------------------------|
| **Ex_type**        | `LSU` (Load/Store Unit operation)                         |
| **Op_type**        | `{1'b0, func3}` (Type of load operation determined by `func3`) |
| **Is_store**       | `0` (Load operation, not store)                           |
| **Is_float**       | `opcode[2]` (Determines if the operation is floating-point) |
| **Offset**         | `u_12` (Immediate offset value for memory access)         |
| **Use_rd**         | `1` (Destination register `rd` is used)                   |

#### Floating-Point Enable (EXT_F_ENABLE)

When the floating-point extension is enabled:
- If `opcode[2]` is set, the destination register `rd` is treated as a floating-point register (`FREG`).
- Otherwise, it defaults to an integer register (`IREG`).

#### Opcode Details

| Instruction  | `func3`   | `op_type`            | Description                               |
|--------------|-----------|---------------------|-------------------------------------------|
| `LB`         | `000`     | `{1'b0, 3'b000}`     | Load byte                                |
| `LH`         | `001`     | `{1'b0, 3'b001}`     | Load halfword                            |
| `LW`         | `010`      | `{1'b0, 3'b010}`     | Load word                                |
| `LBU`        | `100`      | `{1'b0, 3'b100}`     | Load byte unsigned                       |
| `LHU`        | `101`       | `{1'b0, 3'b101}`     | Load halfword unsigned                   |
| `FLD`*       | `011`       | `{1'b0, 3'b011}`     | Load double-precision floating-point     |

#### Notes
- The `EXT_F_ENABLE` block adds support for floating-point load operations (`FLD`).
- Integer loads (`LB`, `LH`, `LW`, etc.) and floating-point loads (`FLD`) share the same opcode (`0000011`), distinguished by `func3` and `opcode[2]`.

This section defines the functionality and decoding for the `LOAD` instruction, incorporating support for the floating-point extension when enabled.
## I-type (store instructions)
``` verilog
`ifdef
 EXT_F_ENABLE
            `INST_FS,   //  7'b0100111 
        `endif
            `INST_S: begin // 7'b0100011   //// store instructions
                ex_type = `EX_LSU;
                op_type = `INST_OP_BITS'({1'b1, func3});
                op_args.lsu.is_store = 1;
                op_args.lsu.is_float = opcode[2];
                op_args.lsu.offset = s_imm;  
                `USED_IREG (rs1);
            `ifdef EXT_F_ENABLE     //M[rs1+imm][0:7]=rs2[0:7]
                if (opcode[2]) begin
                    `USED_FREG (rs2);
                end else
            `endif
                `USED_IREG (rs2);
            end

```
#### Instruction Format

| Field        | Bit Range    | Description                                           |
|--------------|--------------|-------------------------------------------------------|
| `s_imm`      | [31:25, 11:7]| 12-bit immediate value split into two parts          |
| `rs2`        | [24:20]      | Source register 2 (data to be stored)                |
| `rs1`        | [19:15]      | Source register 1 (base address for memory access)   |
| `func3`      | [14:12]      | Function code defining the type of store operation   |
| `opcode`     | [6:0]        | Opcode indicating the STORE instruction              |

#### LSU Arguments

| **Field**          | **Value/Description**                                     |
|--------------------|-----------------------------------------------------------|
| **Ex_type**        | `LSU` (Load/Store Unit operation)                         |
| **Op_type**        | `{1'b1, func3}` (Type of store operation determined by `func3`) |
| **Is_store**       | `1` (Store operation)                                     |
| **Is_float**       | `opcode[2]` (Determines if the operation is floating-point) |
| **Offset**         | `s_imm` (Immediate offset value for memory access)        |

#### Floating-Point Enable (EXT_F_ENABLE)

When the floating-point extension is enabled:
- If `opcode[2]` is set, the source register `rs2` is treated as a floating-point register (`FREG`).
- Otherwise, it defaults to an integer register (`IREG`).

#### Opcode Details

| Instruction  | `func3`   | `op_type`            | Description                               |
|--------------|-----------|----------------------|-------------------------------------------|
| `SB`         | `000`      `{1'b1, 3'b000}`     | Store byte                               |
| `SH`         | `001`     | `{1'b1, 3'b001}`     | Store halfword                           |
| `SW`         | `010`      | `{1'b1, 3'b010}`     | Store word                               |
| `FSD`*       | `011`      | `{1'b1, 3'b011}`     | Store double-precision floating-point    |

#### Notes
- The `EXT_F_ENABLE` block adds support for floating-point store operations (`FSD`).
- Integer stores (`SB`, `SH`, `SW`) and floating-point stores (`FSD`) share the same opcode (`0100011`), distinguished by `func3` and `opcode[2]`.

This section defines the functionality and decoding for the `STORE` instruction, incorporating support for the floating-point extension when enabled.

## Floating piont extension 
``` verilog
`ifdef EXT_F_ENABLE
    `INST_FMADD,  // 7'b100_00_11 //rd=rs1*rs2+rs3
    `INST_FMSUB,  // 7'b100_01_11 // rd=rs1*rs2-rs3
    `INST_FNMSUB, // 7'b100_10_11 // rd=-rs1*rs2-rs3
    `INST_FNMADD: // 7'b100_11_11 // rd=-rs1*rs2+rs3
    begin
        ex_type = `EX_FPU;
        op_type = `INST_OP_BITS'({2'b00, 1'b1, opcode[3]}); // 4'b001_0 or 1 for negative op
        op_args.fpu.frm = func3;
        op_args.fpu.fmt[0] = func2[0]; // float / double   
        op_args.fpu.fmt[1] = opcode[3] ^ opcode[2]; // SUB  // fmt=op[3]^[2]_func2[0]
        use_rd  = 1;
        `USED_FREG (rd);
        `USED_FREG (rs1);
        `USED_FREG (rs2);
        `USED_FREG (rs3);
    end
    `INST_FCI: begin //7'b1010011 float common instructions
        ex_type = `EX_FPU;
        op_args.fpu.frm = func3;
        op_args.fpu.fmt[0] = func2[0]; // float / double
        op_args.fpu.fmt[1] = rs2[1];   // int32 / int64
        use_rd  = 1;
        case (func5)
            5'b00000, // FADD
            5'b00001, // FSUB
            5'b00010: // FMUL
            begin
                op_type = `INST_OP_BITS'({2'b00, 1'b0, func5[1]});
                op_args.fpu.fmt[1] = func5[0]; // SUB
                `USED_FREG (rd);
                `USED_FREG (rs1);
                `USED_FREG (rs2);
            end
            5'b00100: begin
                // NCP: FSGNJ=0, FSGNJN=1, FSGNJX=2
                op_type = `INST_OP_BITS'(`INST_FPU_MISC);  //frm: SGNJ=0, SGNJN=1, SGNJX=2, CLASS=3, MVXW=4, MVWX=5,
                op_args.fpu.frm = `INST_FRM_BITS'(func3[1:0]);
                `USED_FREG (rd);
                `USED_FREG (rs1);
                `USED_FREG (rs2);
            end
            5'b00101: begin
                // NCP: FMIN=6, FMAX=7
                op_type = `INST_OP_BITS'(`INST_FPU_MISC); // 4'b1110 // frm:  FMIN=6, FMAX=7
`define INST_FPU_BITS        4
                op_args.fpu.frm = `INST_FRM_BITS'(func3[0] ? 7 : 6);
                `USED_FREG (rd);
                `USED_FREG (rs1);
                `USED_FREG (rs2);
            end
        `ifdef FLEN_64
            5'b01000: begin
                // FCVT.S.D, FCVT.D.S
                op_type = `INST_OP_BITS'(`INST_FPU_F2F);//4'b1101 // fmt[0]: F32=0, F64=1 // rd=(float)rs1
                `USED_FREG (rd);                     // fmt already assigned up
                `USED_FREG (rs1);
            end
        `endif
            5'b00011: begin
                // FDIV
                op_type = `INST_OP_BITS'(`INST_FPU_DIV); //rd=rs1/rs2
                `USED_FREG (rd);
                `USED_FREG (rs1);
                `USED_FREG (rs2);
            end
            5'b01011: begin
                // FSQRT
                op_type = `INST_OP_BITS'(`INST_FPU_SQRT);  //rd=sqrt(rs1)
                `USED_FREG (rd);
                `USED_FREG (rs1);
            end
            5'b10100: begin
                // FCMP
                op_type = `INST_OP_BITS'(`INST_FPU_CMP);   // frm: LE=0, LT=1, EQ=2
                `USED_IREG (rd);
                `USED_FREG (rs1);
                `USED_FREG (rs2);
            end
            5'b11000: begin
                // FCVT.W.X, FCVT.WU.X
                op_type = (rs2[0]) ? `INST_OP_BITS'(`INST_FPU_F2U) : `INST_OP_BITS'(`INST_FPU_F2I);
                `USED_IREG (rd);
                `USED_FREG (rs1);
            end
            5'b11010: begin
                // FCVT.X.W, FCVT.X.WU  //MoveFloattoInt , //   
                //// fmt[0]: F32=0, F64=1, fmt[1]: I32=0, I64=1       // fmt[0]: F32=0, F64=1, fmt[1]: I32=0, I64=1
                op_type = (rs2[0]) ? `INST_OP_BITS'(`INST_FPU_U2F) : `INST_OP_BITS'(`INST_FPU_I2F);
                `USED_FREG (rd);
                `USED_IREG (rs1);
            end
            5'b11100: begin
                if (func3[0]) begin
                    // NCP: FCLASS=3
                    op_type = `INST_OP_BITS'(`INST_FPU_MISC);
                    op_args.fpu.frm = `INST_FRM_BITS'(3);
                end else begin
                    // NCP: FMV.X.W=4
                    op_type = `INST_OP_BITS'(`INST_FPU_MISC);
                    op_args.fpu.frm = `INST_FRM_BITS'(4);
                end
                `USED_IREG (rd);
                `USED_FREG (rs1);
            end
            5'b11110: begin
                // NCP: FMV.W.X=5
                op_type = `INST_OP_BITS'(`INST_FPU_MISC);
                op_args.fpu.frm = `INST_FRM_BITS'(5);
                `USED_FREG (rd);
                `USED_IREG (rs1);
            end
        default:;
        endcase
    end
`endif
```
### Floating-Point Instructions (`EXT_F_ENABLE`)

#### Instruction Format

| Field        | Bit Range    | Description                                    |
|--------------|--------------|------------------------------------------------|
| `rs3`        | [31:27]      | Source register 3 (used in FMA operations)     |
| `func2`      | [26:25]      | Precision/Format selector (single/double)      |
| `rs2`        | [24:20]      | Source register 2                              |
| `rs1`        | [19:15]      | Source register 1                              |
| `func5`      | [14:10]      | Function code defining the FPU operation       |
| `func3`      | [9:7]        | Rounding mode or auxiliary modifier            |
| `rd`         | [11:7]       | Destination register                           |
| `opcode`     | [6:0]        | Opcode for floating-point operations           |

---

#### FPU Arguments

| **Field**         | **Value/Description**                                      |
|-------------------|------------------------------------------------------------|
| **Ex_type**       | `FPU` (Floating-Point Unit operation)                      |
| **Op_type**       | Defined by `func5`, `func3`, and `opcode`                  |
| **Frm**           | `func3` (Rounding mode or operation-specific flags)        |
| **Fmt[0]**        | `func2[0]` (Floating-point precision: single/double)       |
| **Fmt[1]**        | Dependent on operation (`rs2[1]`, `opcode[3] ^ opcode[2]`) |

---

#### Opcode Details

| Instruction       | `opcode`     | `func5`   | Operation Description                      |
|-------------------|--------------|-----------|--------------------------------------------|
| `FMADD`           | `100_00_11`  | -         | `rd = rs1 * rs2 + rs3`                     |
| `FMSUB`           | `100_01_11`  | -         | `rd = rs1 * rs2 - rs3`                     |
| `FNMSUB`          | `100_10_11`  | -         | `rd = -rs1 * rs2 - rs3`                    |
| `FNMADD`          | `100_11_11`  | -         | `rd = -rs1 * rs2 + rs3`                    |
| `FADD`            | `1010011`    | `00000`   | `rd = rs1 + rs2`                           |
| `FSUB`            | `1010011`    | `00001`   | `rd = rs1 - rs2`                           |
| `FMUL`            | `1010011`    | `00010`   | `rd = rs1 * rs2`                           |
| `FDIV`            | `1010011`    | `00011`   | `rd = rs1 / rs2`                           |
| `FSQRT`           | `1010011`    | `01011`   | `rd = sqrt(rs1)`                           |
| `FCMP`            | `1010011`    | `10100`   | `rd = Comparison result (e.g., LE, LT, EQ)`|
| `FMV.X.W`         | `1010011`    | `11100`   | Move floating-point value to integer       |
| `FMV.W.X`         | `1010011`    | `11110`   | Move integer value to floating-point       |
| `FCVT.S.D`        | `1010011`    | `01000`   | Convert double-precision to single-precision |
| `FCVT.D.S`        | `1010011`    | `01000`   | Convert single-precision to double-precision |
| `FCVT.W.X`        | `1010011`    | `11000`   | Convert floating-point to integer (signed) |
| `FCVT.WU.X`       | `1010011`    | `11000`   | Convert floating-point to integer (unsigned) |

---

#### Notes

- **FMA Operations**: Floating-point multiply-add instructions (e.g., `FMADD`, `FMSUB`) combine multiplication and addition/subtraction into a single step.
- **Rounding Modes (`func3`)**: Specifies how floating-point results are rounded.
- **Precision Selection (`func2`)**: Determines if operations use single-precision (32-bit) or double-precision (64-bit).
- **Type Conversion**:
  - `FCVT` instructions handle conversions between integer and floating-point types.
  - `FMV` instructions transfer values between integer and floating-point registers.
- **Special Operations**:
  - `FDIV`: Floating-point division.
  - `FSQRT`: Floating-point square root.
  - `FSGNJ`: Floating-point sign manipulation (e.g., sign inversion).

This section outlines the instructions and arguments for floating-point operations in the `EXT_F_ENABLE` extension, focusing on precision, arithmetic, and type conversion functionality.
## Custom instruction 
``` verilog
`INST_EXT1: begin
    case (func7)
        7'h00: begin
            ex_type = `EX_SFU;
            is_wstall = 1;
            case (func3)
                3'h0: begin // TMC
                    op_type = `INST_OP_BITS'(`INST_SFU_TMC);
                    `USED_IREG (rs1);
                end
                3'h1: begin // WSPAWN
                    op_type = `INST_OP_BITS'(`INST_SFU_WSPAWN);
                    `USED_IREG (rs1);
                    `USED_IREG (rs2);
                end
                3'h2: begin // SPLIT
                    op_type = `INST_OP_BITS'(`INST_SFU_SPLIT);
                    use_rd    = 1;
                    op_args.wctl.is_neg = rs2[0];
                    `USED_IREG (rs1);
                    `USED_IREG (rd);
                end
                3'h3: begin // JOIN
                    op_type = `INST_OP_BITS'(`INST_SFU_JOIN);
                    `USED_IREG (rs1);
                end
                3'h4: begin // BAR
                    op_type = `INST_OP_BITS'(`INST_SFU_BAR);
                    `USED_IREG (rs1);
                    `USED_IREG (rs2);
                end
                3'h5: begin // PRED
                    op_type = `INST_OP_BITS'(`INST_SFU_PRED);
                    op_args.wctl.is_neg = rd[0];
                    `USED_IREG (rs1);
                    `USED_IREG (rs2);
                end
                default:;
            endcase
        end
        default:;
    endcase
end
```
#### Instruction Breakdown
The `INST_EXT1` opcode is used for specialized control and synchronization operations in the system. This section describes the possible suboperations based on `func7` and `func3`.

---

#### Operation Details

| **Func7** | **Func3** | **Operation** | **Description**                                   | **Key Registers**             |
|-----------|-----------|---------------|---------------------------------------------------|--------------------------------|
| `7'h00`   | `3'h0`    | `TMC`         | Thread Management Control: Adjust thread count.  | `rs1`                         |
|           | `3'h1`    | `WSPAWN`      | Spawn new warps with thread counts.              | `rs1`, `rs2`                  |
|           | `3'h2`    | `SPLIT`       | Split execution path into divergent branches.     | `rs1`, `rd`, `rs2[0]`         |
|           | `3'h3`    | `JOIN`        | Rejoin divergent paths into a single execution.  | `rs1`                         |
|           | `3'h4`    | `BAR`         | Synchronization barrier for threads.             | `rs1`, `rs2`                  |
|           | `3'h5`    | `PRED`        | Predicate control for threads (conditional exec).| `rs1`, `rs2`, `rd[0]`         |

---

#### Arguments and Execution Type

| **Field**        | **Value/Description**                                      |
|-------------------|------------------------------------------------------------|
| **Ex_type**       | `SFU` (Special Function Unit operation)                    |
| **Is_wstall**     | Always set to `1` to indicate execution stall for this op. |
| **Op_args.wctl**  | Controls additional settings for `SPLIT` and `PRED` ops.   |

---

#### Key Points
- **Thread Control**:
  - `TMC` adjusts active threads.
  - `WSPAWN` spawns additional warps with specified threads.
  - `SPLIT` manages execution divergence.
  - `JOIN` rejoins divergent execution paths.

- **Synchronization**:
  - `BAR` sets up thread synchronization points.

- **Predicate Control**:
  - `PRED` enables conditional execution for specific threads.

#### Implementation Notes
- Register usage is defined using macros:
  - `USED_IREG(rs1)` marks the first integer register.
  - `USED_IREG(rs2)` marks the second integer register.
  - `USED_IREG(rd)` marks the destination register.
- The `is_neg` flag is used in `SPLIT` and `PRED` for conditional branching and predicates.

This opcode extends the processor's capabilities for fine-grained thread and execution control, making it essential for parallel processing and synchronization.
