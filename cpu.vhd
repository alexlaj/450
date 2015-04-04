library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
Port (
	fast_clk : in std_ulogic;
	rst : in std_ulogic;
	int : in std_ulogic; -- interrupt
	in_port : in std_ulogic_vector(7 downto 0) := (others => '0');
	out_port : out std_ulogic_vector(7 downto 0) := (others => '0');
	sevenseg_enabled : out std_ulogic_vector(3 downto 0) := (others => '0');
	sevenseg_segment : out std_ulogic_vector(7 downto 0) := (others => '0')	
	);
end cpu;

architecture Behavioral of cpu is

-- ROM signals (ROM is 128 bytes and is byte addressable)
  -- Inputs
signal pc : std_ulogic_vector(6 downto 0) := (others => '0'); -- ROM address
signal clk : std_ulogic := '0'; -- ROM address
signal clk_div_count : std_ulogic_vector(3 downto 0) := (others => '0'); -- ROM address
  -- Outputs
signal romData : std_ulogic_vector(7 downto 0) := (others => '0'); -- Instruction from ROM
-- romData breakdown signals
signal opcode : std_ulogic_vector(3 downto 0) := (others => '0');
signal operandA : std_ulogic_vector(1 downto 0) := (others => '0');
signal operandB : std_ulogic_vector(1 downto 0) := (others => '0');

-- Register signals
  -- Inputs
signal regRst : std_ulogic := '0';
signal regReadIndexA : std_ulogic_vector(1 downto 0) := (others => '0');
signal regReadIndexB :	std_ulogic_vector(1 downto 0) := (others => '0');
signal regWriteIndex : std_ulogic_vector(1 downto 0) := (others => '0');
signal regWriteEnable : std_ulogic := '0';
signal regWriteData : std_ulogic_vector(7 downto 0) := (others => '0');
  -- Outputs
signal regReadDataA : std_ulogic_vector(7 downto 0) := (others => '0');
signal regReadDataB : std_ulogic_vector(7 downto 0) := (others => '0');

-- ALU signals
  -- Inputs
signal aluRst : std_ulogic := '0';
signal aluMode : std_ulogic_vector(3 downto 0) := (others => '0');
signal aluInputA : std_ulogic_vector(7 downto 0) := (others => '0');
signal aluInputB : std_ulogic_vector(7 downto 0) := (others => '0');
  -- Outputs
signal aluResult : std_ulogic_vector(7 downto 0) := (others => '0');
signal aluNegative : std_ulogic := '0';
signal aluZero : std_ulogic := '0';

-- ALU Writeback
signal writeRequestAlu : std_ulogic := '0';
signal writeAluRegister : std_ulogic_vector(1 downto 0) := (others => '0');

-- RAM signals
  -- Inputs
signal ramReadAddr : std_ulogic_vector(6 downto 0) := (others => '0');
signal ramWriteAddr : std_ulogic_vector(6 downto 0) := (others => '0');
signal ramWriteEnable : std_ulogic := '0';
signal ramInputData : std_ulogic_vector(7 downto 0) := (others => '0');
signal ramReadRequest : std_ulogic := '0';
  -- Outputs
signal ramOutputData : std_ulogic_vector(7 downto 0) := (others => '0');
signal ramDataReady : std_ulogic := '0';

-- Branch handling
signal LR : std_ulogic_vector(6 downto 0) := (others => '0');
signal subFlag : std_ulogic := '0';
signal pcBranch : std_ulogic := '0';
signal loadToReg : std_ulogic := '0';
signal loadTarget : std_ulogic_vector(1 downto 0) := (others => '0');

signal storeAddress : std_ulogic_vector(6 downto 0) := (others => '0');
signal storeToMem : std_ulogic := '0';


-- 7 segment display variables


begin

-- entity declarations for instantiations
rom : entity work.imem port map(clk, pc, romData);
regfile : entity work.register_file port map(clk, regRst, regReadIndexA, regReadIndexB, regWriteIndex, regWriteEnable, regWriteData, regReadDataA, regReadDataB);
alu : entity work.alu port map(clk, aluRst, aluMode, aluInputA, aluInputB, aluResult, aluNegative, aluZero);
ram : entity work.ram port map(clk, ramReadAddr, ramWriteAddr, ramWriteEnable, ramInputData, ramReadRequest, ramOutputData, ramDataReady);
display : entity work.display port map(pc, sevenseg_enabled, sevenseg_segment, fast_clk, rst);

datapath: process(fast_clk)
	begin
		if rising_edge(fast_clk) then
			if rst = '1' then
				clk_div_count <= "0001";
				clk <= '0';
			else
				clk_div_count <= clk_div_count(2 downto 0) & clk_div_count(3);
				if clk_div_count(3) = '1' then
					clk <= not clk;
				end if;
			end if;
		end if;
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
				ramWriteEnable <= '0';

				-- Increment PC, check for branch first
				pc <= std_ulogic_vector(unsigned(pc) + to_unsigned(1,1));

				-- If last ins was a 2 byte or a branch then we need to NOP for a cycle
				if opcode = "0011" or opcode = "0001" or opcode = "0010" then
					opcode <= "0000";
					operandA <= "00";
					operandB <= "00";
				else
					opcode <= romData(7 downto 4);
					operandA <= romData(3 downto 2);
					operandB <= romData(1 downto 0);
				end if;

				-- Being greedy here. Register file will be accessed every clock cycle. It will not always be needed.
				-- Advantage is that values are always ready for reading when needed, don't have to wait a clock cycle.
				regReadIndexA <= romData(3 downto 2);
				regReadIndexB <= romData(1 downto 0);

				-- Return, make sure we did a br.sub first
				if opcode = "1110" and subFlag = '1' then
					pc <= LR;
					subFlag <= '0';
				-- Branching
				elsif opcode = "1001" then
					-- Branch to operandB
					if (operandA = "00") or (operandA = "01" and aluZero = '1') or (operandA = "10" and aluNegative = '1') then
						pc <= regReadDataB(6 downto 0);
						opcode <= "0000"; -- Set next opcode to 0 on sucessful branch             
					-- Branch to subroutine at operandB
					elsif operandA = "11" then
						LR <= PC;
						subFlag <= '1';
						pc <= regReadDataB(6 downto 0);
						opcode <= "0000"; -- Set next opcode to 0 on sucessful branch    
					end if;
				-- ALU instructions that use two registers
				-- (add 0100, sub 0101, shift left 0110, shift right 0111, nand 1000)
				elsif opcode = "0100" or opcode = "0101" or opcode = "0110" or opcode = "0111" or opcode = "1000" then
					writeAluRegister <= operandA;
					aluMode <= opcode;
					-- Put the register data in the ALU inputs
					aluInputA <= regReadDataA;
					aluInputB <= regReadDataB;
					-- Request writeback for the ALU 
					writeRequestAlu <= '1';                            
				-- Read data in from IN.PORT (external)
				elsif opcode = "1011" then
					-- Write back data to the first register
					regWriteIndex <= operandA;
					regWriteData <= in_port;
					regWriteEnable <= '1';                          
				-- Write data to OUT.PORT (external)
				elsif opcode = "1100" then
					out_port <= regReadDataA;                       
				-- Move data from one register to another
				elsif opcode = "1101" then
					regWriteIndex <= operandA;
					regWriteData <= regReadDataB;
					regWriteEnable <= '1';
				-- Load immediate value into register
				elsif opcode = "0011" then
					regWriteIndex <= operandA;
					regWriteData <= romData;
					regWriteEnable <= '1';
				-- Load value from memory into register
				elsif opcode = "0001" then
					ramReadAddr <= romData(6 downto 0);
					ramReadRequest <= '1';
					loadToReg <= '1';
					loadTarget <= operandA;
				-- Store value from register to memory 
				elsif opcode = "0010" then
					regReadIndexA <= operandA;
					storeAddress <= romData(6 downto 0);
					storeToMem <= '1';           
				end if;

				-- Register writeback for the ALU, clear request line
				if writeRequestAlu = '1' then
					regWriteIndex <= writeAluRegister;
					regWriteData <= aluResult;
					regWriteEnable <= '1';
					writeRequestAlu <= '0';				
				end if;
				-- Storing memory value in register
				if loadToReg = '1' and ramDataReady = '1' then
					regWriteIndex <= loadTarget;
					regWriteData <= ramOutputData;
					regWriteEnable <= '1';
					loadToReg <= '0';
				end if;
				-- Storing register value in memory
				if storeToMem = '1' then
					ramWriteAddr <= storeAddress;
					ramInputData <= regReadDataA;
					ramWriteEnable <= '1';
					storeToMem <= '0';
				end if;
			end if;      
		end if;
end process;

end Behavioral;
