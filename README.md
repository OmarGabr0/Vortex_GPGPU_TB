# FPGA-Based Hardware Acceleration of NTT with RISC-V ISA Customization

---
Note:
You can take a look at our resources and video tutorials, check out our [Resources.md](https://github.com/RISC-V-Based-Accelerators/Basic-Building-Blocks/blob/main/Resources.md) file for more details.
---
## Table of Contents

- [Objective](#objective)
- [Project Scope and Breakdown](#project-scope-and-breakdown)
  - [Project Scope](#project-scope)
  - [Research and Analysis](#research-and-analysis)
  - [Design and Implementation](#design-and-implementation)
  - [Testing and Validation](#testing-and-validation)
  - [Documentation and Presentation](#documentation-and-presentation)
  - [Project Breakdown](#project-breakdown)
- [Detailed Project Requirements](#detailed-project-requirements)
  - [Hardware Requirements](#hardware-requirements)
  - [Software Requirements](#software-requirements)
  - [Knowledge Requirements](#knowledge-requirements)
  - [Additional Resources and References](#additional-resources-and-references)
- [Project Deliverables](#project-deliverables)
  - [Design Documentation](#design-documentation)
  - [Implementation](#implementation)
  - [Testing and Validation](#testing-and-validation)
  - [Final Report](#final-report)
  - [Presentation](#presentation)
  - [Additional Materials (Optional)](#additional-materials-optional)
- [Potential Challenges](#potential-challenges)
  - [Complexity of NTT Algorithm](#complexity-of-ntt-algorithm)
  - [RISC-V ISA Extension](#risc-v-isa-extension-1)
  - [Integration with RISC-V Core](#integration-with-risc-v-core)
  - [FPGA Constraints](#fpga-constraints)
  - [Performance Optimization](#performance-optimization)
  - [Learning Curve and Development Time](#learning-curve-and-development-time)

---

## Objective

The objective of this project is to design and implement an accelerated Number Theoretic Transform (NTT) operation integrated with RISC-V through custom ISA extensions on an FPGA. The goal is to significantly enhance the performance of NTT, which is a critical and time-consuming operation in many cryptographic protocols and proof-generation processes.

---

## Project Scope and Breakdown

### Project Scope

The project aims to enhance the performance of Number Theoretic Transform (NTT) operations by designing a hardware accelerator integrated with a RISC-V processor and extending its Instruction Set Architecture (ISA) to efficiently support NTT operations on an FPGA platform. The main components of the project include:

#### Research and Analysis:
- Gain an in-depth understanding of the NTT algorithm and its computational bottlenecks.
- Study the RISC-V architecture and the process required to extend its ISA.
- Review existing FPGA-based accelerators and identify suitable development tools and platforms.

#### Design and Implementation:
- Design the NTT accelerator using SystemVerilog or High-Level Synthesis (HLS).
- Develop custom RISC-V instructions tailored for NTT operations.
- Integrate the NTT accelerator with a RISC-V core on an FPGA.

#### Testing and Validation:
- Create comprehensive testbenches to verify the functionality of the NTT accelerator.
- Validate the integration of custom RISC-V instructions with the core processor.
- Benchmark the performance improvements compared to a software-only implementation.

#### Documentation and Presentation:
- Document the design, implementation, and testing processes in detail.
- Prepare a final report summarizing the project.
- Develop a presentation and demonstration of the project outcomes.

---

## Project Breakdown

### Research and Planning (Weeks 1-4):
- **Literature Review:** Study NTT algorithm, RISC-V architecture, and FPGA design techniques.
- **Tool Selection:** Choose appropriate FPGA development tools and platforms.
- **Initial Planning:** Define project milestones, deliverables, and risk management strategies.

### Design Phase (Weeks 5-8):
- **NTT Accelerator Design:** Design the NTT algorithm using SystemVerilog or HLS.
- **ISA Extension:** Develop custom RISC-V instructions for NTT operations.
- **Integration Strategy:** Plan the integration of the NTT accelerator with the RISC-V core.

### Implementation Phase (Weeks 9-14):
- **NTT Accelerator Implementation:** Implement the NTT accelerator on the selected FPGA.
- **RISC-V Core Modification:** Extend the RISC-V core to support custom NTT instructions.
- **Integration:** Integrate the NTT accelerator with the RISC-V core on the FPGA.

### Testing and Validation Phase (Weeks 15-18):
- **Functional Testing:** Develop and run testbenches to verify the NTT accelerator.
- **ISA Validation:** Test the functionality of custom RISC-V instructions.
- **Performance Benchmarking:** Measure and compare the performance of the hardware-accelerated NTT against a software implementation.

### Documentation and Presentation (Weeks 19-22):
- **Documentation:** Compile comprehensive documentation covering design, implementation, testing, and results.
- **Final Report:** Write a detailed final report summarizing the project.
- **Presentation Preparation:** Develop slides and prepare a demonstration to present the project outcomes.


## Detailed Project Requirements

---

### 1. Hardware Requirements

#### FPGA Development Board:
Choose a suitable FPGA development board that supports custom hardware design and integration with a processor core. Examples include:
- **Xilinx Zynq-7000 series**
- **Intel (Altera) Cyclone V**
- **Digilent Arty A7 (for Xilinx Artix-7)**

Ensure the board has sufficient logic elements, memory, and I/O capabilities for the project.

#### RISC-V Core:
Select an appropriate RISC-V core that supports customization and extension. Examples include:
- **Rocket Chip** from the Berkeley Architecture Research group
- **PicoRV32** for a lightweight implementation
- **VexRiscv** for a more configurable core

Ensure compatibility with the chosen FPGA platform.

---

### 2. Software Requirements

#### FPGA Development Suite:
- **Xilinx Vivado** (for Xilinx FPGAs) or **Intel Quartus** (for Intel FPGAs):
  - Used for synthesis, place-and-route, and generating the bitstream.
- **Vivado HLS** or **Vitis HLS** (for High-Level Synthesis if using C/C++ for hardware design).

#### RISC-V Toolchain:
- **RISC-V GNU Compiler Toolchain**:
  - For compiling and assembling code for the RISC-V core.
- **Spike Simulator** or **QEMU**:
  - For simulating and debugging RISC-V code.

#### Hardware Description Languages (HDL):
- **SystemVerilog** or **VHDL**:
  - For designing the Poseidon2 accelerator and integrating it with the RISC-V core.

#### High-Level Synthesis (HLS) Tools (optional):
- If using HLS, tools like **Xilinx Vitis HLS** can be employed to convert C/C++ code into HDL.

#### Simulation and Verification Tools:
- **ModelSim** or **Xilinx Vivado Simulator**:
  - For simulating and verifying the HDL designs.
- **Synopsys VCS** (optional):
  - For advanced simulation capabilities.

---

### 3. Knowledge Requirements

### Digital Design and FPGA Programming:
- Understanding of digital logic design, finite state machines, and FPGA architecture.
- Proficiency in a hardware description language (**SystemVerilog/VHDL**).

#### RISC-V Architecture and ISA Extensions:
- Familiarity with the RISC-V instruction set architecture, including base ISA and extension mechanisms.
- Knowledge of how to modify and extend the RISC-V ISA to include custom instructions.

#### Poseidon2 Algorithm:
- In-depth knowledge of the Poseidon2 algorithm, its mathematical foundations, and computational requirements.

#### High-Level Synthesis (Optional):
- Experience with HLS tools if using C/C++ to design the accelerator.

---

### 4. Additional Resources and References

### Documentation and Tutorials:
- **RISC-V Specifications:** RISC-V ISA Specifications
- **FPGA Vendor Documentation:** Xilinx or Intel FPGA documentation and user guides.
- **Poseidon2 Algorithm Resources:** Research papers, textbooks, and online tutorials on Poseidon2 and related mathematical concepts.

#### Development Kits:
- **FPGA Development Kits:** Ensure access to development kits and necessary accessories (e.g., power supplies, cables).

#### Collaboration and Support:
- Access to forums, support communities, and potential collaboration with peers or mentors specializing in FPGA design and RISC-V.

---

### Project Deliverables

#### 1. Design Documentation

##### Poseidon2 Accelerator Design:
- Detailed design documents outlining the architecture and implementation of the Poseidon2 accelerator.
- Block diagrams, data flow diagrams, and state machine diagrams as applicable.
- Explanation of the chosen algorithmic optimizations and their impact on performance.

##### RISC-V ISA Extension:
- Documentation of the custom RISC-V instructions developed for Poseidon2 operations.
- Instruction format, encoding, and integration details.
- Rationale for the custom instructions and their expected performance benefits.

##### Integration Strategy:
- Detailed plan for integrating the Poseidon2 accelerator with the RISC-V core.
- Interface specifications between the accelerator and the RISC-V core.
- Memory and I/O considerations for the integrated system.

---

#### 2. Implementation

#### Hardware Description Code:
- **SystemVerilog** or **VHDL** code for the Poseidon2 accelerator.
- Modified RISC-V core with custom ISA extensions.
- Integration code to interface the Poseidon2 accelerator with the RISC-V core.
- HLS code (if applicable) for the Poseidon2 accelerator.

##### Simulation and Synthesis Files:
- Testbenches for simulating the Poseidon2 accelerator and verifying functionality.
- Synthesis scripts and configuration files for the FPGA development tools.
- FPGA bitstream file for programming the FPGA with the final design.

---

#### 3. Testing and Validation

##### Testbenches:
- Comprehensive testbenches for verifying the functional correctness of the Poseidon2 accelerator.
- Test cases for validating the custom RISC-V instructions.
- Integration testbenches to ensure the Poseidon2 accelerator works correctly with the RISC-V core.

##### Validation Reports:
- Detailed reports on the results of functional testing, including pass/fail status for each test case.
- Performance benchmarking results comparing the hardware-accelerated Poseidon2 operations to a software-only implementation.
- Analysis of resource utilization on the FPGA, including logic elements, memory blocks, and power consumption.

---

#### 4. Final Report

##### Project Overview:
- Introduction and background information on Poseidon2 and RISC-V.
- Objectives and scope of the project.

##### Design and Implementation:
- Detailed description of the design and implementation process.
- Challenges encountered and how they were addressed.

##### Testing and Results:
- Summary of testing methodologies and results.
- Performance analysis and comparison with baseline software implementation.

##### Conclusion and Future Work:
- Summary of key findings and achievements.
- Potential areas for future improvement and research.

---

#### 5. Presentation

##### Slides:
- A comprehensive slide deck covering all aspects of the project, including introduction, design, implementation, testing, results, and conclusions.
- Visual aids such as diagrams, charts, and graphs to illustrate key points.

##### Demonstration:
- Live demonstration of the working FPGA implementation showing the accelerated Poseidon2 operations.
- Explanation of the custom RISC-V instructions and how they enhance performance.
- Performance comparison between hardware-accelerated and software-only implementations.

---

#### 6. Additional Materials (Optional)

##### Video Presentation:
- A recorded video presentation summarizing the project and demonstrating the key results.
- Can be used as supplementary material for the final presentation.

##### Code Repository:
- A well-organized code repository (e.g., GitHub) containing all the source code, design files, and documentation.
- Instructions for setting up the development environment and reproducing the results.

---

### Potential Challenges

#### 1. Complexity of Poseidon2 Algorithm

##### Mathematical Complexity:
- Understanding and implementing the Poseidon2 algorithm correctly, including modular arithmetic and handling large prime numbers, can be challenging.
- Ensuring that the algorithm is optimized for hardware implementation without sacrificing correctness.

##### Resource Optimization:
- Balancing the trade-offs between speed, area, and power consumption in the FPGA implementation.
- Efficiently mapping the Poseidon2 operations to FPGA resources like DSP blocks, BRAM, and LUTs.

---

#### 2. RISC-V ISA Extension

##### Instruction Design:
- Designing custom RISC-V instructions that effectively accelerate Poseidon2 operations while maintaining the simplicity and orthogonality of the RISC-V ISA.
- Ensuring that the new instructions integrate seamlessly with the existing RISC-V pipeline and do not introduce hazards or performance bottlenecks.

##### Toolchain Modifications:
- Modifying the RISC-V toolchain (assembler, compiler, and simulator) to support the custom instructions.
- Ensuring that the modified toolchain produces correct and optimized code for the new instructions.

---

#### 3. Integration with RISC-V Core

##### Hardware Integration:
- Integrating the Poseidon2 accelerator with the RISC-V core requires careful design to ensure correct data transfer and synchronization.
- Handling interface protocols between the accelerator and the processor, such as memory-mapped I/O or custom co-processor interfaces.

##### Performance Bottlenecks:
- Identifying and mitigating potential performance bottlenecks introduced by the integration, such as data transfer delays or pipeline stalls.
- Ensuring that the overhead of invoking custom instructions does not negate the performance benefits of hardware acceleration.

---

#### 4. FPGA Constraints

##### Resource Utilization:
- Managing FPGA resource constraints, including logic elements, memory blocks, and I/O pins, especially if the design is complex and resource-intensive.
- Ensuring the design meets timing requirements and fits within the available FPGA resources.

##### Debugging and Verification:
- Debugging hardware designs can be challenging, especially when dealing with complex interactions between the processor and the accelerator.
- Developing comprehensive testbenches and validation strategies to ensure the design functions correctly under all conditions.

---

#### 5. Performance Optimization

##### Algorithmic Optimization:
- Optimizing the Poseidon2 algorithm for parallel execution in hardware while maintaining accuracy and robustness.
- Balancing between the depth of pipelining and the latency of individual operations to achieve optimal performance.

##### Benchmarking and Validation:
- Accurately measuring and comparing the performance of the hardware-accelerated Poseidon2 against a software-only implementation.
- Ensuring that the performance gains are significant and justify the complexity of the hardware design.

---

#### 6. Learning Curve and Development Time

##### Tool Proficiency:
- Gaining proficiency with FPGA development tools (e.g., Xilinx Vivado, Intel Quartus) and RISC-V toolchain modifications can take time and effort.
- Staying up-to-date with the latest developments in RISC-V and FPGA technologies.

##### Project Management:
- Managing the project timeline effectively to ensure that all milestones are met, and potential risks are mitigated.
- Allocating sufficient time for testing, debugging, and optimization phases.
