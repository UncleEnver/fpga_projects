LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
LIBRARY lpm;
USE lpm.lpm_components.all;
USE work.mseqlib.all; 

ENTITY mseq IS

PORT(ir : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
clk, reset: IN STD_LOGIC;
Z : IN STD_LOGIC;
code : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
mOPs : OUT STD_LOGIC_VECTOR(26 DOWNTO 0));
			
END mseq;

ARCHITECTURE arc OF mseq IS

    
-- σήματα για τον microsequencer
SIGNAL current_addr_reg, next_addr_mux, mapped_addr: STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL current_addr_inc: STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL next_addr_sel: STD_LOGIC_VECTOR(5 DOWNTO 0);
    

SIGNAL microcode_out: STD_LOGIC_VECTOR(35 DOWNTO 0);-- σήμα εξόδου μνήμης
    

SIGNAL sel_field: STD_LOGIC_VECTOR(2 DOWNTO 0);    -- SEL bits 35-33
SIGNAL cond_bt_field: STD_LOGIC_VECTOR(1 DOWNTO 0); -- Cond. BT bits 32-31
SIGNAL uops_field: STD_LOGIC_VECTOR(26 DOWNTO 0);  -- μOPs bits 30-4
SIGNAL addr_field: STD_LOGIC_VECTOR(5 DOWNTO 0);   -- ADDR bits 5-0
    

SIGNAL input_Z: std_logic_vector(5 DOWNTO 0);
SIGNAL input_Z_prime: STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL input_1: STD_LOGIC_VECTOR(5 DOWNTO 0) := "000001";
SIGNAL input_0: STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
    
BEGIN

input_Z     <= "00000" & Z;
input_Z_prime <= "00000" & (not Z);
    

sel_field <= microcode_out(35 DOWNTO 33);
cond_bt_field <= microcode_out(32 DOWNTO 31);
uops_field <= microcode_out(30 DOWNTO 4);
addr_field <= microcode_out(5 DOWNTO 0);
    
--κλήση της rom του microsequencer
rom_inst: mseq_rom 
PORT MAP (
address => current_addr_reg,
clock => clk, 
q => microcode_out
);
        
--κλήση του καταχωρητή που έχουμε φτιάξει
reg_inst: regnbit 
PORT MAP (
din => next_addr_mux, 
clk => clk, 
rst => reset,
ld => '1',           
inc => '0',        
dout => current_addr_reg 
);
        

current_addr_inc <= current_addr_reg + 1;
    

mapped_addr <= ir & "00"; 
    
--κλήση του πολυπλέκτη
mux4to1_inst: mux4to1
PORT MAP (
S  => cond_bt_field,
I0 => input_1,     
I1 => input_Z,        
I2 => input_Z_prime,  
I3 => input_0,        
Y  => next_addr_sel
);


WITH sel_field SELECT
next_addr_mux <= addr_field WHEN "000",
mapped_addr WHEN "001", 
next_addr_sel WHEN "010",
current_addr_inc WHEN OTHERS;


code <= microcode_out;
mOPs <= uops_field;
    
END arc;
