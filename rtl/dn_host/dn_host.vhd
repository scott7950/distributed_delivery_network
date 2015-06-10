library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dn_host is
generic (
    UART_BAUD_WIDTH : integer := 10 ;
    UART_BAUD_CNT   : integer := 54 ;
    WIDTH           : integer := 8  ;
    SB_TICK         : integer := 16  
);
port (
    clk         : in  std_logic                    ;
    reset       : in  std_logic                    ;
   
    rx          : in  std_logic                    ;
    tx          : out std_logic                    ;

    -- spi0 master interface
    spi_m0_sck  : out std_logic                    ;
    spi_m0_ss   : out std_logic                    ;
    spi_m0_mosi : out std_logic                    ;
    spi_m0_miso : in  std_logic                    ;

    -- spi1 master interface
    spi_m1_sck  : out std_logic                    ;
    spi_m1_ss   : out std_logic                    ;
    spi_m1_mosi : out std_logic                    ;
    spi_m1_miso : in  std_logic                    ;

    -- spi2 master interface
    spi_m2_sck  : out std_logic                    ;
    spi_m2_ss   : out std_logic                    ;
    spi_m2_mosi : out std_logic                    ;
    spi_m2_miso : in  std_logic                    ;

    -- spi3 master interface
    spi_m3_sck  : out std_logic                    ;
    spi_m3_ss   : out std_logic                    ;
    spi_m3_mosi : out std_logic                    ;
    spi_m3_miso : in  std_logic                    ;

    -- spi0 slave interface
    spi_s0_sck  : in  std_logic                    ;
    spi_s0_ss   : in  std_logic                    ;
    spi_s0_mosi : in  std_logic                    ;
    spi_s0_miso : out std_logic                    ;

    -- spi1 slave interface
    spi_s1_sck  : in  std_logic                    ;
    spi_s1_ss   : in  std_logic                    ;
    spi_s1_mosi : in  std_logic                    ;
    spi_s1_miso : out std_logic                    ;

    -- spi2 slave interface
    spi_s2_sck  : in  std_logic                    ;
    spi_s2_ss   : in  std_logic                    ;
    spi_s2_mosi : in  std_logic                    ;
    spi_s2_miso : out std_logic                    ;

    -- spi3 slave interface
    spi_s3_sck  : in  std_logic                    ;
    spi_s3_ss   : in  std_logic                    ;
    spi_s3_mosi : in  std_logic                    ;
    spi_s3_miso : out std_logic                    ;

    debug_en    : in  std_logic                    ;
    ctrl        : in  std_logic_vector(6 downto 0) ;
    data_obs    : out std_logic_vector(7 downto 0) 
);
end dn_host;

architecture arch of dn_host is

component uart_sys is
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

    -- control signal
    rx_tx_loopback_en_pin     : in  std_logic                          ;
    uart2spi_fifo_loopback_en : out std_logic                          ;
    spi_loopback_en           : out std_logic                          ;

    -- status register signal
    spi2uart_fifo_full        : in  std_logic_vector(3 downto 0)       ;
    e_spi2uart_fifo_full      : in  std_logic_vector(3 downto 0)       ;

    -- observation signal
    debug_en_reg              : out std_logic                          ;
    cmd                       : out std_logic_vector(WIDTH-1 downto 0) ;
    tx_fsm_busy_obs           : out std_logic                           
);
end component;

component spi_host is
generic (
    WIDTH : integer := 8 
);
port (
    clk                       : in  std_logic                            ;
    reset                     : in  std_logic                            ;
   
    -- interface with uart2spi_fifo
    uart2spi_fifo_wr_en       : in  std_logic                            ;
    uart2spi_fifo_din         : in  std_logic_vector(WIDTH-1 downto 0)   ;

    uart2spi_fifo_full        : out std_logic                            ;

    -- interface with spi2uart_fifo
    spi2uart_fifo_rd_en       : in  std_logic                            ;
    spi2uart_fifo_dout        : out std_logic_vector(WIDTH-1 downto 0)   ;

    spi2uart_fifo_empty       : out std_logic                            ;

    -- spi master interface
    spi_m_sck                 : out std_logic                            ;
    spi_m_ss                  : out std_logic                            ;
    spi_m_mosi                : out std_logic                            ;
    spi_m_miso                : in  std_logic                            ;

    -- spi slave interface
    spi_s_sck                 : in  std_logic                            ;
    spi_s_ss                  : in  std_logic                            ;
    spi_s_mosi                : in  std_logic                            ;
    spi_s_miso                : out std_logic                            ;

    -- control signal
    uart2spi_fifo_loopback_en : in  std_logic                            ;
    spi_loopback_en           : in  std_logic                            ;

    -- status registers signal
    spi2uart_fifo_full_status : out std_logic                            ;
    e_fifo_full               : out std_logic                             
);
end component;

signal rx_tx_loopback_en_pin         : std_logic                    ;
signal uart2spi_fifo_loopback_en     : std_logic                    ;
signal uart2spi_fifo_loopback_en_reg : std_logic                    ;
signal uart2spi_fifo_loopback_en_pin : std_logic                    ;
signal spi_loopback_en               : std_logic                    ;
signal spi_loopback_en_reg           : std_logic                    ;
signal spi_loopback_en_pin           : std_logic                    ;

-- uart to spi fifo 0
signal uart2spi0_fifo_full  : std_logic ;
signal uart2spi0_fifo_wr_en : std_logic ;
signal uart2spi0_fifo_din   : std_logic_vector(WIDTH-1 downto 0) ; 

-- uart to spi fifo 1
signal uart2spi1_fifo_full  : std_logic ;
signal uart2spi1_fifo_wr_en : std_logic ;
signal uart2spi1_fifo_din   : std_logic_vector(WIDTH-1 downto 0) ; 

-- uart to spi fifo 2
signal uart2spi2_fifo_full  : std_logic ;
signal uart2spi2_fifo_wr_en : std_logic ;
signal uart2spi2_fifo_din   : std_logic_vector(WIDTH-1 downto 0) ; 

-- uart to spi fifo 3
signal uart2spi3_fifo_full  : std_logic ;
signal uart2spi3_fifo_wr_en : std_logic ;
signal uart2spi3_fifo_din   : std_logic_vector(WIDTH-1 downto 0) ; 

-- spi to uart fifo 0
signal spi2uart0_fifo_rd_en : std_logic ;
signal spi2uart0_fifo_empty : std_logic ;
signal spi2uart0_fifo_dout  : std_logic_vector(WIDTH-1 downto 0) ;

-- spi to uart fifo 1
signal spi2uart1_fifo_rd_en : std_logic ;
signal spi2uart1_fifo_empty : std_logic ;
signal spi2uart1_fifo_dout  : std_logic_vector(WIDTH-1 downto 0) ;

-- spi to uart fifo 2
signal spi2uart2_fifo_rd_en : std_logic ;
signal spi2uart2_fifo_empty : std_logic ;
signal spi2uart2_fifo_dout  : std_logic_vector(WIDTH-1 downto 0) ;

-- spi to uart fifo 3
signal spi2uart3_fifo_rd_en : std_logic ;
signal spi2uart3_fifo_empty : std_logic ;
signal spi2uart3_fifo_dout  : std_logic_vector(WIDTH-1 downto 0) ;

---- spi0 master interface
--signal spi_m0_sck  : std_logic                    ;
--signal spi_m0_ss   : std_logic                    ;
--signal spi_m0_mosi : std_logic                    ;
--signal spi_m0_miso : std_logic                    ;
--
---- spi1 master interface
--signal spi_m1_sck  : std_logic                    ;
--signal spi_m1_ss   : std_logic                    ;
--signal spi_m1_mosi : std_logic                    ;
--signal spi_m1_miso : std_logic                    ;
--
---- spi2 master interface
--signal spi_m2_sck  : std_logic                    ;
--signal spi_m2_ss   : std_logic                    ;
--signal spi_m2_mosi : std_logic                    ;
--signal spi_m2_miso : std_logic                    ;
--
---- spi3 master interface
--signal spi_m3_sck  : std_logic                    ;
--signal spi_m3_ss   : std_logic                    ;
--signal spi_m3_mosi : std_logic                    ;
--signal spi_m3_miso : std_logic                    ;
--
---- spi0 slave interface
--signal spi_s0_sck  : std_logic                    ;
--signal spi_s0_ss   : std_logic                    ;
--signal spi_s0_mosi : std_logic                    ;
--signal spi_s0_miso : std_logic                    ;
--
---- spi1 slave interface
--signal spi_s1_sck  : std_logic                    ;
--signal spi_s1_ss   : std_logic                    ;
--signal spi_s1_mosi : std_logic                    ;
--signal spi_s1_miso : std_logic                    ;
--
---- spi2 slave interface
--signal spi_s2_sck  : std_logic                    ;
--signal spi_s2_ss   : std_logic                    ;
--signal spi_s2_mosi : std_logic                    ;
--signal spi_s2_miso : std_logic                    ;
--
---- spi3 slave interface
--signal spi_s3_sck  : std_logic                    ;
--signal spi_s3_ss   : std_logic                    ;
--signal spi_s3_mosi : std_logic                    ;
--signal spi_s3_miso : std_logic                    ;

-- status register signals
signal spi2uart_fifo_full   : std_logic_vector(3 downto 0) ;
signal e_spi2uart_fifo_full : std_logic_vector(3 downto 0) ;
                                                 
-- observation signals
signal cmd             : std_logic_vector(WIDTH-1 downto 0) ;
signal debug_en_reg    : std_logic                          ;
signal tx_fsm_busy_obs : std_logic                          ;

begin

-- observation signal
data_obs(2 downto 0) <= cmd(7 downto 5);
data_obs(7) <= debug_en or debug_en_reg;
data_obs(4) <= spi2uart_fifo_full(0) or spi2uart_fifo_full(1) or spi2uart_fifo_full(2) or spi2uart_fifo_full(3) or uart2spi0_fifo_full or uart2spi1_fifo_full or uart2spi2_fifo_full or uart2spi3_fifo_full;
data_obs(5) <= tx_fsm_busy_obs;

-- control signals
rx_tx_loopback_en_pin <= ctrl(0) when debug_en = '1' else '0';

uart2spi_fifo_loopback_en_pin <= ctrl(1) when debug_en = '1' else '0';
uart2spi_fifo_loopback_en <= uart2spi_fifo_loopback_en_pin or uart2spi_fifo_loopback_en_reg; 

spi_loopback_en_pin <= ctrl(2) when debug_en = '1' else '0';
spi_loopback_en <= spi_loopback_en_pin or spi_loopback_en_reg; 

-- uart
u_uart_sys: uart_sys generic map (
    N              => UART_BAUD_WIDTH ,
    M              => UART_BAUD_CNT   ,
    DBIT           => WIDTH           ,
    SB_TICK        => SB_TICK         ,
    WIDTH          => WIDTH            
) port map (
    clk                       => clk                           ,
    reset                     => reset                         ,
                                                               
    rx                        => rx                            ,
    tx                        => tx                            ,
                                                               
    uart2spi0_fifo_full       => uart2spi0_fifo_full           ,
    uart2spi0_fifo_wr_en      => uart2spi0_fifo_wr_en          ,
    uart2spi0_fifo_din        => uart2spi0_fifo_din            ,
                                                               
    uart2spi1_fifo_full       => uart2spi1_fifo_full           ,
    uart2spi1_fifo_wr_en      => uart2spi1_fifo_wr_en          ,
    uart2spi1_fifo_din        => uart2spi1_fifo_din            ,
                                                               
    uart2spi2_fifo_full       => uart2spi2_fifo_full           ,
    uart2spi2_fifo_wr_en      => uart2spi2_fifo_wr_en          ,
    uart2spi2_fifo_din        => uart2spi2_fifo_din            ,
                                                               
    uart2spi3_fifo_full       => uart2spi3_fifo_full           ,
    uart2spi3_fifo_wr_en      => uart2spi3_fifo_wr_en          ,
    uart2spi3_fifo_din        => uart2spi3_fifo_din            ,
                                                               
    spi2uart0_fifo_rd_en      => spi2uart0_fifo_rd_en          ,
    spi2uart0_fifo_empty      => spi2uart0_fifo_empty          ,
    spi2uart0_fifo_dout       => spi2uart0_fifo_dout           ,
                                                               
    spi2uart1_fifo_rd_en      => spi2uart1_fifo_rd_en          ,
    spi2uart1_fifo_empty      => spi2uart1_fifo_empty          ,
    spi2uart1_fifo_dout       => spi2uart1_fifo_dout           ,
                                                               
    spi2uart2_fifo_rd_en      => spi2uart2_fifo_rd_en          ,
    spi2uart2_fifo_empty      => spi2uart2_fifo_empty          ,
    spi2uart2_fifo_dout       => spi2uart2_fifo_dout           ,
                                                               
    spi2uart3_fifo_rd_en      => spi2uart3_fifo_rd_en          ,
    spi2uart3_fifo_empty      => spi2uart3_fifo_empty          ,
    spi2uart3_fifo_dout       => spi2uart3_fifo_dout           ,

    rx_tx_loopback_en_pin     => rx_tx_loopback_en_pin         ,
    uart2spi_fifo_loopback_en => uart2spi_fifo_loopback_en_reg ,
    spi_loopback_en           => spi_loopback_en_reg           ,

    spi2uart_fifo_full        => spi2uart_fifo_full            ,
    e_spi2uart_fifo_full      => e_spi2uart_fifo_full          ,
                                                 
    debug_en_reg              => debug_en_reg                  ,
    cmd                       => cmd                           ,
    tx_fsm_busy_obs           => tx_fsm_busy_obs                    
);

-- spi0
u_spi_host0: spi_host generic map (
    WIDTH => WIDTH
) port map (
    clk                       => clk                       ,
    reset                     => reset                     ,
                                                           
    uart2spi_fifo_wr_en       => uart2spi0_fifo_wr_en      ,
    uart2spi_fifo_din         => uart2spi0_fifo_din        ,
                                                           
    uart2spi_fifo_full        => uart2spi0_fifo_full       ,
                                                           
    spi2uart_fifo_rd_en       => spi2uart0_fifo_rd_en      ,
    spi2uart_fifo_dout        => spi2uart0_fifo_dout       ,
                                                           
    spi2uart_fifo_empty       => spi2uart0_fifo_empty      ,

    spi_m_sck                 => spi_m0_sck                ,
    spi_m_ss                  => spi_m0_ss                 ,
    spi_m_mosi                => spi_m0_mosi               ,
    spi_m_miso                => spi_m0_miso               ,

    spi_s_sck                 => spi_s0_sck                ,
    spi_s_ss                  => spi_s0_ss                 ,
    spi_s_mosi                => spi_s0_mosi               ,
    spi_s_miso                => spi_s0_miso               ,

    uart2spi_fifo_loopback_en => uart2spi_fifo_loopback_en ,
    spi_loopback_en           => spi_loopback_en           ,

    spi2uart_fifo_full_status => spi2uart_fifo_full(0)     ,
    e_fifo_full               => e_spi2uart_fifo_full(0)    
);

-- spi1
u_spi_host1: spi_host generic map (
    WIDTH => WIDTH
) port map (
    clk                       => clk                       ,
    reset                     => reset                     ,
                                                           
    uart2spi_fifo_wr_en       => uart2spi1_fifo_wr_en      ,
    uart2spi_fifo_din         => uart2spi1_fifo_din        ,
                                                           
    uart2spi_fifo_full        => uart2spi1_fifo_full       ,
                                                           
    spi2uart_fifo_rd_en       => spi2uart1_fifo_rd_en      ,
    spi2uart_fifo_dout        => spi2uart1_fifo_dout       ,
                                                           
    spi2uart_fifo_empty       => spi2uart1_fifo_empty      ,

    spi_m_sck                 => spi_m1_sck                ,
    spi_m_ss                  => spi_m1_ss                 ,
    spi_m_mosi                => spi_m1_mosi               ,
    spi_m_miso                => spi_m1_miso               ,

    spi_s_sck                 => spi_s1_sck                ,
    spi_s_ss                  => spi_s1_ss                 ,
    spi_s_mosi                => spi_s1_mosi               ,
    spi_s_miso                => spi_s1_miso               ,

    uart2spi_fifo_loopback_en => uart2spi_fifo_loopback_en ,
    spi_loopback_en           => spi_loopback_en           ,

    spi2uart_fifo_full_status => spi2uart_fifo_full(1)     ,
    e_fifo_full               => e_spi2uart_fifo_full(1)    
);

-- spi2
u_spi_host2: spi_host generic map (
    WIDTH => WIDTH
) port map (
    clk                       => clk                       ,
    reset                     => reset                     ,
                                                           
    uart2spi_fifo_wr_en       => uart2spi2_fifo_wr_en      ,
    uart2spi_fifo_din         => uart2spi2_fifo_din        ,
                                                           
    uart2spi_fifo_full        => uart2spi2_fifo_full       ,
                                                           
    spi2uart_fifo_rd_en       => spi2uart2_fifo_rd_en      ,
    spi2uart_fifo_dout        => spi2uart2_fifo_dout       ,
                                                           
    spi2uart_fifo_empty       => spi2uart2_fifo_empty      ,

    spi_m_sck                 => spi_m2_sck                ,
    spi_m_ss                  => spi_m2_ss                 ,
     spi_m_mosi               => spi_m2_mosi               ,
    spi_m_miso                => spi_m2_miso               ,

    spi_s_sck                 => spi_s2_sck                ,
    spi_s_ss                  => spi_s2_ss                 ,
    spi_s_mosi                => spi_s2_mosi               ,
    spi_s_miso                => spi_s2_miso               ,

    uart2spi_fifo_loopback_en => uart2spi_fifo_loopback_en ,
    spi_loopback_en           => spi_loopback_en           ,

    spi2uart_fifo_full_status => spi2uart_fifo_full(2)     ,
    e_fifo_full               => e_spi2uart_fifo_full(2)    
);

-- spi3
u_spi_host3: spi_host generic map (
    WIDTH => WIDTH
) port map (
    clk                       => clk                       ,
    reset                     => reset                     ,
                                                           
    uart2spi_fifo_wr_en       => uart2spi3_fifo_wr_en      ,
    uart2spi_fifo_din         => uart2spi3_fifo_din        ,
                                                           
    uart2spi_fifo_full        => uart2spi3_fifo_full       ,
                                                           
    spi2uart_fifo_rd_en       => spi2uart3_fifo_rd_en      ,
    spi2uart_fifo_dout        => spi2uart3_fifo_dout       ,
                                                           
    spi2uart_fifo_empty       => spi2uart3_fifo_empty      ,

    spi_m_sck                 => spi_m3_sck                ,
    spi_m_ss                  => spi_m3_ss                 ,
    spi_m_mosi                => spi_m3_mosi               ,
    spi_m_miso                => spi_m3_miso               ,

    spi_s_sck                 => spi_s3_sck                ,
    spi_s_ss                  => spi_s3_ss                 ,
    spi_s_mosi                => spi_s3_mosi               ,
    spi_s_miso                => spi_s3_miso               ,

    uart2spi_fifo_loopback_en => uart2spi_fifo_loopback_en ,
    spi_loopback_en           => spi_loopback_en           ,

    spi2uart_fifo_full_status => spi2uart_fifo_full(3)     ,
    e_fifo_full               => e_spi2uart_fifo_full(3)    
);

end arch;

