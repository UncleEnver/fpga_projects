LIBRARY ieee;
USE IEEE.std_logic_1164.all;

-- Ορισμός της οντότητας (Entity)
ENTITY decoder4to16 IS
    PORT (
        Din : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);  -- Είσοδος 4-bit (0 έως 15)
        Dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- Έξοδος 16-bit
    );
END decoder4to16;

-- Αρχιτεκτονική (Architecture)
ARCHITECTURE behavioral OF decoder4to16 IS
BEGIN
    PROCESS(Din)
        -- Χρησιμοποιούμε μια μεταβλητή για την είσοδο μέσα στη διεργασία
        VARIABLE input: STD_LOGIC_VECTOR(3 DOWNTO 0);
    BEGIN
        input := Din;

        -- Η δομή CASE επιλέγει μία έξοδο 16-bit με '1',
        -- ανάλογα με τη τιμή εισόδου 4-bit.
        CASE input IS
            WHEN "0000" => Dout <= "0000000000000001"; -- 0
            WHEN "0001" => Dout <= "0000000000000010"; -- 1
            WHEN "0010" => Dout <= "0000000000000100"; -- 2
            WHEN "0011" => Dout <= "0000000000001000"; -- 3
            WHEN "0100" => Dout <= "0000000000010000"; -- 4
            WHEN "0101" => Dout <= "0000000000100000"; -- 5
            WHEN "0110" => Dout <= "0000000001000000"; -- 6
            WHEN "0111" => Dout <= "0000000010000000"; -- 7
            WHEN "1000" => Dout <= "0000000100000000"; -- 8
            WHEN "1001" => Dout <= "0000001000000000"; -- 9
            WHEN "1010" => Dout <= "0000010000000000"; -- 10 (A)
            WHEN "1011" => Dout <= "0000100000000000"; -- 11 (B)
            WHEN "1100" => Dout <= "0001000000000000"; -- 12 (C)
            WHEN "1101" => Dout <= "0010000000000000"; -- 13 (D)
            WHEN "1110" => Dout <= "0100000000000000"; -- 14 (E)
            WHEN OTHERS => Dout <= "1000000000000000"; -- 15 (F)
        END CASE;
    END PROCESS;
END behavioral;