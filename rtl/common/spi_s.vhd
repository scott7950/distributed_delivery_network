library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_s is
generic (
    WIDTH : integer := 8 
);
port (
    reset         : in  std_logic                          ;

    -- spi slave interface
    sck           : in  std_logic                          ;
    mosi          : in  std_logic                          ;
    miso          : out std_logic                          ;
    ss            : in  std_logic                          ;

    -- spi to fifo interface
    spi_done_tick : out std_logic                          ;
    spi_dout      : out std_logic_vector(WIDTH-1 downto 0)  
);
end spi_s;

architecture arch of spi_s is
type state_type is (idle, readSPI, readFirstBit);

signal state_reg, state_next     : state_type                         ;
signal spi_cnt_reg, spi_cnt_next : unsigned(3 downto 0)               ;
signal data_reg, data_next       : std_logic_vector(WIDTH-1 downto 0) ;
signal spi_done_tick_reg, spi_done_tick_next : std_logic              ;

begin

-- output
spi_done_tick <= spi_done_tick_reg;
process(sck, reset)
begin
    if(reset = '1') then
        spi_dout <= (others => '0');
    elsif(rising_edge(sck)) then
        spi_dout <= data_reg;
    end if;
end process;

process(sck, reset)
begin
    if(reset = '1') then
        state_reg <= idle;
        spi_cnt_reg <= (others => '0');
        data_reg <= (others => '0');
        spi_done_tick_reg <= '0';
    elsif(rising_edge(sck)) then
        state_reg <= state_next;
        spi_cnt_reg <= spi_cnt_next;
        data_reg <= data_next;
        spi_done_tick_reg <= spi_done_tick_next;
    end if;
end process;

process(state_reg, spi_cnt_reg, data_reg, ss, mosi)
begin
    state_next <= state_reg;
    spi_cnt_next <= spi_cnt_reg;
    data_next <= data_reg;
    spi_done_tick_next <= '0';

    case state_reg is
        when idle =>
            if(ss = '0') then
                data_next <= data_reg(6 downto 0) & mosi;
                spi_cnt_next <= (others => '0');

                state_next <= readSPI;
            end if;
        when readSPI =>
            if(ss = '0') then
                data_next <= data_reg(6 downto 0) & mosi;

                if(spi_cnt_reg = 6) then
                    state_next <= readFirstBit;
                end if;
            else
                data_next <= (others => '0');
                state_next <= idle;
            end if;
            spi_cnt_next <= spi_cnt_reg + 1;
        when readFirstBit =>
            if(ss = '0') then
                data_next <= data_reg(6 downto 0) & mosi;
                spi_cnt_next <= (others => '0');

                state_next <= readSPI;
            else
                data_next <= (others => '0');
                state_next <= idle;
            end if;
            spi_done_tick_next <= '1';
    end case;
end process;

end arch;

