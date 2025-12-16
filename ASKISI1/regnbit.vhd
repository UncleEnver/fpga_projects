LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY regnbit IS

GENERIC(n: INTEGER:=8);

PORT(din: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
clk,rst,ld: IN STD_LOGIC;
inc: IN STD_LOGIC;
dout: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0));

END regnbit;

ARCHITECTURE arc OF regnbit IS

SIGNAL temp: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
BEGIN

PROCESS(clk,rst)

BEGIN
 IF rst='0' THEN
 temp<=(others=>'0');
 
 ELSIF rising_edge(clk) THEN
 
 IF ld='1' THEN
 temp<=din;
 
 ELSIF inc='1' THEN
 temp<=temp+1;
 
 END IF;
END IF;
END PROCESS;

dout<=temp;
END;

 
