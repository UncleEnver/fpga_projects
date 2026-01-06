library ieee;
use ieee.std_logic_1164.all;

package hardwiredlib is

	component decoder_generic is 
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
	end component;
	
	component counter_3bit is
		port(
			-- Input(s)
			clk : in std_logic;
			rst : in std_logic;
			inc : in std_logic;
			
			-- Output(s)
			count : out std_logic_vector(2 downto 0)
		);
	end component;
	
end package hardwiredlib;