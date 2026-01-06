library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_3bit is
	port(
	
		-- Input(s)
		clk : in std_logic;
		rst : in std_logic;
		inc : in std_logic;
		
		-- Output(s)
		count : out std_logic_vector(2 downto 0)
	);
end entity;

architecture  rtl  of counter_3bit is

	signal temp : unsigned(2 downto 0);
	
begin

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				temp <= (others => '0');
			elsif inc = '1' then
				temp <= temp + 1;
			end if;
		end if;
	end process;
	
	count <= std_logic_vector(temp); -- Converting the unsigned temp to std_logic_vector
	
end architecture;