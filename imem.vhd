library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_ARITH.all;

entity imem is
    port(
        clk      : in  std_ulogic;
        addr     : in  std_ulogic_vector (6 downto 0);
        data     : out std_ulogic_vector (7 downto 0)
        );
end imem;
architecture BHV of imem is
    type ROM_TYPE is array (0 to 127) of std_ulogic_vector (7 downto 0);
    constant rom_content : ROM_TYPE := (
    x"00", -- 1) 00000000 NOP
    x"30", -- 2) 00110000 LOADIMM R0 0xC0 Shape for moving around
    x"c0", -- 3) 11000000 0xc0
    x"34", -- 4) 00110100 LOADIMM R1 0x06 Counter until branch to subsection
    x"06", -- 5) 00000110 0x06
    x"38", -- 6) 00111000 LOADIMM R2 0x01 To decrement counter
    x"01", -- 7) 00000001 0x01
    x"3c", -- 8) 00111100 LOADIMM R3 0xF0 Branching addresses
    x"f0", -- 9) 11110000 0xf0
    x"20", -- 10) 00100000 STORE R0 0x01
    x"01", -- 11) 00000001 0x01
    x"24", -- 12) 00100100 STORE R1 0x02
    x"02", -- 13) 00000010 0x02
    x"28", -- 14) 00101000 STORE R2 0x03
    x"03", -- 15) 00000011 0x03
    x"2c", -- 16) 00101100 STORE R3 0xF0
    x"f0", -- 17) 11110000 0xf0
    x"00", -- 18) 00000000 NOP
    x"00", -- 19) 00000000 NOP
    x"00", -- 20) 00000000 NOP For loop start
    x"24", -- 21) 00100100 STORE R1 0x06
    x"06", -- 22) 00000110 0x06
    x"c0", -- 23) 11000000 OUT R0
    x"1c", -- 24) 00011100 LOAD R3 0xF0
    x"f0", -- 25) 11110000 0xf0
    x"00", -- 26) 00000000 NOP
    x"00", -- 27) 00000000 NOP
    x"38", -- 28) 00111000 LOADIMM R2 0x03
    x"03", -- 29) 00000011 0x03
    x"00", -- 30) 00000000 NOP
    x"56", -- 31) 01010110 SUB R1 R2 Sets negative flag in ALU if we've done 3 iterations
    x"00", -- 32) 00000000 NOP
    x"14", -- 33) 00010100 LOAD R1 0x06
    x"06", -- 34) 00000110 0x06
    x"00", -- 35) 00000000 NOP
    x"38", -- 36) 00111000 LOADIMM R2 1
    x"01", -- 37) 00000001 1
    x"3c", -- 38) 00111100 LOADIMM R3 58 Branch past SHR
    x"3a", -- 39) 00111010 58
    x"00", -- 40) 00000000 NOP
    x"00", -- 41) 00000000 NOP
    x"97", -- 42) 10010111 BR.Z R3 If we have done 3 iterations shift left, else shift right
    x"00", -- 43) 00000000 NOP
    x"9b", -- 44) 10011011 BR.N R3
    x"70", -- 45) 01110000 SHR R0
    x"00", -- 46) 00000000 NOP
    x"00", -- 47) 00000000 NOP
    x"70", -- 48) 01110000 SHR R0
    x"00", -- 49) 00000000 NOP
    x"56", -- 50) 01010110 SUB R1 R2
    x"00", -- 51) 00000000 NOP
    x"3c", -- 52) 00111100 LOADIMM R3 19 Branch to beginning
    x"13", -- 53) 00010011 19
    x"00", -- 54) 00000000 NOP
    x"00", -- 55) 00000000 NOP
    x"93", -- 56) 10010011 BR R3
    x"00", -- 57) 00000000 NOP
    x"00", -- 58) 00000000 NOP
    x"00", -- 59) 00000000 NOP
    x"00", -- 60) 00000000 NOP
    x"00", -- 61) 00000000 NOP
    x"00", -- 62) 00000000 NOP
    x"60", -- 63) 01100000 SHL R0
    x"00", -- 64) 00000000 NOP
    x"3c", -- 65) 00111100 LOADIMM R3 80
    x"50", -- 66) 01010000 80
    x"60", -- 67) 01100000 SHL R0
    x"00", -- 68) 00000000 NOP
    x"00", -- 69) 00000000 NOP
    x"97", -- 70) 10010111 BR.Z R3 If the two bits have been shifted to 0 branch to next routine
    x"56", -- 71) 01010110 SUB R1 R2
    x"00", -- 72) 00000000 NOP
    x"00", -- 73) 00000000 NOP
    x"3c", -- 74) 00111100 LOADIMM R3 19 Branch to beginning
    x"13", -- 75) 00010011 19
    x"00", -- 76) 00000000 NOP
    x"00", -- 77) 00000000 NOP
    x"93", -- 78) 10010011 BR R3
    x"00", -- 79) 00000000 NOP
    x"00", -- 80) 00000000 NOP For loop is over now
    x"00", -- 81) 00000000 NOP 
    x"30", -- 82) 00110000 LOADIMM R0 0x80 Shape
    x"80", -- 83) 10000000 0x80
    x"34", -- 84) 00110100 LOADIMM R1 0xFF 
    x"ff", -- 85) 11111111 0xff
    x"38", -- 86) 00111000 LOADIMM R2 0x80 Add to shape
    x"80", -- 87) 10000000 0x80
    x"3c", -- 88) 00111100 LOADIMM R3 0x01 Branching address
    x"01", -- 89) 00000001 0x01
    x"c0", -- 90) 11000000 OUT R0
    x"00", -- 91) 00000000 NOP
    x"00", -- 92) 00000000 NOP
    x"00", -- 93) 00000000 NOP
    x"00", -- 94) 00000000 NOP
    x"00", -- 95) 00000000 NOP
    x"00", -- 96) 00000000 NOP
    x"00", -- 97) 00000000 NOP
    x"00", -- 98) 00000000 NOP
    x"00", -- 99) 00000000 NOP
    x"00", -- 100) 00000000 NOP
    x"00", -- 101) 00000000 NOP
    x"70", -- 102) 01110000 SHR R0
    x"00", -- 103) 00000000 NOP
    x"00", -- 104) 00000000 NOP
    x"42", -- 105) 01000010 ADD R0 R2
    x"00", -- 106) 00000000 NOP
    x"00", -- 107) 00000000 NOP
    x"c0", -- 108) 11000000 OUT R0
    x"00", -- 109) 00000000 NOP
    x"34", -- 110) 00110100 LOADIMM R1 0xFF
    x"ff", -- 111) 11111111 0xff
    x"00", -- 112) 00000000 NOP
    x"00", -- 113) 00000000 NOP
    x"54", -- 114) 01010100 SUB R1 R0
    x"00", -- 115) 00000000 NOP
    x"3c", -- 116) 00111100 LOADIMM R3 1
    x"01", -- 117) 00000001 1
    x"00", -- 118) 00000000 NOP
    x"00", -- 119) 00000000 NOP
    x"97", -- 120) 10010111 BR.Z R3
    x"00", -- 121) 00000000 NOP
    x"00", -- 122) 00000000 NOP
    x"3c", -- 123) 00111100 LOADIMM R3 100
    x"64", -- 124) 01100100 100
    x"00", -- 125) 00000000 NOP
    x"00", -- 126) 00000000 NOP
    x"93", -- 127) 10010011 BR R3
    others => x"00"
);
begin
p1:    process (clk)
    variable add_in : integer := 0;
    begin
        if rising_edge(clk) then
            add_in := conv_integer(unsigned(addr));
            data <= rom_content(add_in);
        end if;
    end process;
end BHV;
