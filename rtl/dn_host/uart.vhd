library ieee;
use ieee.std_logic_1164.all;

entity uart is
generic (
    N       : integer := 10  ;
    M       : integer := 651 ;
    DBIT    : integer := 24  ;
    SB_TICK : integer := 16   
);
port (
    clk               : in  std_logic                         ;
    reset             : in  std_logic                         ;

    rx                : in  std_logic                         ;
    uart_rx_dout      : out std_logic_vector(DBIT-1 downto 0) ;
    rx_done_tick      : out std_logic                         ;

    tx_start          : in  std_logic                         ;
    uart_tx_din       : in  std_logic_vector(DBIT-1 downto 0) ;
    tx                : out std_logic                         ;
    tx_done_tick      : out std_logic                         ;

    rx_tx_loopback_en : in  std_logic                          
);
end uart;

architecture arch of uart is
component baud_Gen is
generic (
    N: integer := 10  ;
    M: integer := 651  
);
port (
    clk, reset : in  std_logic                      ;
    max_tick   : out std_logic                      ;
    q          : out std_logic_vector(N-1 downto 0)  
);
end component;

component uart_rx is
generic (
    DBIT    : integer := 24 ;
    SB_TICK : integer := 16  
);
port(
    clk, reset   : in  std_logic                         ;
    rx           : in  std_logic                         ;
    s_tick       : in  std_logic                         ;
    rx_done_tick : out std_logic                         ;
    dout         : out std_logic_vector(DBIT-1 downto 0)  
);
end component;

component uart_tx is
generic(
    DBIT    : integer := 24 ;
    SB_TICK : integer := 16  
);
port(
    clk, reset   : in  std_logic                         ;
    tx_start     : in  std_logic                         ;
    s_tick       : in  std_logic                         ;
    din          : in  std_logic_vector(DBIT-1 downto 0) ;
    tx_done_tick : out std_logic                         ;
    tx           : out std_logic                     
);
end component;

component uart_loopback is
generic (
    DBIT : integer := 24 
);
port(
    clk                   : in  std_logic                         ;
    reset                 : in  std_logic                         ;

    -- interface with rx
    uart_rx_dout_internal : in  std_logic_vector(DBIT-1 downto 0) ;
    rx_done_tick_internal : in  std_logic                         ;

    -- interface with uart2fifo_ctrl
    uart_rx_dout          : out std_logic_vector(DBIT-1 downto 0) ;
    rx_done_tick          : out std_logic                         ;

    -- interface with tx
    tx_done_tick_internal : in  std_logic                         ;
    uart_tx_din_internal  : out std_logic_vector(DBIT-1 downto 0) ;
    tx_start_internal     : out std_logic                         ;

    -- interface with fifo2uart_ctrl
    tx_start              : in  std_logic                         ;
    uart_tx_din           : in  std_logic_vector(DBIT-1 downto 0) ;
    tx_done_tick          : out std_logic                         ;

    rx_tx_loopback_en     : in  std_logic                       
);
end component;

signal s_tick                : std_logic                         ;
signal q                     : std_logic_vector(N-1 downto 0)    ;
signal uart_rx_dout_internal : std_logic_vector(DBIT-1 downto 0) ;
signal rx_done_tick_internal : std_logic                         ;
signal tx_done_tick_internal : std_logic                         ;
signal uart_tx_din_internal  : std_logic_vector(DBIT-1 downto 0) ;
signal tx_start_internal     : std_logic                         ;

begin

u_uart_loopback: uart_loopback generic map (
    DBIT => DBIT 
) port map (
    clk                   => clk                   ,
    reset                 => reset                 ,
                                                   
    uart_rx_dout_internal => uart_rx_dout_internal ,
    rx_done_tick_internal => rx_done_tick_internal ,
                                                   
    uart_rx_dout          => uart_rx_dout          ,
    rx_done_tick          => rx_done_tick          ,
                                                   
    tx_done_tick_internal => tx_done_tick_internal ,
    uart_tx_din_internal  => uart_tx_din_internal  ,
    tx_start_internal     => tx_start_internal     ,
                                                   
    tx_start              => tx_start              ,
    uart_tx_din           => uart_tx_din           ,
    tx_done_tick          => tx_done_tick          ,
                                                   
    rx_tx_loopback_en     => rx_tx_loopback_en      
);

u_baud_Gen: baud_Gen generic map (
    N => N ,
    M => M
) port map (
    clk      => clk     ,
    reset    => reset   ,
    max_tick => s_tick  ,
    q        => q        
);

u_uart_rx: uart_rx generic map (
    DBIT    => DBIT    ,
    SB_TICK => SB_TICK  
) port map (
    clk          => clk                   , 
    reset        => reset                 ,
    rx           => rx                    ,
    s_tick       => s_tick                ,
    rx_done_tick => rx_done_tick_internal ,
    dout         => uart_rx_dout_internal  
);

u_uart_tx: uart_tx generic map (
    DBIT    => DBIT    , 
    SB_TICK => SB_TICK  
) port map (
    clk          => clk                   ,
    reset        => reset                 , 
    tx_start     => tx_start_internal     , 
    s_tick       => s_tick                , 
    din          => uart_tx_din_internal  , 
    tx_done_tick => tx_done_tick_internal , 
    tx           => tx                     
);

end arch;

