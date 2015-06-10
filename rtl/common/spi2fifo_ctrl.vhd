library ieee;
use ieee.std_logic_1164.all;

entity spi2fifo_ctrl is
generic (
    WIDTH : integer := 8 
);
port (
    clk           : in  std_logic                          ;
    reset         : in  std_logic                          ;

    spi_done_tick : in  std_logic                          ;
    spi_dout      : in  std_logic_vector(WIDTH-1 downto 0) ;

    fifo_full     : in  std_logic                          ;
    fifo_wr_en    : out std_logic                          ;
    fifo_din      : out std_logic_vector(WIDTH-1 downto 0) ;

    -- status register signal
   e_fifo_full    : out std_logic                            
);
end spi2fifo_ctrl;

architecture arch of spi2fifo_ctrl is
signal spi_done_tick_ff1  : std_logic                          ;
signal spi_done_tick_ff2  : std_logic                          ;
signal spi_done_tick_ff3  : std_logic                          ;
signal spi_done_tick_trig : std_logic                          ;
signal spi_dout_ff1       : std_logic_vector(WIDTH-1 downto 0) ;
signal spi_dout_ff2       : std_logic_vector(WIDTH-1 downto 0) ;

begin

process(clk, reset)
begin
    if(reset = '1') then
        spi_done_tick_ff1 <= '0';
        spi_done_tick_ff2 <= '0';
        spi_done_tick_ff3 <= '0';

        spi_dout_ff1 <= (others => '0');
        spi_dout_ff2 <= (others => '0');
    elsif(rising_edge(clk)) then
        spi_done_tick_ff1 <= spi_done_tick;
        spi_done_tick_ff2 <= spi_done_tick_ff1;
        spi_done_tick_ff3 <= spi_done_tick_ff2;

        spi_dout_ff1 <= spi_dout;
        spi_dout_ff2 <= spi_dout_ff1;
    end if;
end process;

spi_done_tick_trig <= spi_done_tick_ff2 and (not spi_done_tick_ff3);

process(clk, reset)
begin
    if(reset = '1') then
        fifo_wr_en <= '0';
        fifo_din <= (others => '0');
    elsif(rising_edge(clk)) then
        if(spi_done_tick_trig = '1' and fifo_full = '0') then
            fifo_wr_en <= '1';
            fifo_din <= spi_dout_ff2;
        else
            fifo_wr_en <= '0';
            fifo_din <= (others => '0');
        end if;
    end if;
end process;

-- TODO: generate error when fifo full
process(clk, reset)
begin
    if(reset = '1') then
        e_fifo_full <= '0';
    elsif(rising_edge(clk)) then
        if(spi_done_tick_trig = '1' and fifo_full = '1') then
            e_fifo_full <= '1';
        else
            e_fifo_full <= '0';
        end if;
    end if;
end process;

end arch;

