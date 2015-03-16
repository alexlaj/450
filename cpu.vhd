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
signal operandA :      std_ulogic_vector(1 downto 0) := (others => '0');
signal operandB :      std_ulogic_vector(1 downto 0) := (others => '0');

-- Register signals
  -- Inputs
signal regRst :         std_ulogic := '0';
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
signal aluRst :         std_ulogic := '0';
signal aluMode :        std_ulogic_vector(3 downto 0) := (others => '0');
signal aluInputA :      std_ulogic_vector(7 downto 0) := (others => '0');
signal aluInputB :      std_ulogic_vector(7 downto 0) := (others => '0');
  -- Outputs
signal aluResult :      std_ulogic_vector(7 downto 0) := (others => '0');
signal aluNegative :    std_ulogic := '0';
signal aluZero :        std_ulogic := '0';
-- ALU Writeback
signal operandsReady : std_ulogic := '0';
signal writeRequestAlu : std_ulogic := '0';
signal writeAluRegister : std_ulogic_vector(1 downto 0) := (others => '0');
-- Branch handling
signal LR :             std_ulogic_vector(6 downto 0) := (others => '0');
signal pcBranch :   std_ulogic := '0';
signal subFlag : std_ulogic := '0';
signal writeOutPort : std_ulogic := '0';

begin

  -- entity declarations for instantiations
  rom : 		entity work.imem port map(clk, pc, romData);
  regfile : entity work.register_file port map(clk, regRst, regReadIndexA, regReadIndexB, regWriteIndex, regWriteEnable, regWriteData, regReadDataA, regReadDataB);
  alu : 		entity work.alu port map(clk, aluRst, aluMode, aluInputA, aluInputB, aluResult, aluNegative, aluZero);
	
 datapath: process(clk)
  begin
      if rising_edge(clk) then
        if rst = '1' then
          -- Reset system
          pc <= "0000000";
          out_port <= "00000000";
          regRst <= '1';
          aluRst <= '1';
          opcode <= "0000";
          operandA <= "00";
          operandB <= "00";
          regReadIndexA <= "00";
          regReadIndexB <= "00";
          regWriteIndex <= "00";
          regWriteEnable <= '0';
          regWriteData <= "00000000";
          aluMode <= "0000";
          aluInputA <= "00000000";
          aluInputB <= "00000000";
          writeRequestAlu <= '0';
          writeAluRegister <= "00";
        else
          -- Clear write enable so it's only on for one clock cycle
          regWriteEnable <= '0';
          -- Increment PC by 1 (convert logic vector and int to unsigned, add, then result to logic vector)
          if pcBranch = '1' then
            pc <= regReadDataA(6 downto 0);
            pcBranch <= '0';
          else
            pc <= std_ulogic_vector(unsigned(pc) + to_unsigned(1,1));
          end if;
          opcode <= romData(7 downto 4);
          operandA <= romData(3 downto 2);
          operandB <= romData(1 downto 0);
          
          -- Check for return
          if opcode = "1110" and subFlag = '1' then
            pc <= LR;
            subFlag <= '0';
          -- Check for branching
          elsif opcode = "1001" then
            -- Branch to operandB
            if (operandA = "00") or (operandA = "01" and aluZero = '1') or (operandA = "10" and aluNegative = '1') then
              regReadIndexA <= operandB;
              pcBranch <= '1';              
            -- Branch to subroutine at operandB
            elsif operandA = "11" then
              LR <= PC;
              subFlag <= '1';
              regReadIndexA <= operandB;
              pcBranch <= '1';
            end if;
          else  
            -- Check for ALU instructions that use two registers (add 0100, sub 0101, nand 1000, shift left 0110, shift right 0111)
            if opcode = "0100" or opcode = "0101" or opcode = "1000" or opcode = "0110" or opcode = "0111" then
              -- Get the data from the registers
              regReadIndexA <= operandA;
              regReadIndexB <= operandB;
              writeAluRegister <= operandA;
              operandsReady <= '1';
              aluMode <= opcode;
              
            -- Read data in from IN.PORT (external)
            elsif opcode = "1011" then
              -- Write back data to the first register
              regWriteIndex <= operandA;
              regWriteData <= in_port;
              regWriteEnable <= '1';            
              
            -- Write data to OUT.PORT (external)
            elsif opcode = "1100" then

              -- Get data from the first register and dump it in the outport
              regReadIndexA <= operandA;
              writeOutPort <= '1';            
            
            -- Move data from one register to another
            elsif opcode = "1101" then
              -- Read data from 2nd register
              regReadIndexA <= operandB;
              -- Write to first register
              regWriteIndex <= operandA;
              regWriteData <= regReadDataA;
              regWriteEnable <= '1';            
            end if;
            
            -- If the data from the registers is ready to send to ALU
            if operandsReady = '1' then
              -- Put the register data in the ALU inputs
              aluInputA <= regReadDataA;
              aluInputB <= regReadDataB;
              -- Request writeback for the ALU 
              writeRequestAlu <= '1';
              operandsReady <= '0';
              
            -- Writeback for the ALU, clear request line
            elsif writeRequestAlu = '1' then
              regWriteIndex <= writeAluRegister;
              regWriteData <= aluResult;
              regWriteEnable <= '1';
              writeRequestAlu <= '0';
              -- Write for outport if the operands are ready
            elsif writeOutPort = '1' then
                out_port <= regReadDataA;
                writeOutPort <= '0';
              
            end if;
          end if;
        end if;      
    end if;
 end process;

end Behavioral;
