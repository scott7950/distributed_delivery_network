library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo2uart_ctrl is
generic (
    WIDTH   : integer := 8 ;
    SPI_NUM : integer := 4 
);
port (
    clk                : in  std_logic                            ;
    reset              : in  std_logic                            ;

    -- interface with fifo2fifo
    tx_fsm_start       : in  std_logic                            ;
    tx_fsm_busy        : out std_logic                            ;
    tx_fsm_access_fifo : in  std_logic                            ;

    -- interface with reg
    reg_dout           : in  std_logic_vector(7 downto 0)         ;
   
    -- interface with uart
    tx_done_tick       : in  std_logic                            ;
    tx_start           : out std_logic                            ;
    uart_tx_din        : out std_logic_vector(WIDTH-1 downto 0)   ;

    -- interface with fifo
    fifo_empty         : in std_logic                             ;

    fifo_dout          : in  std_logic_vector(WIDTH-1 downto 0)   ;
    fifo_rd_en         : out std_logic                            ;

    spi2uart_fifo_sel  : out std_logic_vector(SPI_NUM-1 downto 0)  

);
end fifo2uart_ctrl;

architecture arch of fifo2uart_ctrl is
type tx_state_type is (idle, readReg, checkFifo, readFifo, waitTxDone) ;

signal tx_state_reg, tx_state_next : tx_state_type                        ;
signal tx_cnt_reg, tx_cnt_next     : unsigned(0 downto 0)                 ;
signal spi2uart_fifo_sel_reg       : std_logic_vector(SPI_NUM downto 0) ;
signal spi2uart_fifo_sel_next      : std_logic_vector(SPI_NUM downto 0) ;
signal fifo_en_reg, fifo_en_next   : std_logic;

begin

spi2uart_fifo_sel <= spi2uart_fifo_sel_reg(SPI_NUM-1 downto 0);

process(clk, reset)
begin
    if(reset = '1') then
        tx_state_reg <= idle;
        tx_cnt_reg <= (others => '0');
        -- spi2uart_fifo_sel_reg <= (0 => '1', others => '0');
        spi2uart_fifo_sel_reg <= (SPI_NUM downto 1 => '0') & '1';
        fifo_en_reg <= '0';
    elsif(rising_edge(clk)) then
        tx_state_reg <= tx_state_next;
        tx_cnt_reg <= tx_cnt_next;
        spi2uart_fifo_sel_reg <= spi2uart_fifo_sel_next;
        fifo_en_reg <= fifo_en_next;
    end if;
end process;

-- state machine to read data from fifo and send data to tx
process(tx_state_reg, tx_fsm_start, tx_cnt_reg, tx_done_tick, fifo_empty, fifo_dout, spi2uart_fifo_sel_reg, tx_fsm_access_fifo, fifo_en_reg)
begin
    tx_state_next <= tx_state_reg;
    tx_cnt_next <= tx_cnt_reg;
    spi2uart_fifo_sel_next <= spi2uart_fifo_sel_reg;
    fifo_en_next <= fifo_en_reg;
    fifo_rd_en <= '0';
    tx_start <= '0';
    uart_tx_din <= (others => '0');
    tx_fsm_busy <= '1';

    case(tx_state_reg) is
        when idle =>
            if(tx_fsm_start  = '1') then
                fifo_en_next <= tx_fsm_access_fifo;
                if(tx_fsm_access_fifo = '1') then
                    tx_state_next <= checkFifo;
                else
                    tx_state_next <= readReg;
                end if;
                spi2uart_fifo_sel_next <= (SPI_NUM downto 1 => '0') & '1';
            end if;
            tx_fsm_busy <= '0';
        when readReg =>
            uart_tx_din <= reg_dout;
            tx_start <= '1';
            tx_state_next <= waitTxDone;
        when checkFifo =>
            if(spi2uart_fifo_sel_reg(SPI_NUM) = '1') then
                tx_state_next <= idle;
            else
                tx_cnt_next <= (others => '0');
                tx_state_next <= readFifo;
            end if;
        when readFifo =>
            if(tx_cnt_reg = 0) then 
                if(fifo_empty = '0') then
                    fifo_rd_en <= '1';
                else
                    spi2uart_fifo_sel_next <= spi2uart_fifo_sel_reg(SPI_NUM-1 downto 0) & spi2uart_fifo_sel_reg(SPI_NUM);
                    tx_state_next <= checkFifo;
                end if;
            elsif(tx_cnt_reg = 1) then 
                uart_tx_din <= fifo_dout;
                tx_start <= '1';
                tx_state_next <= waitTxDone;
            end if;

            tx_cnt_next <= tx_cnt_reg + 1;
        when waitTxDone =>
            if(tx_done_tick = '1') then
                tx_cnt_next <= (others => '0');
                if(fifo_en_reg = '0') then
                    tx_state_next <= idle;
                else
                    tx_state_next <= readFifo;
                end if;
            end if;
    end case;
end process;

end arch;

