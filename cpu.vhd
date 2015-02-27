----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:50:52 02/06/2015 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
Port (
	clk :       in std_ulogic;
	rst :       in std_ulogic;
	int :       in std_ulogic; -- interrupt
	in_port :   in std_ulogic_vector(7 downto 0) := (others => '0');
	out_port :  out std_ulogic_vector(7 downto 0) := (others => '0')
	);
end cpu;

architecture Behavioral of cpu is

-- ROM signals (ROM is 128 bytes and is byte addressable)
  -- Inputs
signal pc :             std_ulogic_vector(6 downto 0) := (others => '0'); -- ROM address
  -- Outputs
signal romData :        std_ulogic_vector(7 downto 0) := (others => '0'); -- Instruction from ROM
-- romData breakdown signals
signal opcode:          std_ulogic_vector(3 downto 0) := (others => '0');
signal registerA :      std_ulogic_vector(1 downto 0) := (others => '0');
signal registerB :      std_ulogic_vector(1 downto 0) := (others => '0');

-- Register signals
  -- Inputs
signal regReadIndexA :  std_ulogic_vector(1 downto 0) := (others => '0');
signal regReadIndexB : 	std_ulogic_vector(1 downto 0) := (others => '0');
signal regWriteIndex : 	std_ulogic_vector(1 downto 0) := (others => '0');
signal regWriteEnable : std_ulogic := '0';
signal regWriteData : 	std_ulogic_vector(7 downto 0) := (others => '0');
  -- Outputs
signal regReadDataA : 	std_ulogic_vector(7 downto 0) := (others => '0');
signal regReadDataB : 	std_ulogic_vector(7 downto 0) := (others => '0');
-- ALU signals
  -- Inputs
signal aluMode : 	std_ulogic_vector(3 downto 0) := (others => '0');
signal aluInputA : 	std_ulogic_vector(7 downto 0) := (others => '0');
signal aluInputB : 	std_ulogic_vector(7 downto 0) := (others => '0');
  -- Outputs
signal aluResult : 		  std_ulogic_vector(7 downto 0) := (others => '0');
signal aluNegative : 		std_ulogic := '0';
signal aluZero : 				std_ulogic := '0';
-- Misc
signal writeRequestAlu : std_ulogic := '0';


begin

  -- entity declarations for instantiations
  rom : 		entity work.imem port map(clk, pc, romData);
  regfile : entity work.register_file port map(clk, rst, regReadIndexA, regReadIndexB, regWriteIndex, regWriteEnable, regWriteData, regReadDataA, regReadDataB);
  alu : 		entity work.alu port map(clk, rst, aluMode, aluInputA, aluInputB, aluResult, aluNegative, aluZero);
	
 datapath: process(clk)
  begin
    if rising_edge(clk) then
      if rising_edge(clk) then
        if rst = '1' then
          -- Reset system
          pc <= "0000000";
          -- Still need to reset ROM, regfile
        else
          -- Clear write enable so it's only on for one clock cycle
          regWriteEnable <= '0';
          -- Increment PC by 1 (convert logic vector and int to unsigned, add, then result to logic vector)
          pc <= std_ulogic_vector(unsigned(pc) + to_unsigned(1,1));
          opcode <= romData(7 downto 4);
          registerA <= romData(3 downto 2);
          registerB <= romData(1 downto 0);
          -- Check for ALU instructions that use two registers (add 0100, sub 0101, nand 1000, shift left 0110, shift right 0111)
          if opcode = "0100" or opcode = "0101" or opcode = "1000" or opcode = "0110" or opcode = "0111" then
            -- Get the data from the registers
            regReadIndexA <= registerA;
            regReadIndexB <= registerB;
            -- Put the register data in the ALU inputs
            aluInputA <= regReadDataA;
            aluInputB <= regReadDataB;
            -- Set the ALU mode
            aluMode <= opcode;
            -- Request writeback for the ALU 
            writeRequestAlu <= '1';
            
          -- Read data in from IN.PORT (external)
          elsif opcode = "1011" then
            -- Write back data to the first register
            regWriteIndex <= registerA;
            regWriteData <= in_port;
            regWriteEnable <= '1';            
            
          -- Write data to OUT.PORT (external)
          elsif opcode = "1100" then
            -- Get data from the first register and dump it in the outport
            regReadIndexA <= registerA;
            out_port <= regReadDataA;
          
          -- Move data from one register to another
          elsif opcode = "1101" then
            -- Read data from 2nd register
            regReadIndexA <= registerB;
            -- Write to first register
            regWriteIndex <= registerA;
            regWriteData <= regReadDataA;
            regWriteEnable <= '1';            
          end if;
          -- Writeback for the ALU, clear request line
          if writeRequestAlu = '1' then
            regWriteIndex <= registerA;
            regWriteData <= aluResult;
            regWriteEnable <= '1';
            writeRequestAlu <= '0';
          end if;
        end if;
      end if;      
    end if;
 end process;

end Behavioral;

