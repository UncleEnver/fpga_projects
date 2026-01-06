LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg1 IS
    PORT(
        clk, rst, ld : IN STD_LOGIC;
        d : IN STD_LOGIC;
        q : OUT STD_LOGIC
    );
END reg1;

ARCHITECTURE behavioral OF reg1 IS
    SIGNAL temp : STD_LOGIC;
BEGIN
    PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            temp <= '0';
        ELSIF rising_edge(clk) THEN
            IF ld = '1' THEN
                temp <= d;
            END IF;
        END IF;
    END PROCESS;
    q <= temp;
END behavioral;
