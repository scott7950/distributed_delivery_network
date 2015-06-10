library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_sys is
generic (
    N              : integer := 10 ;
    M              : integer := 54 ;
    DBIT           : integer := 8  ;
    SB_TICK        : integer := 16 ;
    WIDTH          : integer := 8   
);
port (
    clk                       : in  std_logic                          ;
    reset                     : in  std_logic                          ;

    -- interface with tx/rx
    rx                        : in  std_logic                          ;
    tx                        : out std_logic                          ;

    -- uart to spi fifo 0
    uart2spi0_fifo_full       : in  std_logic                          ;
    uart2spi0_fifo_wr_en      : out std_logic                          ;
    uart2spi0_fifo_din        : out std_logic_vector(WIDTH-1 downto 0) ; 

    -- uart to spi fifo 1     
    uart2spi1_fifo_full       : in  std_logic                          ;
    uart2spi1_fifo_wr_en      : out std_logic                          ;
    uart2spi1_fifo_din        : out std_logic_vector(WIDTH-1 downto 0) ; 

    -- uart to spi fifo 2     
    uart2spi2_fifo_full       : in  std_logic                          ;
    uart2spi2_fifo_wr_en      : out std_logic                          ;
    uart2spi2_fifo_din        : out std_logic_vector(WIDTH-1 downto 0) ; 

    -- uart to spi fifo 3     
    uart2spi3_fifo_full       : in  std_logic                          ;
    uart2spi3_fifo_wr_en      : out std_logic                          ;
    uart2spi3_fifo_din        : out std_logic_vector(WIDTH-1 downto 0) ; 

    -- spi to uart fifo 0     
    spi2uart0_fifo_rd_en      : out std_logic                          ;
    spi2uart0_fifo_empty      : in  std_logic                          ;
    spi2uart0_fifo_dout       : in  std_logic_vector(WIDTH-1 downto 0) ;

    -- spi to uart fifo 1     
    spi2uart1_fifo_rd_en      : out std_logic                          ;
    spi2uart1_fifo_empty      : in  std_logic                          ;
    spi2uart1_fifo_dout       : in  std_logic_vector(WIDTH-1 downto 0) ;

    -- spi to uart fifo 2     
    spi2uart2_fifo_rd_en      : out std_logic                          ;
    spi2uart2_fifo_empty      : in  std_logic                          ;
    spi2uart2_fifo_dout       : in  std_logic_vector(WIDTH-1 downto 0) ;

    -- spi to uart fifo 3     
    spi2uart3_fifo_rd_en      : out std_logic                          ;
    spi2uart3_fifo_empty      : in  std_logic                          ;
    spi2uart3_fifo_dout       : in  std_logic_vector(WIDTH-1 downto 0) ;

    -- ctrl signal
    rx_tx_loopback_en_pin     : in   std_logic                         ;
    uart2spi_fifo_loopback_en : out  std_logic                         ;
    spi_loopback_en           : out  std_logic                         ;

    -- status signal
    spi2uart_fifo_full        : in  std_logic_vector(3 downto 0)       ;
    e_spi2uart_fifo_full      : in  std_logic_vector(3 downto 0)       ;

    -- observation signal
    debug_en_reg              : out std_logic                          ;
    cmd                       : out std_logic_vector(WIDTH-1 downto 0) ;
    tx_fsm_busy_obs           : out std_logic                           
);
end uart_sys;

architecture arch of uart_sys is
component uart is
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
end component;

component uart2fifo_ctrl is
generic (
    WIDTH          : integer := 8 ;
    SPI_NUM        : integer := 4  
);
port (
    clk               : in  std_logic                            ;
    reset             : in  std_logic                            ;
   
    -- interface with uart_rx
    rx_done_tick      : in std_logic                             ;
    uart_rx_dout      : in std_logic_vector(WIDTH-1 downto 0)    ;

    -- interface with register
    reg_addr          : out std_logic_vector(2 downto 0)         ;
    reg_wr_en         : out std_logic                            ;
    reg_din           : out std_logic_vector(7 downto 0)         ;

    -- interface with fifo
    fifo_full         : in std_logic                             ;

    fifo_wr_en        : out std_logic                            ;
    fifo_din          : out std_logic_vector(WIDTH-1 downto 0)   ;

    uart2spi_fifo_sel : out std_logic_vector(SPI_NUM-1 downto 0) ;

    -- interface with fifo2uart_ctrl
    tx_fsm_busy       : in  std_logic                            ;
    tx_fsm_start      : out std_logic                            ;

    tx_fsm_access_fifo           : out std_logic                            ;


    -- status register signal
    e_fifo_full       : out std_logic_vector(4 downto 0)          ;

    -- observation signal
    cmd               : out std_logic_vector(WIDTH-1 downto 0)    

);
end component;

component fifo2uart_ctrl is
generic (
    WIDTH   : integer := 8 ;
    SPI_NUM : integer := 4 
);
port (
    clk               : in  std_logic                            ;
    reset             : in  std_logic                            ;

    -- interface with uart2fifo_ctrl
    tx_fsm_start      : in  std_logic                            ;
    tx_fsm_busy       : out std_logic                            ;
    tx_fsm_access_fifo           : in  std_logic                            ;

    -- interface with reg
    reg_dout          : in  std_logic_vector(7 downto 0)         ;
   
    -- interface with uart_tx
    tx_done_tick      : in  std_logic                            ;
    tx_start          : out std_logic                            ;
    uart_tx_din       : out std_logic_vector(WIDTH-1 downto 0)   ;

    -- interface with fifo
    fifo_empty        : in std_logic                             ;

    fifo_dout         : in  std_logic_vector(WIDTH-1 downto 0)   ;
    fifo_rd_en        : out std_logic                            ;

    spi2uart_fifo_sel : out std_logic_vector(SPI_NUM-1 downto 0)  

);
end component;

component dn_reg is
port (
    clk                           : in  std_logic                    ;
    reset                         : in  std_logic                    ;

    reg_addr                      : in  std_logic_vector(2 downto 0) ;
    reg_wr_en                     : in  std_logic                    ;
    reg_din                       : in  std_logic_vector(7 downto 0) ;
    reg_dout                      : out std_logic_vector(7 downto 0) ;

    uart2spi_fifo_full            : in  std_logic_vector(3 downto 0) ;
    spi2uart_fifo_full            : in  std_logic_vector(3 downto 0) ;

    e_spi2uart_fifo_full          : in  std_logic_vector(3 downto 0) ;
    e_uart2spi_fifo_full          : in  std_logic_vector(4 downto 0) ;

    debug_en                      : out std_logic                    ;
    uart2spi_fifo_loopback_en     : out std_logic                    ;
    spi_loopback_en               : out std_logic                     
);
end component;

constant SPI_NUM : integer := 4 ;

-- uart signal
signal uart_rx_dout : std_logic_vector(7 downto 0)   ;
signal rx_done_tick : std_logic                      ;

signal tx_start     : std_logic                      ;
signal uart_tx_din  : std_logic_vector(7 downto 0)   ;
signal tx_done_tick : std_logic                      ;

signal tx_fsm_busy  : std_logic                            ;
signal tx_fsm_start : std_logic                            ;

-- signal with register
signal reg_addr  : std_logic_vector(2 downto 0)         ;
signal reg_wr_en : std_logic                            ;
signal reg_din   : std_logic_vector(7 downto 0)         ;
signal reg_dout  : std_logic_vector(7 downto 0)         ;

signal tx_fsm_access_fifo   : std_logic                            ;

-- uart to spi fifo signal
signal uart2spi_fifo_sel : std_logic_vector(SPI_NUM-1 downto 0) ;
-- spi to uart fifo signal
signal spi2uart_fifo_sel : std_logic_vector(SPI_NUM-1 downto 0) ;

-- uart to spi fifo signal
signal fifo_full         : std_logic                             ;
-- spi to uart fifo signal
signal fifo_empty        : std_logic                             ;

-- spi to uart fifo signal
signal fifo_dout         : std_logic_vector(WIDTH-1 downto 0)   ;
signal fifo_rd_en        : std_logic                            ;

-- uart to spi fifo signal
signal fifo_wr_en        : std_logic                            ;
signal fifo_din          : std_logic_vector(WIDTH-1 downto 0)   ;

-- ctrl signals controlled by registers
signal rx_tx_loopback_en             : std_logic                       ;
signal uart2spi_fifo_full : std_logic_vector(3 downto 0) ;

-- error uart to spi master fifo full 
signal e_uart2spi_fifo_full        : std_logic_vector(4 downto 0) ;

begin

-- observation signal
tx_fsm_busy_obs <= tx_fsm_busy ;

u_dn_reg: dn_reg port map (
    clk                           => clk                       ,
    reset                         => reset                     ,

    reg_addr                      => reg_addr                  ,
    reg_wr_en                     => reg_wr_en                 ,
    reg_din                       => reg_din                   ,
    reg_dout                      => reg_dout                  ,

    uart2spi_fifo_full            => uart2spi_fifo_full        ,
    spi2uart_fifo_full            => spi2uart_fifo_full        ,

    e_spi2uart_fifo_full          => e_spi2uart_fifo_full      ,
    e_uart2spi_fifo_full          => e_uart2spi_fifo_full      ,

    debug_en                      => debug_en_reg              ,
    uart2spi_fifo_loopback_en     => uart2spi_fifo_loopback_en ,
    spi_loopback_en               => spi_loopback_en            
);

uart2spi_fifo_full <= uart2spi3_fifo_full & uart2spi2_fifo_full & uart2spi1_fifo_full & uart2spi0_fifo_full;

-- ctrl signal
rx_tx_loopback_en <= rx_tx_loopback_en_pin;

-- fifo_full for uart to spi fifo
process(uart2spi_fifo_sel, uart2spi0_fifo_full, uart2spi1_fifo_full, uart2spi2_fifo_full, uart2spi3_fifo_full)
begin
    case uart2spi_fifo_sel is
        when x"1" => fifo_full <= uart2spi0_fifo_full;
        when x"2" => fifo_full <= uart2spi1_fifo_full;
        when x"4" => fifo_full <= uart2spi2_fifo_full;
        when x"8" => fifo_full <= uart2spi3_fifo_full;
        when x"f" => fifo_full <= uart2spi0_fifo_full or uart2spi1_fifo_full or uart2spi2_fifo_full or uart2spi3_fifo_full;
        when others => fifo_full <= '1';
    end case;
end process;

-- wr_en for uart to spi fifo
uart2spi0_fifo_wr_en <= uart2spi_fifo_sel(0) and fifo_wr_en;
uart2spi1_fifo_wr_en <= uart2spi_fifo_sel(1) and fifo_wr_en;
uart2spi2_fifo_wr_en <= uart2spi_fifo_sel(2) and fifo_wr_en;
uart2spi3_fifo_wr_en <= uart2spi_fifo_sel(3) and fifo_wr_en;

-- din for uart to spi fifo
uart2spi0_fifo_din   <= fifo_din;
uart2spi1_fifo_din   <= fifo_din;
uart2spi2_fifo_din   <= fifo_din;
uart2spi3_fifo_din   <= fifo_din;

-- fifo_empty for spi fifo to uart 
process(spi2uart_fifo_sel, spi2uart0_fifo_empty, spi2uart1_fifo_empty, spi2uart2_fifo_empty, spi2uart3_fifo_empty)
begin
    case spi2uart_fifo_sel is
        when x"1" => fifo_empty <= spi2uart0_fifo_empty;
        when x"2" => fifo_empty <= spi2uart1_fifo_empty;
        when x"4" => fifo_empty <= spi2uart2_fifo_empty;
        when x"8" => fifo_empty <= spi2uart3_fifo_empty;
        when others => fifo_empty <= '1';
    end case;
end process;

-- rd_en for spi fifo to uart 
spi2uart0_fifo_rd_en <= spi2uart_fifo_sel(0) and fifo_rd_en;
spi2uart1_fifo_rd_en <= spi2uart_fifo_sel(1) and fifo_rd_en;
spi2uart2_fifo_rd_en <= spi2uart_fifo_sel(2) and fifo_rd_en;
spi2uart3_fifo_rd_en <= spi2uart_fifo_sel(3) and fifo_rd_en;

-- fifo_dout for spi fifo to uart 
process(spi2uart_fifo_sel, spi2uart0_fifo_dout, spi2uart1_fifo_dout, spi2uart2_fifo_dout, spi2uart3_fifo_dout)
begin
    case spi2uart_fifo_sel is
        when x"1" => fifo_dout <= spi2uart0_fifo_dout;
        when x"2" => fifo_dout <= spi2uart1_fifo_dout;
        when x"4" => fifo_dout <= spi2uart2_fifo_dout;
        when x"8" => fifo_dout <= spi2uart3_fifo_dout;
        when others => fifo_dout <= (others => '0');
    end case;
end process;

u_uart: uart generic map (
    N       => N       ,
    M       => M       ,
    DBIT    => DBIT    ,
    SB_TICK => SB_TICK  
) port map (
    clk               => clk               ,
    reset             => reset             ,

    rx                => rx                ,
    uart_rx_dout      => uart_rx_dout      ,
    rx_done_tick      => rx_done_tick      ,

    tx_start          => tx_start          ,
    uart_tx_din       => uart_tx_din       ,
    tx                => tx                ,
    tx_done_tick      => tx_done_tick      ,
    rx_tx_loopback_en => rx_tx_loopback_en
);

u_uart2fifo_ctrl: uart2fifo_ctrl generic map (
    WIDTH          => WIDTH          ,
    SPI_NUM        => SPI_NUM         
) port map (
    clk               => clk                   ,
    reset             => reset                 ,

    rx_done_tick      => rx_done_tick          ,
    uart_rx_dout      => uart_rx_dout          ,

    reg_addr          => reg_addr              ,
    reg_wr_en         => reg_wr_en             ,
    reg_din           => reg_din               ,

    fifo_full         => fifo_full             ,

    fifo_wr_en        => fifo_wr_en            ,
    fifo_din          => fifo_din              ,

    uart2spi_fifo_sel => uart2spi_fifo_sel     ,

    tx_fsm_busy       => tx_fsm_busy           ,
    tx_fsm_start      => tx_fsm_start          ,

    tx_fsm_access_fifo           => tx_fsm_access_fifo               ,

    e_fifo_full       => e_uart2spi_fifo_full  ,

    cmd               => cmd                    

);

u_fifo2uart_ctrl: fifo2uart_ctrl generic map (
    WIDTH   => WIDTH   ,
    SPI_NUM => SPI_NUM  
) port map (
    clk                => clk               ,
    reset              => reset             ,

    tx_fsm_start       => tx_fsm_start      ,
    tx_fsm_busy        => tx_fsm_busy       ,
    tx_fsm_access_fifo => tx_fsm_access_fifo           ,

    reg_dout           => reg_dout          ,

    tx_done_tick       => tx_done_tick      ,
    tx_start           => tx_start          ,
    uart_tx_din        => uart_tx_din       ,

    fifo_empty         => fifo_empty        ,

    fifo_dout          => fifo_dout         ,
    fifo_rd_en         => fifo_rd_en        ,

    spi2uart_fifo_sel  => spi2uart_fifo_sel  

);

end arch;

