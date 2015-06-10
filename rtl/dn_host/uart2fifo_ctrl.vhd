library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart2fifo_ctrl is
generic (
    WIDTH          : integer := 8 ;
    SPI_NUM        : integer := 4  
);
port (
    clk                : in  std_logic                                   ;
    reset              : in  std_logic                                   ;
   
    -- interface with uart_rx
    rx_done_tick       : in std_logic                                    ;
    uart_rx_dout       : in std_logic_vector(WIDTH-1 downto 0)           ;

    -- interface with register
    reg_addr           : out std_logic_vector(2 downto 0) ;
    reg_wr_en          : out std_logic                                   ;
    reg_din            : out std_logic_vector(7 downto 0)                ;

    -- interface with fifo
    fifo_full          : in std_logic                                    ;

    fifo_wr_en         : out std_logic                                   ;
    fifo_din           : out std_logic_vector(WIDTH-1 downto 0)          ;

    uart2spi_fifo_sel  : out std_logic_vector(SPI_NUM-1 downto 0)        ;

    -- interface with spi2fifo
    tx_fsm_busy        : in  std_logic                                   ;
    tx_fsm_start       : out std_logic                                   ;

    tx_fsm_access_fifo : out std_logic                                   ;

    -- status register signal
    e_fifo_full       : out std_logic_vector(4 downto 0)                 ;

    -- observation signal
    cmd               : out std_logic_vector(WIDTH-1 downto 0)           

);
end uart2fifo_ctrl;

architecture arch of uart2fifo_ctrl is
type rx_state_type is (idle, writeReg, readLength, writeFifo, sendData) ;

signal rx_state_reg, rx_state_next                     : rx_state_type                ;
signal cmd_reg, cmd_next                               : std_logic_vector(7 downto 0) ;
signal length_reg, length_next                         : unsigned(7 downto 0)         ;
signal uart2spi_fifo_sel_reg                           : std_logic_vector(SPI_NUM-1 downto 0);
signal uart2spi_fifo_sel_next                          : std_logic_vector(SPI_NUM-1 downto 0);
signal uart2spi_fifo_sel_prev_reg                      : std_logic_vector(SPI_NUM-1 downto 0);
signal uart2spi_fifo_sel_prev_next                     : std_logic_vector(SPI_NUM-1 downto 0);
signal broadcast_reg, broadcast_next                   : std_logic;
signal tx_fsm_access_fifo_reg, tx_fsm_access_fifo_next : std_logic;
signal reg_addr_reg, reg_addr_next                     : std_logic_vector(2 downto 0);

constant w_char  : std_logic_vector(2 downto 0) := "001";
constant r_char  : std_logic_vector(2 downto 0) := "010";

begin

uart2spi_fifo_sel <= uart2spi_fifo_sel_reg when broadcast_reg = '0' else (others => '1');
cmd <= cmd_reg;
tx_fsm_access_fifo <= tx_fsm_access_fifo_reg;
reg_addr <= reg_addr_reg;

process(clk, reset)
begin
    if(reset = '1') then
        rx_state_reg <= idle;
        cmd_reg <= (others => '0');
        length_reg <= (others => '0');
        -- uart2spi_fifo_sel_reg <= (0 => '1', others => '0');
        uart2spi_fifo_sel_reg <= (SPI_NUM-1 downto 1 => '0') & '1';
        uart2spi_fifo_sel_prev_reg <= (others => '0');
        reg_addr_reg <= (others => '0');
        broadcast_reg <= '0';
        tx_fsm_access_fifo_reg <= '0';
    elsif(rising_edge(clk)) then
        rx_state_reg <= rx_state_next;
        cmd_reg <= cmd_next;
        length_reg <= length_next;
        uart2spi_fifo_sel_reg <= uart2spi_fifo_sel_next;
        uart2spi_fifo_sel_prev_reg <= uart2spi_fifo_sel_prev_next;
        broadcast_reg <= broadcast_next;
        tx_fsm_access_fifo_reg <= tx_fsm_access_fifo_next;
        reg_addr_reg <= reg_addr_next;
    end if;
end process;

-- state machine to read data from rx and send data to fifo
process(rx_state_reg, length_reg, rx_done_tick, uart_rx_dout, fifo_full, uart2spi_fifo_sel_reg, cmd_reg, uart2spi_fifo_sel_prev_reg, broadcast_reg, tx_fsm_access_fifo_reg, reg_addr_reg)
begin
    rx_state_next <= rx_state_reg;
    length_next <= length_reg;
    cmd_next <= cmd_reg;
    uart2spi_fifo_sel_next <= uart2spi_fifo_sel_reg;
    uart2spi_fifo_sel_prev_next <= uart2spi_fifo_sel_prev_reg;
    broadcast_next <= broadcast_reg;
    tx_fsm_access_fifo_next <= tx_fsm_access_fifo_reg;
    reg_addr_next <= reg_addr_reg;
    fifo_wr_en <= '0';
    fifo_din <= (others => '0');
    reg_wr_en <= '0';
    tx_fsm_start <= '0';
    reg_din <= (others => '0');
    e_fifo_full <= (others => '0');

    case(rx_state_reg) is
        when idle =>
            if(rx_done_tick = '1') then
                -- 7      6      5      4                 3             2       1       0
                -- cmd[2] cmd[1] cmd[0] broadcast/unicast fifo/regisetr addr[2] addr[1] addr[0]
                if(uart_rx_dout(7 downto 5) = w_char and uart_rx_dout(3) = '0') then
                    rx_state_next <= writeReg;
                elsif(uart_rx_dout(7 downto 5) = w_char and uart_rx_dout(3) = '1') then
                    rx_state_next <= readLength;
                elsif(uart_rx_dout(7 downto 5) = r_char) then
                    rx_state_next <= sendData;
                end if;

                if(uart_rx_dout(3) = '0') then
                    tx_fsm_access_fifo_next <= '0';
                else
                    tx_fsm_access_fifo_next <= '1';
                end if;

                broadcast_next <= uart_rx_dout(4);
                reg_addr_next <= uart_rx_dout(2 downto 0);
                cmd_next <= uart_rx_dout;
            end if;
        when writeReg => 
            if(rx_done_tick = '1') then
                reg_wr_en <= '1';
                reg_din <= uart_rx_dout;
                rx_state_next <= idle;
            end if;
        when readLength =>
            if(rx_done_tick = '1') then
                -- data format: d length data
                length_next <= unsigned(uart_rx_dout);

                -- broadcast mode
                if(broadcast_reg = '1') then
                    uart2spi_fifo_sel_prev_next <= uart2spi_fifo_sel_reg;
                end if;
                rx_state_next <= writeFifo;
            end if;
        when writeFifo =>
            if(length_reg = 0) then
                if(broadcast_reg = '1') then
                    uart2spi_fifo_sel_next <= uart2spi_fifo_sel_prev_reg;
                else
                    uart2spi_fifo_sel_next <= uart2spi_fifo_sel_reg(SPI_NUM-2 downto 0) & uart2spi_fifo_sel_reg(SPI_NUM-1);
                end if;
                rx_state_next <= idle;
            else
                if(rx_done_tick = '1') then
                    if(fifo_full = '0') then
                        fifo_wr_en <= '1';
                        fifo_din <= uart_rx_dout;
                    else
                        -- fifo is full, TODO: generate error to show fifo full
                        if(broadcast_reg = '1') then
                            e_fifo_full <= "10000";
                        else
                            e_fifo_full <= '0' & uart2spi_fifo_sel_reg;
                        end if;

                        if(broadcast_reg = '1') then
                            uart2spi_fifo_sel_next <= uart2spi_fifo_sel_prev_reg;
                        else
                            uart2spi_fifo_sel_next <= uart2spi_fifo_sel_reg(SPI_NUM-2 downto 0) & uart2spi_fifo_sel_reg(SPI_NUM-1);
                        end if;
                        rx_state_next <= idle;
                    end if;

                    length_next <= length_reg - 1;
                end if;
            end if;
        when sendData =>
            if(tx_fsm_busy = '0') then
                tx_fsm_start <= '1';
            end if;
            rx_state_next <= idle;
    end case;
end process;

end arch;

