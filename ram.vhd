library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity ram is
	port(
		clk : in std_ulogic;
		readAddr : in std_ulogic_vector (6 downto 0) := (others => '0');
		writeAddr : in std_ulogic_vector (6 downto 0) := (others => '0');
		writeEn : in std_ulogic := '0';
		inputData : in std_ulogic_vector (7 downto 0) := (others => '0');
		readRequest : in std_ulogic := '0';
		outputData : out std_ulogic_vector (7 downto 0) := (others => '0');
		dataReady : out std_ulogic := '0'
	);
end ram;

architecture Behavioral of ram is
type RAM_TYPE is array (0 to 127) of std_ulogic_vector (7 downto 0);
signal ramData : RAM_TYPE;
  
begin
process (clk)
	begin
		if rising_edge(clk) then
			-- Make sure dataReady is only on for one clock cycle
			dataReady <= '0';
			-- Check for write/read
			if writeEn = '1' then
				ramData(to_integer(unsigned(writeAddr))) <= inputData;
      end if;
		end if;
		if readRequest = '1' then
			outputData <= ramData(to_integer(unsigned(readAddr)));
			dataReady <= '1';
		end if;
end process;

end Behavioral;
