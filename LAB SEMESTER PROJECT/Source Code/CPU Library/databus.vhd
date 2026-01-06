-- Added: Register B input and control signals
-- Expanded: 6-way mux to 7-way mux for Register B support

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY databus IS
    PORT (
        -- Inputs from registers
        PCIN   : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- PC is 16-bit
        DRIN   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        TRIN   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        RIN    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        ACIN   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        BIN    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- NEW FOR A6: Register B input
        MEMIN  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

        -- Control signals
        PCBUS  : IN STD_LOGIC;
        DRBUS  : IN STD_LOGIC;
        TRBUS  : IN STD_LOGIC;
        RBUS   : IN STD_LOGIC;
        ACBUS  : IN STD_LOGIC;
        BBUS   : IN STD_LOGIC;  -- NEW FOR A6: Register B to bus control
        MEMBUS : IN STD_LOGIC;

        -- Output (Internal Data Bus)
        BUSOUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END databus;

ARCHITECTURE rtl OF databus IS
BEGIN
    -- Priority Mux behavior (Order doesn't matter if control unit ensures mutex)
    -- Selects one of 7 register sources (expanded from A5's 6 sources for Register B)
    BUSOUT <= PCIN(7 downto 0) WHEN PCBUS = '1' ELSE -- Only lower 8 bits of PC
              DRIN             WHEN DRBUS = '1' ELSE
              TRIN             WHEN TRBUS = '1' ELSE
              RIN              WHEN RBUS  = '1' ELSE
              ACIN             WHEN ACBUS = '1' ELSE
              BIN              WHEN BBUS  = '1' ELSE  -- NEW FOR A6: Register B
              MEMIN            WHEN MEMBUS= '1' ELSE
              (others => '0'); -- Default case
END rtl;