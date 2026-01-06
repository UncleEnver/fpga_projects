library ieee ;
use ieee.std_logic_1164.all ;

entity alus IS
port(rbus,acload,zload,andop        : in std_logic;
          orop,notop,xorop,aczero        : in std_logic;
          acinc,plus,minus,drbus           : in std_logic;
          alus                                                : out std_logic_vector(6 downto 0));
end alus ;

architecture arc of alus is
signal control : std_logic_vector(11 downto 0);
begin
    -- bit 11: rbus
    -- bit 10: drbus
    -- bit 9: acload
    -- bit 8: zload
    -- bit 7: andop
    -- bit 6: orop
    -- bit 5: notop
    -- bit 4: xorop
    -- bit 3: aczero
    -- bit 2: acinc
    -- bit 1: plus
    -- bit 0: minus
    
    control <= rbus & drbus & acload & zload & andop & orop
                    & notop & xorop & aczero & acinc & plus & minus ;
    process(control)
    begin
        case control is
            -- Logic Operations (AND, OR, XOR, NOT)
            WHEN "101110000000" => alus <= "1000000" ; -- AND
            WHEN "101101000000" => alus <= "1100000" ; -- OR
            WHEN "101100010000" => alus <= "1010000" ; -- XOR
            WHEN "001100100000" => alus <= "1110000" ; -- NOT
            
            -- AC Direct Operations (CLAC, INAC)
            WHEN "001100001000" => alus <= "0000000" ; -- CLAC (AC <- 0)
            WHEN "001100000100" => alus <= "0001001" ; -- INAC (AC <- AC + 1)
            
            -- ADD/SUB with DR (drbus='1', uses DRdata as operand)
            WHEN "101100000010" => alus <= "0000101" ; -- ADD (AC <- AC + DR)
            WHEN "101100000001" => alus <= "0001011" ; -- SUB (AC <- AC - DR)
            
            -- MOVR (Move R to AC)
            WHEN "101100000000" => alus <= "0000100" ; -- MOVR (AC <- R)
            
            -- LDAC completion (AC loads from DataBus, not ALU)
            WHEN "011100000000" => alus <= "0000100" ; -- LDAC5 (AC <- DataBus via multiplexer)
            
            -- FIXED: ADDB/SUBB with DR (drbus='1', uses DRdata which contains B)
            -- Control pattern: rbus=0, drbus=1, acload=1, zload=1, plus=1, minus=0
            WHEN "001101000010" => alus <= "0000101" ; -- ADDB (AC <- AC + DR where DR=B)
            
            -- Control pattern: rbus=0, drbus=1, acload=1, zload=1, plus=0, minus=1
            WHEN "001101000001" => alus <= "0001011" ; -- SUBB (AC <- AC - DR where DR=B)

            -- Default case (NO-OP or invalid)
            WHEN others => alus <= "1111111" ; 
        end case;
    end process;
end arc ;
