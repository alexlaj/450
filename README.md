## 450
A simple CPU written in VHDL for a class. Main files are imem.vhd (ROM), register_file.vhd (registers), alu.vhd (add/sub/shift/nand), and cpu.vhd (how the parts interact).
### Implemented Instructions
Bits marked Ra and Rb are the 2 bit identifier of the register (ie R1 is 01, R3 is 11). Bits marked X do not care about their value. Bits marked D are data bits, used in 2 byte instructions.
#### NOP 0000XXXX (1 byte)
No operation.
#### LOAD 0001RaXX DDDDDDDD (2 bytes)
Not yet implemented.
#### STORE 0010RaXX DDDDDDDD (2 bytes)
Not yet implemented.
#### LOADIMM 0011RaXX DDDDDDDD (2 bytes)
Loads the data value specified in the second byte into register Ra.
#### ADD 0100RaRb (1 byte)
Adds two register values and stores the result in Ra.
ADD R0, R1 will do R0+R1 and store the result in R0.
#### SUB 0101RaRb (1 byte)
Subtracts two register values and stores the result in Ra.
SUB R0, R1 will do R0-R1 and store the result in R0.
#### SHL 0110RaXX (1 byte)
Performs a zero padded logical shift one bit to the left, dropping the leftmost bit.
SHL R0 will shift the bits in R0 to the left. If the value of R0 is 11110000 before the shift it will be 11100000 after the shift.
#### SHR 0111RaXX (1 byte)
Performs a zero padded logical shift one bit to the right, dropping the rightmost bit.
SHR R0 will shift the bits in R0 to the right. If the value of R0 is 11110000 before the shift it will be 01111000 after the shift.
#### NAND 1000RaRb (1 byte)
NANDs the bits contained in the two registers and stores the result in Ra.
NAND R0, R1 will NAND the bits in R0 and R1 and will store the result in R0.
#### Branching 1001YYRb (1 byte)
Bits marked YY are identifiers for the type of branch to take.
##### BR 100100Rb
Sets the PC to the ROM location in Rb unconditionally.
##### BR.Z 100101Rb
Sets the PC to the ROM location in Rb if the zero flag from the ALU is set (last ALU operation was zero).
##### BR.N 100110Rb
Sets the PC to the ROM location in Rb if the negative flag from the ALU is set (last ALU operation was negative).
##### BR.SUB 100111Rb
Sets the PC to the ROM location stored in Rb unconditionally. Saves the current PC in a temporary register for use with the RETURN instruction.
#### PUSH 101001Rb (1 byte)
Not yet implemented.
#### POP 101000Rb (1 byte)
Not yet implemented.
#### IN 1011RaXX (1 byte)
Writes the value at the external IN port to Ra.
#### OUT 1100RaXX (1 byte)
Writes the value in Ra to the external OUT port.
#### MOV 1101RaRb (1 byte)
Moves the value from Rb into Ra. The value of Rb remains unchanged.
#### Return 111000XX
Sets the PC equal to the ROM location previously set by the BR.sub instruction. If BR.SUB has not be executed yet this instruction is treated as a NOP.
#### RTI 111011XX
Not yet implemented.

