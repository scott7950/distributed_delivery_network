library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_host is
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
end spi_host;

architecture arch of spi_host is
component uart2spi_fifo is
port (
    clk   : in  std_logic                    ;
    rst   : in  std_logic                    ;
    din   : in  std_logic_vector(7 downto 0) ;
    wr_en : in  std_logic                    ;
    rd_en : in  std_logic                    ;
    dout  : out std_logic_vector(7 downto 0) ;
    full  : out std_logic                    ;
    empty : out std_logic                     
);
end component;

component spi_m is
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
end component;

component spi_s is
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
end component;

component spi2fifo_ctrl is
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
    e_fifo_full   : out std_logic                           

);
end component;

component spi2uart_fifo is
port (
    clk   : in  std_logic                    ;
    rst   : in  std_logic                    ;
    din   : in  std_logic_vector(7 downto 0) ;
    wr_en : in  std_logic                    ;
    rd_en : in  std_logic                    ;
    dout  : out std_logic_vector(7 downto 0) ;
    full  : out std_logic                    ;
    empty : out std_logic                     
);
end component;

component fifo_loopback is
generic (
    WIDTH : integer := 8 
);
port (
    clk              : in std_logic ;
    reset            : in std_logic ;

    -- fifo interface to read fifo
    fifo_empty       : in  std_logic ;
    fifo_rd_en       : out std_logic ;
    fifo_dout        : in  std_logic_vector(7 downto 0) ;

    -- fifo interface needed to connect read fifo
    fifo_empty_ext   : out std_logic ;
    fifo_rd_en_ext   : in  std_logic ;
    fifo_dout_ext    : out std_logic_vector(7 downto 0) ;

    -- fifo interface to write fifo
    fifo_full        : in  std_logic ;
    fifo_wr_en       : out std_logic ;
    fifo_din         : out std_logic_vector(7 downto 0) ;

    -- fifo interface needed to connect write fifo
    fifo_full_ext    : out std_logic ;
    fifo_wr_en_ext   : in  std_logic ;
    fifo_din_ext     : in  std_logic_vector(7 downto 0) ;

    fifo_loopback_en : in std_logic
);
end component;

component spi_loopback is
port (
    -- interface with spi master
    spi_m_sck       : in  std_logic ;
    spi_m_ss        : in  std_logic ;
    spi_m_mosi      : in  std_logic ;
    spi_m_miso      : out std_logic ;

    -- interface with that needed connected to spi master
    spi_m_sck_ext   : out std_logic ;
    spi_m_ss_ext    : out std_logic ;
    spi_m_mosi_ext  : out std_logic ;
    spi_m_miso_ext  : in  std_logic ;

    -- interface with spi slave
    spi_s_sck       : out std_logic ;
    spi_s_ss        : out std_logic ;
    spi_s_mosi      : out std_logic ;
    spi_s_miso      : in  std_logic ;

    -- interface with that needed connected to spi slave
    spi_s_sck_ext   : in  std_logic ;
    spi_s_ss_ext    : in  std_logic ;
    spi_s_mosi_ext  : in  std_logic ;
    spi_s_miso_ext  : out std_logic ;

    -- control signal
    spi_loopback_en : in  std_logic  

);
end component;

signal spi_m_uart2spi_fifo_empty    : std_logic                          ;
signal spi_m_uart2spi_fifo_rd_en    : std_logic                          ;
signal spi_m_uart2spi_fifo_dout     : std_logic_vector(WIDTH-1 downto 0) ;

signal uart2spi_fifo_empty          : std_logic                          ;
signal uart2spi_fifo_rd_en          : std_logic                          ;
signal uart2spi_fifo_dout           : std_logic_vector(WIDTH-1 downto 0) ;

signal spi_s_spi2uart_fifo_full     : std_logic                          ;
signal spi_s_spi2uart_fifo_wr_en    : std_logic                          ;
signal spi_s_spi2uart_fifo_din      : std_logic_vector(WIDTH-1 downto 0) ;

signal spi2uart_fifo_full           : std_logic                          ;
signal spi2uart_fifo_wr_en          : std_logic                          ;
signal spi2uart_fifo_din            : std_logic_vector(WIDTH-1 downto 0) ;

-- spi master interface
signal spi_m_sck_internal           : std_logic                          ;
signal spi_m_mosi_internal          : std_logic                          ;
signal spi_m_miso_internal          : std_logic                          ;
signal spi_m_ss_internal            : std_logic                          ;

-- spi slave interface
signal spi_s_sck_internal           : std_logic                          ;
signal spi_s_ss_internal            : std_logic                          ;
signal spi_s_mosi_internal          : std_logic                          ;
signal spi_s_miso_internal          : std_logic                          ;

signal spi_done_tick                : std_logic                          ;
signal spi_dout                     : std_logic_vector(WIDTH-1 downto 0) ;

begin

-- status register signal
spi2uart_fifo_full_status <= spi2uart_fifo_full;

-- uart2spi fifo loop back to spi2uart fifo
u_fifo_loopback: fifo_loopback generic map (
    WIDTH => WIDTH 
) port map (
    clk              => clk                       ,
    reset            => reset                     ,

    -- fifo interface to read fifo
    fifo_empty       => uart2spi_fifo_empty       ,
    fifo_rd_en       => uart2spi_fifo_rd_en       ,
    fifo_dout        => uart2spi_fifo_dout        ,

    -- fifo interface needed to connect read fifo
    fifo_empty_ext   => spi_m_uart2spi_fifo_empty ,
    fifo_rd_en_ext   => spi_m_uart2spi_fifo_rd_en ,
    fifo_dout_ext    => spi_m_uart2spi_fifo_dout  ,

    -- fifo interface to write fifo
    fifo_full        => spi2uart_fifo_full        ,
    fifo_wr_en       => spi2uart_fifo_wr_en       ,
    fifo_din         => spi2uart_fifo_din         ,

    -- fifo interface needed to connect write fifo
    fifo_full_ext    => spi_s_spi2uart_fifo_full  ,
    fifo_wr_en_ext   => spi_s_spi2uart_fifo_wr_en ,
    fifo_din_ext     => spi_s_spi2uart_fifo_din   ,

    fifo_loopback_en => uart2spi_fifo_loopback_en  
);

u_uart2spi_fifo: uart2spi_fifo port map (
    clk   => clk                 ,
    rst   => reset               ,
    din   => uart2spi_fifo_din   ,
    wr_en => uart2spi_fifo_wr_en ,
    rd_en => uart2spi_fifo_rd_en ,
    dout  => uart2spi_fifo_dout  ,
    full  => uart2spi_fifo_full  ,
    empty => uart2spi_fifo_empty  
);

u_spi_m: spi_m generic map (
    WIDTH => WIDTH
) port map (
    clk        => clk                       ,
    reset      => reset                     ,

    fifo_empty => spi_m_uart2spi_fifo_empty ,
    fifo_dout  => spi_m_uart2spi_fifo_dout  ,
    fifo_rd_en => spi_m_uart2spi_fifo_rd_en ,

    sck        => spi_m_sck_internal        ,
    mosi       => spi_m_mosi_internal       ,
    miso       => spi_m_miso_internal       ,
    ss         => spi_m_ss_internal          
);

u_spi_loopback: spi_loopback port map (
    -- interface with spi master
    spi_m_sck       => spi_m_sck_internal  ,
    spi_m_ss        => spi_m_ss_internal   ,
    spi_m_mosi      => spi_m_mosi_internal ,
    spi_m_miso      => spi_m_miso_internal ,

    -- interface with that needed connected to spi master
    spi_m_sck_ext   => spi_m_sck           ,
    spi_m_ss_ext    => spi_m_ss            ,
    spi_m_mosi_ext  => spi_m_mosi          ,
    spi_m_miso_ext  => spi_m_miso          ,

    -- interface with spi slave
    spi_s_sck       => spi_s_sck_internal  ,
    spi_s_ss        => spi_s_ss_internal   ,
    spi_s_mosi      => spi_s_mosi_internal ,
    spi_s_miso      => spi_s_miso_internal ,

    -- interface with that needed connected to spi slave
    spi_s_sck_ext   => spi_s_sck           ,
    spi_s_ss_ext    => spi_s_ss            ,
    spi_s_mosi_ext  => spi_s_mosi          ,
    spi_s_miso_ext  => spi_s_miso          ,

    -- control signal
    spi_loopback_en => spi_loopback_en      

);

u_spi_s: spi_s generic map (
    WIDTH => WIDTH
) port map (
    reset         => reset                  ,
                                   
    sck           => spi_s_sck_internal     ,
    mosi          => spi_s_mosi_internal    ,
    miso          => spi_s_miso_internal    ,
    ss            => spi_s_ss_internal      ,
                                   
    spi_done_tick => spi_done_tick ,
    spi_dout      => spi_dout       
);

u_spi2fifo_ctrl: spi2fifo_ctrl generic map (
    WIDTH => WIDTH
) port map (
    clk           => clk                       ,
    reset         => reset                     ,

    spi_done_tick => spi_done_tick             ,
    spi_dout      => spi_dout                  ,

    fifo_full     => spi_s_spi2uart_fifo_full  ,
    fifo_wr_en    => spi_s_spi2uart_fifo_wr_en ,
    fifo_din      => spi_s_spi2uart_fifo_din   ,

    e_fifo_full   => e_fifo_full                
);

u_spi2uart_fifo: spi2uart_fifo port map (
    clk   => clk                  ,
    rst   => reset                ,
    din   => spi2uart_fifo_din   ,
    wr_en => spi2uart_fifo_wr_en ,
    rd_en => spi2uart_fifo_rd_en ,
    dout  => spi2uart_fifo_dout  ,
    full  => spi2uart_fifo_full  ,
    empty => spi2uart_fifo_empty  
);

end arch;

