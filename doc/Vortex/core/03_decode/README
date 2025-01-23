# decoding stage 
## Overview:

decoding stage responsible for decoding binary instruction fetched from scheduling stage, produce signals for excution units, specify used registers, and play a role in warp stall unlocking 

### Responsibilities:
1. **Excution unit selection**: determine wich excution unit would be selected for to excute specific warp, and determine the type of operation done in chosen excution unit (addition, substaction,...)

2. **Regester selection**: 
Determine and prepare register for excution (rd,rs1,rs2,rs3), and determine the type of of register (Integer o Floating point register). 

3. **Warp stall infomation**: 
also play a role in determination warp stall information to inform scheduling stage.

## Interfaces: 

### Fetch unit interface: 
decodin stage request to recieve instruction from ichache memory in fetching stage, and manage communication between stages 

### schdeduling_decodin interface: 
Responsible for reactivation of stalled warps in scheduling stage and resolution of deadloocks 

### Decode interface: 
pass the decoded warps to it's corresponding instruction buffer slice in issue slice based on warp tag (wid,uuid) in Issue stage, to resolve additional warp stalling and manage Hazards and dependencies 




