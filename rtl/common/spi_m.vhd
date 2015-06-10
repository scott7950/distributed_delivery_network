library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_m is
generic (
    WIDTH : integer := 8 
);
port (
    clk        : in  std_logic                          ;
    reset      : in  std_logic                          ;

    -- fifo interface
    fifo_empty : in  std_logic                          ;
    fifo_dout  : in  std_logic_vector(WIDTH-1 downto 0) ;
    fifo_rd_en : out std_logic                          ;

    -- spi master interface
    sck        : out std_logic                          ;
    mosi       : out std_logic                          ;
    miso       : in  std_logic                          ;
    ss         : out std_logic                           
);
end spi_m;

architecture arch of spi_m is
component spi_clk_gen is
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
end component;

type state_type is (idle, writeSPI, readFifoWriteSPI, stop);

signal state_reg, state_next     : state_type                         ;
signal spi_cnt_reg, spi_cnt_next : unsigned(3 downto 0)               ;
signal data_reg, data_next       : std_logic_vector(WIDTH-1 downto 0) ;
signal ss_reg, ss_next           : std_logic                          ;

signal s_tick                    : std_logic                          ;

begin

--generate sck
u_spi_clk_gen: spi_clk_gen generic map (
    N => 2 ,
    M => 3  
) port map (
    clk      => clk      ,
    reset    => reset    ,
    spi_clk  => sck      ,
    max_tick => s_tick    
);

-- spi output
mosi <= data_reg(7);
ss   <= ss_reg;

process(clk, reset)
begin
    if(reset = '1') then
        state_reg <= idle;
        spi_cnt_reg <= (others => '0');
        data_reg <= (others => '0');
        ss_reg <= '1';
    elsif(rising_edge(clk)) then
        state_reg <= state_next;
        spi_cnt_reg <= spi_cnt_next;
        data_reg <= data_next;
        ss_reg <= ss_next;
    end if;
end process;

process(state_reg, spi_cnt_reg, data_reg, fifo_empty, fifo_dout, ss_reg, s_tick)
begin
    state_next <= state_reg;
    spi_cnt_next <= spi_cnt_reg;
    data_next <= data_reg;
    ss_next <= ss_reg;
    fifo_rd_en <= '0';

    case state_reg is
        when idle =>
            ss_next <= '1';
            if(fifo_empty = '0') then
                fifo_rd_en <= '1';
                spi_cnt_next <= (others => '0');
                state_next <= writeSPI;
            end if;
        when writeSPI =>
            if(s_tick = '1') then
                if(spi_cnt_reg = 0) then
                    data_next <= fifo_dout;
                else
                    data_next <= data_reg(6 downto 0) & '0';
                end if;
                ss_next <= '0';
                spi_cnt_next <= spi_cnt_reg + 1;
                if(spi_cnt_reg = 6) then
                    state_next <= readFifoWriteSPI;
                end if;
            end if;
        when readFifoWriteSPI =>
            if(s_tick = '1') then
                data_next <= data_reg(6 downto 0) & '0';
                ss_next <= '0';
                spi_cnt_next <= (others => '0');
                if(fifo_empty = '0') then
                    fifo_rd_en <= '1';
                end if;
                if(fifo_empty = '0') then
                    state_next <= writeSPI;
                else
                    state_next <= stop;
                end if;
            end if;
        when stop =>
            if(s_tick = '1') then
                ss_next <= '0';
                state_next <= idle;
            end if;
    end case;
end process;

end arch;

