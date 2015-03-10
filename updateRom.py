# Opens a file of instructions called ins.txt and writes the binary equivalent to ROM
from re import split
from os import rename
# File names
textInstructions = 'ins.txt'
tempOutputFile = 'imemcopy.vhd'
finalOutputFile = 'imem.vhd'
# Dict of assembly instructions and their binary equivalents
insToBin = {'NOP': '00000000',
			'ADD': '0100',
			'SUB': '0101',
			'SHL': '0110',
			'SHR': '0111',
			'NAND':'1000',
			'IN' : '1011',
			'OUT': '1100',
			'MOV': '1101',
			'BR' : '100100',
			'BR.Z':'100101',
			'BR.N':'100110',
			'BR.SUB':'100111',
			'RETURN':'11100000',
			'R0' : '00',
			'R1' : '01',
			'R2' : '10',
			'R3' : '11',
}

# Start of imem file
imem = "library IEEE;\nuse IEEE.std_logic_1164.all;\nuse IEEE.std_logic_ARITH.all;\n\nentity imem is\n    port(\n        clk      : in  std_ulogic;\n        addr     : in  std_ulogic_vector (6 downto 0);\n        data     : out std_ulogic_vector (7 downto 0)\n        );\nend imem;\narchitecture BHV of imem is\n    type ROM_TYPE is array (0 to 127) of std_ulogic_vector (7 downto 0);\n    constant rom_content : ROM_TYPE := (\n"
# End of imem file
imemEnd = "begin\np1:    process (clk)\n    variable add_in : integer := 0;\n    begin\n        if rising_edge(clk) then\n            add_in := conv_integer(unsigned(addr));\n            data <= rom_content(add_in);\n        end if;\n    end process;\nend BHV;"

# Read in lines into list, remove newlines
txtIns = []
txtIns = [line.strip() for line in open(textInstructions)]
binIns = []
tmpIns = ''
pad = False
for line in txtIns:
	# Split line at space or comma
	splitIns = split(' |, ', line)
	# Convert to binary
	tmpIns = ''
	for i in splitIns:
		tmpIns += insToBin[i]
		if i == 'IN' or i == 'OUT':
			pad = True
	if pad:
		tmpIns += '00'
		pad = False
	binIns.append('"'+tmpIns+'",    --'+line+'\n')
# Open file to write to
for i in binIns:
	imem = imem + i
for i in range(0,127-len(binIns)):
	imem += '"' + insToBin['NOP'] + '",\n'
imem += '"' + insToBin['NOP'] + '");\n'
imem += imemEnd
# Write to temporary file
f = open(tempOutputFile,'w')
f.write(imem)
f.close()
# Check to see if there were too any instructions in the input file
if (len(binIns) < 129):
	rename(tempOutputFile, finalOutputFile)
	print("Write successful! Renamed imemcopy.vhd to imem.vhd.")
else:
	print('Too many instructions in ins.txt. Result still written to imemcopy.vhd')


				
