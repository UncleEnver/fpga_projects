library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Οντότητα Testbench
entity alu_tb is
end entity alu_tb;

architecture tb_architecture of alu_tb is

    -- Δήλωση Component ALU (Πρέπει να ταιριάζει με την entity alu)
    component alu
        generic  ( n  : integer := 8);
        port ( ac      :  in  std_logic_vector(n-1 downto 0);
               db      :  in  std_logic_vector(n-1 downto 0);
               alus    :  in  std_logic_vector(7 downto 1);
               dout    :  out std_logic_vector(n-1 downto 0)
        );
    end component;

    -- Σταθερές Εισόδου Δεδομένων (8-bit)
    constant AC_FIXED : std_logic_vector(7 downto 0) := "01001001"; -- 73 (Hex: 49)
    constant DB_FIXED : std_logic_vector(7 downto 0) := "10011001"; -- 153 (Hex: 99)
    
    -- Σήματα για τη σύνδεση με το DUT
    signal ALUS_stim : std_logic_vector(7 downto 1) := (others => '0');
    signal DOUT_result : std_logic_vector(7 downto 0);

    constant Delay : time := 100 ns;

begin

    -- Ενσωμάτωση του DUT (ALU)
    DUT: alu
        port map (
            ac   => AC_FIXED,
            db   => DB_FIXED,
            alus => ALUS_stim,
            dout => DOUT_result
        );

    -- Διαδικασία Διέγερσης (Stimulus Process)
    stimulus: process
    begin
        -- Ελέγχουμε τις λειτουργίες σύμφωνα με τον Πίνακα 1

        -- 1. AND (01001001 AND 10011001 = 00001001)
        ALUS_stim <= "1000000"; -- ALUS7=1, ALUS6=0, ALUS5=0, ALUS4=0 (Logic=10000, AND)
        wait for Delay; 

        -- 2. OR (01001001 OR 10011001 = 11011001)
        ALUS_stim <= "1100000"; 
        wait for Delay; 

        -- 3. XOR (01001001 XOR 10011001 = 11010000)
        ALUS_stim <= "1010000";
        wait for Delay; 

        -- 4. NOT (NOT 01001001 = 10110110)
        ALUS_stim <= "1110000";
        wait for Delay; 
        
        -- 5. CLAC (Clear AC: Result = 00000000)
        ALUS_stim <= "0000000"; 
        wait for Delay; 
        
        -- 6. ADD (73 + 153 = 226 => 11100010)
        ALUS_stim <= "0000101"; 
        wait for Delay; 

        -- 7. SUB (73 - 153 = -80. Συμπλήρωμα ως προς 2 του 153. Result = 10110000)
        ALUS_stim <= "0001011"; 
        wait for Delay; 

        -- 8. MOVR (Move DB to AC -> Result = 10011001)
        ALUS_stim <= "0000100"; 
        wait for Delay; 
        
        -- ΣΗΜΕΙΩΣΗ: Οι τιμές ALUS για INAC και LDAC 5 αφορούν τον AC και δεν ελέγχονται μόνο από την ALU.
        
        wait;
    end process stimulus;

end architecture tb_architecture;