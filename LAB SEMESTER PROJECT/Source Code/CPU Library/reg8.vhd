LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY reg8 IS
    PORT(
        clk, rst, ld, inc, clr : IN STD_LOGIC; -- Added clr for ACZERO
        d : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END reg8;

ARCHITECTURE rtl OF reg8 IS
    SIGNAL temp : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
    PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            temp <= (others => '0');
        ELSIF rising_edge(clk) THEN
            IF clr = '1' THEN        -- Synchronous Clear (for ACZERO)
                temp <= (others => '0');
            ELSIF ld = '1' THEN
                temp <= d;
            ELSIF inc = '1' THEN
                temp <= temp + 1;
            END IF;
        END IF;
    END PROCESS;
    q <= temp;
END rtl;
