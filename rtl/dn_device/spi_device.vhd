library ieee;
use ieee.std_logic_1164.all;

entity spi_device is
generic (
    WIDTH : integer := 8 
);
port(
    clk              : in  std_logic                          ;
    reset            : in  std_logic                          ;

    -- spi slave interface
    spi_s_sck        : in  std_logic                          ;
    spi_s_ss         : in  std_logic                          ;
    spi_s_mosi       : in  std_logic                          ;
    spi_s_miso       : out std_logic                          ;

    -- spi slave fifo interface
    spi_s_fifo_empty_ext : out std_logic                          ;
    spi_s_fifo_rd_en_ext : in  std_logic                          ;
    spi_s_fifo_dout_ext  : out std_logic_vector(WIDTH-1 downto 0) ;

    -- spi master fifo interface
    spi_m_fifo_full_ext  : out std_logic                          ;
    spi_m_fifo_wr_en_ext : in  std_logic                          ;
    spi_m_fifo_din_ext   : in  std_logic_vector(WIDTH-1 downto 0) ;

    -- spi master interface
    spi_m_sck         : out std_logic                          ;
    spi_m_ss          : out std_logic                          ;
    spi_m_mosi        : out std_logic                          ;
    spi_m_miso        : in  std_logic                          ;
    spi_fifo_loopback : in  std_logic                           
);
end spi_device;

architecture arch of spi_device is
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
    fifo_din      : out std_logic_vector(WIDTH-1 downto 0)  
);
end component;

-- spi_s fifo
component spi_s_fifo is
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

-- spi_m fifo
component spi_m_fifo is
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

-- spi_m
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
end component;

signal spi_done_tick    : std_logic                          ;
signal spi_dout         : std_logic_vector(WIDTH-1 downto 0) ;

signal spi_s_din        : std_logic_vector(WIDTH-1 downto 0) ;
signal spi_s_wr_en      : std_logic                          ;
signal spi_s_full       : std_logic                          ;

signal spi_m_empty      : std_logic                          ;
signal spi_m_rd_en      : std_logic                          ;
signal spi_m_dout       : std_logic_vector(WIDTH-1 downto 0) ;

signal spi_s_fifo_empty : std_logic                          ;
signal spi_s_fifo_rd_en : std_logic                          ;
signal spi_s_fifo_dout  : std_logic_vector(WIDTH-1 downto 0) ;

signal spi_s_fifo_full  : std_logic                          ;
signal spi_s_fifo_wr_en : std_logic                          ;
signal spi_s_fifo_din   : std_logic_vector(WIDTH-1 downto 0) ;

signal spi_m_fifo_full  : std_logic                          ;
signal spi_m_fifo_wr_en : std_logic                          ;
signal spi_m_fifo_din   : std_logic_vector(WIDTH-1 downto 0) ;

signal spi_m_fifo_empty : std_logic                          ;
signal spi_m_fifo_rd_en : std_logic                          ;
signal spi_m_fifo_dout  : std_logic_vector(WIDTH-1 downto 0) ;

begin

-- mux for loopback
u_fifo_loopback: fifo_loopback generic map (
    WIDTH => WIDTH 
) port map (
    clk              => clk                     ,
    reset            => reset                   ,

    -- fifo interface to read fifo
    fifo_empty       => spi_s_fifo_empty        ,
    fifo_rd_en       => spi_s_fifo_rd_en        ,
    fifo_dout        => spi_s_fifo_dout         ,

    -- fifo interface needed to connect read fifo
    fifo_empty_ext   => spi_s_fifo_empty_ext    ,
    fifo_rd_en_ext   => spi_s_fifo_rd_en_ext    ,
    fifo_dout_ext    => spi_s_fifo_dout_ext     ,

    -- fifo interface to write fifo
    fifo_full        => spi_m_fifo_full         ,
    fifo_wr_en       => spi_m_fifo_wr_en        ,
    fifo_din         => spi_m_fifo_din          ,

    -- fifo interface needed to connect write fifo
    fifo_full_ext    => spi_m_fifo_full_ext     ,
    fifo_wr_en_ext   => spi_m_fifo_wr_en_ext    ,
    fifo_din_ext     => spi_m_fifo_din_ext      ,

    fifo_loopback_en => spi_fifo_loopback        
);

u_spi_s: spi_s generic map (
    WIDTH => WIDTH
) port map (
    reset         => reset         ,

    sck           => spi_s_sck     ,
    mosi          => spi_s_mosi    ,
    miso          => spi_s_miso    ,
    ss            => spi_s_ss      ,

    spi_done_tick => spi_done_tick ,
    spi_dout      => spi_dout       
);

u_spi2fifo_ctrl: spi2fifo_ctrl generic map (
    WIDTH => WIDTH
) port map (
    clk           => clk              ,
    reset         => reset            ,
                                        
    spi_done_tick => spi_done_tick    ,
    spi_dout      => spi_dout         ,
                                   
    fifo_full     => spi_s_fifo_full  ,
    fifo_wr_en    => spi_s_fifo_wr_en ,
    fifo_din      => spi_s_fifo_din    
);

u_spi_s_fifo: spi_s_fifo port map (
    clk   => clk              ,
    rst   => reset            ,
    din   => spi_s_fifo_din   ,
    wr_en => spi_s_fifo_wr_en ,
    rd_en => spi_s_fifo_rd_en ,
    dout  => spi_s_fifo_dout  ,
    full  => spi_s_fifo_full  ,
    empty => spi_s_fifo_empty  
);

u_spi_m_fifo: spi_m_fifo port map (
    clk   => clk              ,
    rst   => reset            ,
    din   => spi_m_fifo_din   ,
    wr_en => spi_m_fifo_wr_en ,
    rd_en => spi_m_fifo_rd_en ,
    dout  => spi_m_fifo_dout  ,
    full  => spi_m_fifo_full  ,
    empty => spi_m_fifo_empty  
);

u_spi_m: spi_m generic map (
    WIDTH => WIDTH
) port map (
    clk        => clk              ,
    reset      => reset            ,
                             
    fifo_empty => spi_m_fifo_empty ,
    fifo_dout  => spi_m_fifo_dout  ,
    fifo_rd_en => spi_m_fifo_rd_en ,
                             
    sck        => spi_m_sck        ,
    mosi       => spi_m_mosi       ,
    miso       => spi_m_miso       ,
    ss         => spi_m_ss          
);

end arch;

