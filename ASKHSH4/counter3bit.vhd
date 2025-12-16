LIBRARY ieee;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;


ENTITY counter3bit IS
    PORT (
        clock : IN STD_LOGIC;  -- clock
        rst   : IN STD_LOGIC;  -- reset  
        inc   : IN STD_LOGIC;  -- increment
        count : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END counter3bit;


ARCHITECTURE behavioral OF counter3bit IS

    SIGNAL count_temp : unsigned(2 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS(clock, rst)
    BEGIN
        IF rst = '1' THEN

            count_temp <= (OTHERS => '0');

        ELSIF rising_edge(clock) THEN

            IF inc = '1' THEN

                count_temp <= count_temp + 1;
            END IF;
        END IF;
    END PROCESS;

    count <= STD_LOGIC_VECTOR(count_temp);

END behavioral;