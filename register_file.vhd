library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity register_file is
port ( 	clk: in std_ulogic;
			rst: in std_ulogic;
			rd_index_a: in std_ulogic_vector(1 downto 0);
			rd_index_b: in std_ulogic_vector(1 downto 0);
			wr_index: in std_ulogic_vector(1 downto 0);
			wr_en: in std_ulogic;
			wr_data: in std_ulogic_vector(7 downto 0);
			rd_data_a: out std_ulogic_vector(7 downto 0);
			rd_data_b: out std_ulogic_vector(7 downto 0)
			);
			
end register_file;

architecture Behavioral of register_file is
type registers is array(0 to 3) of std_ulogic_vector(7 downto 0); 
signal regfile : registers;
begin
	rd_data_a <= regfile(to_integer(unsigned(rd_index_a)));
	rd_data_b <= regfile(to_integer(unsigned(rd_index_b)));
	process (clk)
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				regfile(0) <= "00000000";
				regfile(1) <= "00000000";
				regfile(2) <= "00000000";
				regfile(3) <= "00000000";		
			else
				if (wr_en = '1') then
					regfile(to_integer(unsigned(wr_index))) <= wr_data;
				end if;
			end if;
		end if;
	end process;
end Behavioral;

