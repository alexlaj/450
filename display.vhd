----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:47:38 03/30/2015 
-- Design Name: 
-- Module Name:    display - Behavioral 
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


entity display is
    Port ( data : in  std_ulogic_VECTOR (6 downto 0);
           enabled : out  std_ulogic_VECTOR (3 downto 0);
           segment : out  std_ulogic_VECTOR (7 downto 0);
           clk : in std_ulogic;
           rst : in std_ulogic);
end display;


architecture Behavioral of display is
function digit_to_sev(num : integer range 0 to 9)
              return std_ulogic_vector is
variable ret : std_ulogic_vector(7 downto 0);
begin
    case num is
        when 0 =>  ret := "00000011";
        when 1 =>  ret := "10011111";
        when 2 =>  ret := "00100101";
        when 3 =>  ret := "00001101";
        when 4 =>  ret := "10011001";
        when 5 =>  ret := "01001001";
        when 6 =>  ret := "01000001";
        when 7 =>  ret := "00011111";
        when 8 =>  ret := "00000001";
        when 9 =>  ret := "00001001";
        when others =>   ret := "01101110"; -- looks like letter H
    end case;
    return ret;
end function digit_to_sev;
  shared variable ones : std_ulogic_VECTOR (3 downto 0);
  shared variable tens : std_ulogic_VECTOR (3 downto 0);
  shared variable hundreds : std_ulogic_VECTOR (3 downto 0);
  shared variable thousands : std_ulogic_VECTOR (3 downto 0);
begin
bcd1: process(data)
 
  -- temporary variable
  variable temp : std_ulogic_VECTOR (11 downto 0);
 
  -- variable to store the output BCD number
  -- organized as follows
  -- thousands = bcd(15 downto 12)
  -- hundreds = bcd(11 downto 8)
  -- tens = bcd(7 downto 4)
  -- units = bcd(3 downto 3)
  variable bcd : UNSIGNED (15 downto 0) := (others => '0');
 
  -- by
  -- https://en.wikipedia.org/wiki/Double_dabble
 
  begin
    -- zero the bcd variable
    bcd := (others => '0');
 
    -- read input into temp variable
    temp(11 downto 0) := "00000" & data;
 
    -- cycle 12 times as we have 12 input bits
    -- this could be optimized, we dont need to check and add 3 for the 
    -- first 3 iterations as the number can never be >4
    for i in 0 to 11 loop
 
      if bcd(3 downto 0) > 4 then 
        bcd(3 downto 0) := bcd(3 downto 0) + 3;
      end if;
 
      if bcd(7 downto 4) > 4 then 
        bcd(7 downto 4) := bcd(7 downto 4) + 3;
      end if;
 
      if bcd(11 downto 8) > 4 then  
        bcd(11 downto 8) := bcd(11 downto 8) + 3;
      end if;
 
      -- thousands can't be >4 for a 12-bit input number
      -- so don't need to do anything to upper 4 bits of bcd
 
      -- shift bcd left by 1 bit, copy MSB of temp into LSB of bcd
      bcd := bcd(14 downto 0) & temp(11);
 
      -- shift temp left by 1 bit
      temp := temp(10 downto 0) & '0';
 
    end loop;
 
    -- set outputs
    ones := std_ulogic_VECTOR(bcd(3 downto 0));
    tens := std_ulogic_VECTOR(bcd(7 downto 4));
    hundreds := std_ulogic_VECTOR(bcd(11 downto 8));
    thousands := std_ulogic_VECTOR(bcd(15 downto 12));

    
    end process;
    process(clk)
    variable new_enabled : std_ulogic_VECTOR(3 downto 0);
        begin
        if rising_edge(clk) then
            if rst = '1' then
                new_enabled := "1110";
            else
                new_enabled := new_enabled(2 downto 0)  & new_enabled(3) ;
                case new_enabled is
                when "1110" => segment <= digit_to_sev(to_integer(unsigned(thousands)));
                when "1101" => segment <= digit_to_sev(to_integer(unsigned(hundreds)));
                when "1011" => segment <= digit_to_sev(to_integer(unsigned(tens)));
                when "0111" => segment <= digit_to_sev(to_integer(unsigned(ones)));
                when others => segment <= x"00";
                end case;
            end if;
        end if;
        enabled <= new_enabled;
    end process;
end Behavioral;

