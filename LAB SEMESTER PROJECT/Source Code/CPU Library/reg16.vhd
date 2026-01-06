LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY reg16 IS
    PORT(
        clk, rst, ld, inc : IN STD_LOGIC;
        d : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END reg16;

ARCHITECTURE rtl OF reg16 IS
    SIGNAL temp : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
    PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            temp <= (others => '0'); -- Asynchronous Reset
        ELSIF rising_edge(clk) THEN
            IF ld = '1' THEN
                temp <= d;
            ELSIF inc = '1' THEN
                temp <= temp + 1;
            END IF;
        END IF;
    END PROCESS;
    q <= temp;
END rtl;
