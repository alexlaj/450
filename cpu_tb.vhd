--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:16:23 02/06/2015
-- Design Name:   
-- Module Name:   /home/alex/450/alu/cpu_tb.vhd
-- Project Name:  alu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cpu
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_ulogic and
-- std_ulogic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY cpu_tb IS
END cpu_tb;
 
ARCHITECTURE behavior OF cpu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu
    PORT(
         clk : IN  std_ulogic;
         rst : IN  std_ulogic;
         int : IN  std_ulogic;
         in_port : IN  std_ulogic_vector(7 downto 0);
         out_port : OUT  std_ulogic_vector(7 downto 0)
        );
    END COMPONENT;
    


   --Inputs
   signal clk : std_ulogic := '0';
   signal rst : std_ulogic := '0';
   signal int : std_ulogic := '0';
   signal in_port : std_ulogic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal out_port : std_ulogic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpu PORT MAP (
          clk => clk,
          rst => rst,
          int => int,
          in_port => in_port,
          out_port => out_port
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      rst <= '1';
      wait for 100 ns;  -- first four instructions fill the registers
      rst <= '0';
      in_port <= x"01";
      wait for clk_period;      
      in_port <= x"03";
      wait for clk_period;
      in_port <= x"05";
      wait for clk_period;
      in_port <= x"07";
      wait for clk_period;
      in_port <= "ZZZZZZZZ";
      wait;
   end process;

END;
