----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:04:17 02/01/2015 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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
use IEEE.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    Port ( clk : in  std_ulogic;
           rst : in  std_ulogic;
           alu_mode : in  std_ulogic_VECTOR (3 downto 0);
           in_a : in  std_ulogic_VECTOR (7 downto 0);
           in_b : in  std_ulogic_VECTOR (7 downto 0);
           result : out  std_ulogic_VECTOR (7 downto 0);
           n : out  std_ulogic;
           z : out  std_ulogic);
end alu;

architecture Behavioral of alu is
begin
  process (clk)
  variable res : std_ulogic_vector(7 downto 0);
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        res := "00000000";
        n <= '0';
        z <= '0';
      else
        case alu_mode is
          when "0100" => res := std_ulogic_vector(signed(in_a) + signed(in_b));
          when "0101" => res := std_ulogic_vector(signed(in_a) - signed(in_b));
          when "0110" => res := in_a nand in_b;
          when "0111" => res := std_ulogic_vector(shift_right(signed(in_a),to_integer(signed(in_b))));
          when "1000" => res := std_ulogic_vector(shift_left(signed(in_a),to_integer(signed(in_b))));
          when others => res := "XXXXXXXX";
        end case;
        if (to_integer(signed(res)) < 0) then
          n <= '1';
        else
          n <= '0';
        end if; -- end if neg
        if (to_integer(signed(res)) = 0) then
          z <= '1';
        else
          z <= '0';
        end if; -- end if zero
      end if; -- end if rst=1
      result <= res;
    end if; -- end rising_edge clk
  end process;
end Behavioral;

