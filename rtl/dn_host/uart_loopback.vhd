library ieee;
use ieee.std_logic_1164.all;

entity uart_loopback is
generic (
    DBIT : integer := 24 
);
port(
    clk                   : in  std_logic                      ;
    reset                 : in  std_logic                      ;

    -- interface with rx
    uart_rx_dout_internal : in  std_logic_vector(DBIT-1 downto 0)   ;
    rx_done_tick_internal : in  std_logic                      ;

    -- interface with uart2fifo_ctrl
    uart_rx_dout          : out std_logic_vector(DBIT-1 downto 0)   ;
    rx_done_tick          : out std_logic                      ;

    -- interface with tx
    tx_done_tick_internal : in  std_logic                      ;
    uart_tx_din_internal  : out std_logic_vector(DBIT-1 downto 0)   ;
    tx_start_internal     : out std_logic                      ;

    -- interface with fifo2uart_ctrl
    tx_start              : in  std_logic                      ;
    uart_tx_din           : in  std_logic_vector(DBIT-1 downto 0)   ;
    tx_done_tick          : out std_logic                      ;


    rx_tx_loopback_en        : in  std_logic                       
);
end uart_loopback;

architecture arch of uart_loopback is
signal din       : std_logic_vector(DBIT-1 downto 0);
signal buf_reg   : std_logic_vector(DBIT-1 downto 0);
signal buf_next  : std_logic_vector(DBIT-1 downto 0);
signal flag_reg  : std_logic;
signal flag_next : std_logic;
signal set_flag  : std_logic;
signal clr_flag  : std_logic;

begin

-- mux for loopback
uart_tx_din_internal <= uart_tx_din when rx_tx_loopback_en = '0' else buf_reg;
tx_start_internal <= tx_start when rx_tx_loopback_en = '0' else flag_reg;
tx_done_tick <= tx_done_tick_internal when rx_tx_loopback_en = '0' else '0';

uart_rx_dout <= uart_rx_dout_internal when rx_tx_loopback_en = '0' else (others => '0');
rx_done_tick <= rx_done_tick_internal when rx_tx_loopback_en = '0' else '0';

set_flag <= rx_done_tick_internal when rx_tx_loopback_en = '1' else '0';
clr_flag <= tx_done_tick_internal when rx_tx_loopback_en = '1' else '0';
din <= uart_rx_dout_internal when rx_tx_loopback_en = '1' else (others => '0');

process(clk, reset)
begin
    if (reset = '1') then
        buf_reg <= (others =>'0');
        flag_reg <= '0';
    elsif (clk'event and clk='1') then
        buf_reg <= buf_next;
        flag_reg <= flag_next;
    end if;
end process;

-- next-state logic
process (buf_reg, flag_reg, set_flag, clr_flag, din)
begin
    buf_next <= buf_reg;
    flag_next <= flag_reg;
    if (set_flag = '1') then
        buf_next <= din;
        flag_next <= '1';
    elsif (clr_flag = '1') then
        flag_next <= '0';
    end if;
end process;

end arch;

