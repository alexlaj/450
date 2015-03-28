library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_ARITH.all;

entity imem is
    port(
        clk      : in  std_ulogic;
        addr     : in  std_ulogic_vector (6 downto 0);
        data     : out std_ulogic_vector (7 downto 0)
        );
end imem;
architecture BHV of imem is
    type ROM_TYPE is array (0 to 127) of std_ulogic_vector (7 downto 0);
    constant rom_content : ROM_TYPE := (

-- in this program, the loop will be executed 8 times, each time r0 is right shifted and r1 is left shifted
-- first 4 loops, output (add r0, r1), last 4 loops, output (nand r0,r1)
-- 1st loop: out 7F+FE = 01111101
-- 2nd loop: out 3F+FC = 00111000
-- 3rd loop: out 1F+F8 = 00010111
-- 4th loop: out 0F+F0 = 11111111
-- 5th loop: out 07 nand E0 = 11111111
-- 6th loop: out 03 nand C0 = 11111111
-- 7th loop: out 01 nand 80 = 11111111
-- 8th loop: out 00 nand 00 = 11111111



00 =>   x"00", -- NOP
01 =>   x"00", -- NOP
02 =>	x"30", -- loadimm	r0,0F		#start#  
03 =>	x"0F", -- 
04 =>	x"00", -- NOP
05 =>	x"00", -- NOP
06 =>	x"00", -- NOP
07 =>	x"00", -- NOP
08 =>	x"00", -- NOP
09 =>	x"20", -- store	 r0,add_nand
10 =>	x"0F", -- 
11 =>	x"30", -- loadimm	r0,7
12 =>	x"07", -- 
13 =>	x"00", -- NOP
14 =>	x"00", -- NOP
15 =>	x"00", -- NOP
16 =>	x"00", -- NOP
17 =>	x"00", -- NOP
18 =>	x"20", -- store		r0,counter
19 =>	x"0E", -- 
20 =>	x"30", -- loadimm 	r0,FF
21 =>	x"FF", -- 
22 =>	x"34", -- loadimm		r1,FF
23 =>	x"FF", -- 
24 =>	x"00", -- NOP
25 =>	x"00", -- NOP
26 =>	x"00", -- NOP
27 =>	x"00", -- NOP
28 =>	x"00", -- NOP
29 =>	x"70", -- shr		r0  		#loop# 
30 =>	x"64", -- shl		r1
31 =>	x"00", -- NOP
32 =>	x"00", -- NOP
33 =>	x"00", -- NOP
34 =>	x"00", -- NOP
35 =>	x"DC", -- mov		r3,r0 	
36 =>	x"10", -- load		r0,add_nand
37 =>	x"0F", -- 
38 =>	x"00", -- NOP
39 =>	x"00", -- NOP
40 =>	x"00", -- NOP
41 =>	x"00", -- NOP
42 =>	x"00", -- NOP
43 =>	x"70", -- shr		r0
44 =>	x"00", -- NOP
45 =>	x"00", -- NOP
46 =>	x"00", -- NOP
47 =>	x"00", -- NOP
48 =>	x"00", -- NOP
49 =>	x"20", -- store		r0,add_nand
50 =>	x"0F", -- 
51 =>	x"D3", -- mov		r0,r3	
52 =>	x"00", -- NOP
53 =>	x"00", -- NOP
54 =>	x"00", -- NOP
55 =>	x"00", -- NOP
56 =>	x"00", -- NOP
57 =>	x"00", -- NOP
58 =>	x"38", -- loadimm		r2,nand
59 =>	x"4B", -- 
60 =>	x"00", -- NOP
61 =>	x"00", -- NOP
62 =>	x"00", -- NOP
63 =>	x"00", -- NOP
64 =>	x"96", -- brz		nand:
65 =>	x"41", -- add		r0,r1
66 =>	x"00", -- NOP   
67 =>	x"38", -- loadimm	r2,out_add_nand
68 =>	x"4C", -- 
69 =>	x"00", -- NOP
70 =>	x"00", -- NOP
71 =>	x"00", -- NOP
72 =>	x"00", -- NOP
73 =>	x"00", -- NOP
74 =>	x"92", -- br		out_add_nand
75 =>	x"81", -- nand		r0,r1              #nand#
76 =>	x"00", -- NOP    			   #out_add_nand# 
77 =>	x"00", -- NOP
78 =>	x"00", -- NOP
79 =>	x"00", -- NOP
80 =>	x"00", -- NOP
81 =>	x"C0", -- out		r0
82 =>	x"10", -- load		r0,counter
83 =>	x"0E", -- 
84 =>	x"D9", -- mov		r2,r1		
85 =>	x"34", -- loadimm	r1,1
86 =>	x"01", -- 
87 =>	x"00", -- NOP
88 =>	x"00", -- NOP
89 =>	x"00", -- NOP
90 =>	x"00", -- NOP
91 =>	x"00", -- NOP
92 =>	x"51", -- sub		r0,r1
93 =>	x"00", -- NOP
94 =>	x"00", -- NOP
95 =>	x"00", -- NOP
96 =>	x"00", -- NOP
97 =>	x"00", -- NOP
98 =>	x"20", -- store		r0,counter
99 =>	x"0E", -- 
100 =>	x"D6", -- mov		r1,r2	
101 =>	x"38", -- loadimm		r2,out:
102 =>	x"76", -- 
103 =>	x"00", -- NOP
104 =>	x"00", -- NOP
105 =>	x"00", -- NOP
106 =>	x"D3", -- mov		r0,r3	
107 =>	x"00", -- NOP
108 =>	x"00", -- NOP
109 =>	x"9A", -- brn		out
110 =>	x"38", -- loadimm		r2,loop
111 =>	x"1D", -- 
112 =>	x"00", -- NOP
113 =>	x"00", -- NOP
114 =>	x"00", -- NOP
115 =>	x"00", -- NOP
116 =>	x"00", -- NOP
117 =>	x"92", -- br		loop
118 =>	x"38", -- loadimm		r2,start     #out#
119 =>	x"02", -- 
120 =>	x"00", -- NOP
121 =>	x"00", -- NOP
122 =>	x"00", -- NOP
123 =>	x"00", -- NOP
124 =>	x"00", -- NOP
125 =>	x"92", -- br		start
126 =>	x"00", -- NOP
127 =>	x"00" -- NOP
);
begin
p1:    process (clk)
    variable add_in : integer := 0;
    begin
        if rising_edge(clk) then
            add_in := conv_integer(unsigned(addr));
            data <= rom_content(add_in);
        end if;
    end process;
end BHV;
