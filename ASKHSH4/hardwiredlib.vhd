LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

PACKAGE hardwiredlib IS


    COMPONENT decoder4to16 IS
        PORT (
            Din : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            Dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;


    COMPONENT counter3bit IS
        PORT (
            clock : IN STD_LOGIC;
            rst   : IN STD_LOGIC;
            inc   : IN STD_LOGIC;
            count : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;


    COMPONENT decoder3to8 IS
        PORT (
            Din : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            Dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

END hardwiredlib;

PACKAGE BODY hardwiredlib IS

END hardwiredlib;