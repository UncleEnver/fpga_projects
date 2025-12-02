LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE mseqlib IS

-- ΔΙΟΡΘΩΜΕΝΟ regnbit Component (Ταιριάζει με Entity regnbit)
COMPONENT regnbit IS
PORT(
    din : IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- din αντί για D (για Data Input)
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    ld  : IN STD_LOGIC;
    inc : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(5 DOWNTO 0) -- dout αντί για q (για Data Output)
);
END COMPONENT;

-- ΔΙΟΡΘΩΜΕΝΟ mux4to1 Component (Ταιριάζει με Entity mux4to1)
COMPONENT mux4to1 IS 
PORT( 
    I0, I1, I2, I3 : IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- I0-I3 αντί για A-D
    S              : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- S αντί για sel
    Y              : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
);
END COMPONENT;

-- ΔΙΟΡΘΩΜΕΝΟ mseq_rom Component (Ταιριάζει με Entity mseq_rom)
COMPONENT mseq_rom IS
PORT( 
    clock   : IN STD_LOGIC;                 -- clock αντί για clk
    address : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    q       : OUT STD_LOGIC_VECTOR(35 DOWNTO 0)
);
END COMPONENT;

END PACKAGE mseqlib;

PACKAGE BODY mseqlib IS
END PACKAGE BODY mseqlib;