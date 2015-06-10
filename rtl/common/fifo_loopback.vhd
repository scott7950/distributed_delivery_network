library ieee;
use ieee.std_logic_1164.all;

entity fifo_loopback is
generic (
    WIDTH : integer := 8 
);
port (
    clk              : in std_logic ;
    reset            : in std_logic ;

    -- fifo interface to read fifo
    fifo_empty       : in  std_logic ;
    fifo_rd_en       : out std_logic ;
    fifo_dout        : in  std_logic_vector(WIDTH-1 downto 0) ;

    -- fifo interface needed to connect read fifo
    fifo_empty_ext   : out std_logic ;
    fifo_rd_en_ext   : in  std_logic ;
    fifo_dout_ext    : out std_logic_vector(WIDTH-1 downto 0) ;

    -- fifo interface to write fifo
    fifo_full        : in  std_logic ;
    fifo_wr_en       : out std_logic ;
    fifo_din         : out std_logic_vector(WIDTH-1 downto 0) ;

    -- fifo interface needed to connect write fifo
    fifo_full_ext    : out std_logic ;
    fifo_wr_en_ext   : in  std_logic ;
    fifo_din_ext     : in  std_logic_vector(WIDTH-1 downto 0) ;

    fifo_loopback_en : in std_logic
);
end fifo_loopback;

architecture arch of fifo_loopback is
type loopback_state_type is (idle, readFifo, writeFifo);

signal loopback_state_reg, loopback_state_next: loopback_state_type;
signal loopback_fifo_rd_en : std_logic;
signal loopback_fifo_wr_en : std_logic;

begin
-- uart2spi fifo loop back to spi2uart fifo
process(clk, reset) 
begin
    if(reset = '1') then
        loopback_state_reg <= idle;
    elsif(rising_edge(clk)) then
        loopback_state_reg <= loopback_state_next;
    end if;
end process;

process(loopback_state_reg, fifo_loopback_en, fifo_empty, fifo_full) 
begin
    loopback_state_next <= loopback_state_reg;
    loopback_fifo_rd_en <= '0';
    loopback_fifo_wr_en <= '0';

    case(loopback_state_reg) is
        when idle =>
            if(fifo_loopback_en = '1' and fifo_empty = '0') then
                loopback_state_next <= readFifo;
            end if;
        when readFifo =>
            if(fifo_empty = '0') then
                loopback_fifo_rd_en <= '1';
                loopback_state_next <= writeFifo;
            else
                loopback_state_next <= idle;
            end if;
        when writeFifo =>
            if(fifo_full = '0') then
                loopback_fifo_wr_en <= '1';
                loopback_state_next <= readFifo;
            else
                loopback_state_next <= idle;
            end if;
    end case;
end process;


fifo_din <= fifo_dout when fifo_loopback_en = '1' else fifo_din_ext;
fifo_rd_en <= loopback_fifo_rd_en when fifo_loopback_en = '1' else fifo_rd_en_ext;
fifo_wr_en <= loopback_fifo_wr_en when fifo_loopback_en = '1' else fifo_wr_en_ext;

fifo_dout_ext <= fifo_dout when fifo_loopback_en = '0' else (others => '0');
fifo_empty_ext <= fifo_empty when fifo_loopback_en = '0' else '1';  
fifo_full_ext <= fifo_full when fifo_loopback_en = '0' else '1';

end arch;

