library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- clk is 100MHz
entity spi_clk_gen is
generic(
    N: integer := 1 ;
    M: integer := 1  
);

port (
    clk      : in  std_logic ;
    reset    : in  std_logic ;
    spi_clk  : out std_logic ;
    max_tick : out std_logic  
);
end spi_clk_gen;

architecture arch of spi_clk_gen is
signal r_reg: unsigned(N-1 downto 0);
signal r_next: unsigned(N-1 downto 0);

begin

process(clk, reset)
begin
    if (reset = '1') then
        r_reg <= (others => '0');
    elsif (clk'event and clk='1') then
        r_reg <= r_next;
    end if;
end process;

-- next state logic
r_next <= (others => '0') when r_reg=M else
          r_reg + 1;

-- output logic
spi_clk  <= r_reg(N-1);
max_tick <= '1' when r_reg=M else '0';

end arch;

