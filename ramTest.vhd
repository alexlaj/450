LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY ramTest IS
END ramTest;
 
ARCHITECTURE behavior OF ramTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ram
    PORT(
		clk : in std_ulogic;
		readAddr : in std_ulogic_vector (6 downto 0) := (others => '0');
		writeAddr : in std_ulogic_vector (6 downto 0) := (others => '0');
		writeEn : in std_ulogic := '0';
		inputData : in std_ulogic_vector (7 downto 0) := (others => '0');
		readRequest : in std_ulogic := '0';
		outputData : out std_ulogic_vector (7 downto 0) := (others => '0');
		dataReady : out std_ulogic := '0'
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_ulogic := '0';
   signal readAddr : std_ulogic_vector(6 downto 0) := (others => '0');
   signal writeAddr : std_ulogic_vector(6 downto 0) := (others => '0');
   signal writeEn : std_ulogic := '0';
   signal inputData : std_ulogic_vector(7 downto 0) := (others => '0');
   signal readRequest : std_ulogic := '0';

 	--Outputs
   signal outputData : std_ulogic_vector(7 downto 0);
   signal dataReady : std_ulogic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ram PORT MAP (
          clk => clk,
          readAddr => readAddr,
          writeAddr => writeAddr,
          writeEn => writeEn,
          inputData => inputData,
          readRequest => readRequest,
          outputData => outputData,
          dataReady => dataReady
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
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
      writeAddr <= "0000000";
      inputData <= "11111111";
      writeEn <= '1';
	wait for clk_period;
      writeAddr <= "0000001";
      inputData <= "11111111";
      writeEn <= '1';
	wait for clk_period;
      writeAddr <= "0000010";
      inputData <= "11111111";
      writeEn <= '1';
	wait for clk_period;
      writeAddr <= "0000011";
      inputData <= "11111111";
      writeEn <= '1';
  	wait for clk_period;
      readAddr <= "0000011";
      readRequest <= '1';
      wait;
   end process;

END;