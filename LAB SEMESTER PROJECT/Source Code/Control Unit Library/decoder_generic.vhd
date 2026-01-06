--===========================================
-- GENERIC DECODER.
-- Example for declaring a 4x16 decoder:
--
-- i_Decoder4to16 : entity work.decoder_generic(rtl)
--    generic map(
--        INPUT_WIDTH  => 4,
--        OUTPUT_WIDTH => 16
--    )
--    port map(
--        din  => din,
--        dout => dout
--    );
--===========================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder_generic is
	generic(
		INPUT_WIDTH  : integer; -- Number of input bits
		OUTPUT_WIDTH : integer  -- Number of output bits (2^{input_width})
	);
	port(
		-- Input(s)
		din  : in std_logic_vector(INPUT_WIDTH-1 downto 0);
		
		-- Output(s)
		dout : out std_logic_vector(OUTPUT_WIDTH-1 downto 0)
	);
end entity;

architecture rtl of decoder_generic is
begin

	process(din)
	begin
		
		-- Default: all outputs 0
		dout <= (others => '0');

		-- Activate one output based on ir value
		dout(to_integer(unsigned(din))) <= '1';
	end process;
end architecture;