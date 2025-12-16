LIBRARY ieee;
USE IEEE.std_logic_1164.all;


ENTITY decoder3to8 IS
PORT ( Din : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
Dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));

END decoder3to8;

ARCHITECTURE behavioral OF decoder3to8 IS

BEGIN
PROCESS(Din)
VARIABLE input: STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN
input:= Din;

CASE input IS
                WHEN "000"=>Dout<="00000001";
                WHEN "001"=>Dout<="00000010";
                WHEN "010"=>Dout<="00000100";
                WHEN "011"=>Dout<="00001000";
               WHEN "100"=>Dout<="00010000";
               WHEN "101"=>Dout<="00100000";
 WHEN "110"=>Dout<="01000000";
              WHEN OTHERS=>Dout<="10000000";
       END CASE;
END PROCESS;
END behavioral;
