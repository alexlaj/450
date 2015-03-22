LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY cpuTest IS
END cpuTest;
 
ARCHITECTURE behavior OF cpuTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu
    PORT(
         clk :      IN  std_ulogic;
         rst :      IN  std_ulogic;
         int :      IN  std_ulogic;
         in_port :  IN  std_ulogic_vector(7 downto 0);
         out_port : OUT  std_ulogic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk :     std_ulogic := '0';
   signal rst :     std_ulogic := '0';
   signal int :     std_ulogic := '0';
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
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      -- wait for 100 ns;	

      -- wait for clk_period*2;

      -- insert stimulus here 
      
      
      --rst <= '1';
      wait for clk_period*5;
      in_port <= "00011000";
      wait for clk_period*1;
      in_port <= "00000001";
      wait for clk_period*1;
      in_port <= "00001001";
      wait for clk_period*1;
      in_port <= "00010101";
      wait for clk_period*1;
      in_port <= "00000000";
   end process;

END;
