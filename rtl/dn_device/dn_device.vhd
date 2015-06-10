library ieee;
use ieee.std_logic_1164.all;

entity dn_device is
generic (
    WIDTH : integer := 8 
);
port(
    clk               : in  std_logic                    ;
    reset             : in  std_logic                    ;

    -- spi0 slave interface
    spi_s0_sck        : in  std_logic                    ;
    spi_s0_ss         : in  std_logic                    ;
    spi_s0_mosi       : in  std_logic                    ;
    spi_s0_miso       : out std_logic                    ;

    -- spi1 slave interface
    spi_s1_sck        : in  std_logic                    ;
    spi_s1_ss         : in  std_logic                    ;
    spi_s1_mosi       : in  std_logic                    ;
    spi_s1_miso       : out std_logic                    ;

    -- spi2 slave interface
    spi_s2_sck        : in  std_logic                    ;
    spi_s2_ss         : in  std_logic                    ;
    spi_s2_mosi       : in  std_logic                    ;
    spi_s2_miso       : out std_logic                    ;

    -- spi3 slave interface
    spi_s3_sck        : in  std_logic                    ;
    spi_s3_ss         : in  std_logic                    ;
    spi_s3_mosi       : in  std_logic                    ;
    spi_s3_miso       : out std_logic                    ;

    -- spi0 master interface
    spi_m0_sck        : out std_logic                    ;
    spi_m0_ss         : out std_logic                    ;
    spi_m0_mosi       : out std_logic                    ;
    spi_m0_miso       : in  std_logic                    ;

    -- spi1 master interface
    spi_m1_sck        : out std_logic                    ;
    spi_m1_ss         : out std_logic                    ;
    spi_m1_mosi       : out std_logic                    ;
    spi_m1_miso       : in  std_logic                    ;

    -- spi2 master interface
    spi_m2_sck        : out std_logic                    ;
    spi_m2_ss         : out std_logic                    ;
    spi_m2_mosi       : out std_logic                    ;
    spi_m2_miso       : in  std_logic                    ;

    -- spi3 master interface
    spi_m3_sck        : out std_logic                    ;
    spi_m3_ss         : out std_logic                    ;
    spi_m3_mosi       : out std_logic                    ;
    spi_m3_miso       : in  std_logic                    ;

    debug_en          : in  std_logic                    ;
    ctrl              : in  std_logic_vector(6 downto 0) ;
    data_obs          : out std_logic_vector(7 downto 0)
);
end dn_device;

architecture arch of dn_device is
component spi_device is
generic (
    WIDTH : integer := 8 
);
port(
    clk                  : in  std_logic                          ;
    reset                : in  std_logic                          ;

    -- spi slave interface
    spi_s_sck            : in  std_logic                          ;
    spi_s_ss             : in  std_logic                          ;
    spi_s_mosi           : in  std_logic                          ;
    spi_s_miso           : out std_logic                          ;

    -- spi slave fifo interface
    spi_s_fifo_empty_ext : out std_logic                          ;
    spi_s_fifo_rd_en_ext : in  std_logic                          ;
    spi_s_fifo_dout_ext  : out std_logic_vector(WIDTH-1 downto 0) ;

    -- spi master fifo interface
    spi_m_fifo_full_ext  : out std_logic                          ;
    spi_m_fifo_wr_en_ext : in  std_logic                          ;
    spi_m_fifo_din_ext   : in  std_logic_vector(WIDTH-1 downto 0) ;

    -- spi master interface
    spi_m_sck            : out std_logic                          ;
    spi_m_ss             : out std_logic                          ;
    spi_m_mosi           : out std_logic                          ;
    spi_m_miso           : in  std_logic                          ;

    spi_fifo_loopback    : in  std_logic                           
);
end component;

-- spi0 slave fifo interface
signal spi_s0_fifo_empty : std_logic                          ;
signal spi_s0_fifo_rd_en : std_logic                          ;
signal spi_s0_fifo_dout  : std_logic_vector(WIDTH-1 downto 0) ;

-- spi0 master fifo interface
signal spi_m0_fifo_full  : std_logic                          ;
signal spi_m0_fifo_wr_en : std_logic                          ;
signal spi_m0_fifo_din   : std_logic_vector(WIDTH-1 downto 0) ;

-- spi1 slave fifo interface
signal spi_s1_fifo_empty : std_logic                          ;
signal spi_s1_fifo_rd_en : std_logic                          ;
signal spi_s1_fifo_dout  : std_logic_vector(WIDTH-1 downto 0) ;

-- spi1 master fifo interface
signal spi_m1_fifo_full  : std_logic                          ;
signal spi_m1_fifo_wr_en : std_logic                          ;
signal spi_m1_fifo_din   : std_logic_vector(WIDTH-1 downto 0) ;

-- spi2 slave fifo interface
signal spi_s2_fifo_empty : std_logic                          ;
signal spi_s2_fifo_rd_en : std_logic                          ;
signal spi_s2_fifo_dout  : std_logic_vector(WIDTH-1 downto 0) ;

-- spi2 master fifo interface
signal spi_m2_fifo_full  : std_logic                          ;
signal spi_m2_fifo_wr_en : std_logic                          ;
signal spi_m2_fifo_din   : std_logic_vector(WIDTH-1 downto 0) ;

-- spi3 slave fifo interface
signal spi_s3_fifo_empty : std_logic                          ;
signal spi_s3_fifo_rd_en : std_logic                          ;
signal spi_s3_fifo_dout  : std_logic_vector(WIDTH-1 downto 0) ;

-- spi3 master fifo interface
signal spi_m3_fifo_full  : std_logic                          ;
signal spi_m3_fifo_wr_en : std_logic                          ;
signal spi_m3_fifo_din   : std_logic_vector(WIDTH-1 downto 0) ;

-- debug signal
signal spi_fifo_loopback : std_logic                          ;

begin

-- debug signal
spi_fifo_loopback <= ctrl(0) when debug_en = '1' else '0';

u_spi_device0: spi_device generic map ( 
    WIDTH => WIDTH 
) port map (
    clk               => clk                ,
    reset             => reset              ,
                                           
    spi_s_sck         => spi_s0_sck         ,
    spi_s_ss          => spi_s0_ss          ,
    spi_s_mosi        => spi_s0_mosi        ,
    spi_s_miso        => spi_s0_miso        ,
                                           
    spi_s_fifo_empty_ext  => spi_s0_fifo_empty  ,
    spi_s_fifo_rd_en_ext  => spi_s0_fifo_rd_en  ,
    spi_s_fifo_dout_ext   => spi_s0_fifo_dout   ,
                                           
    spi_m_fifo_full_ext   => spi_m0_fifo_full   ,
    spi_m_fifo_wr_en_ext  => spi_m0_fifo_wr_en  ,
    spi_m_fifo_din_ext    => spi_m0_fifo_din    ,
                                           
    spi_m_sck         => spi_m0_sck         ,
    spi_m_ss          => spi_m0_ss          ,
    spi_m_mosi        => spi_m0_mosi        ,
    spi_m_miso        => spi_m0_miso        ,

    spi_fifo_loopback => spi_fifo_loopback   
);

u_spi_device1: spi_device generic map ( 
    WIDTH => WIDTH 
) port map (
    clk                  => clk                ,
    reset                => reset              ,
                                              
    spi_s_sck            => spi_s1_sck         ,
    spi_s_ss             => spi_s1_ss          ,
    spi_s_mosi           => spi_s1_mosi        ,
    spi_s_miso           => spi_s1_miso        ,

    spi_s_fifo_empty_ext => spi_s1_fifo_empty  ,
    spi_s_fifo_rd_en_ext => spi_s1_fifo_rd_en  ,
    spi_s_fifo_dout_ext  => spi_s1_fifo_dout   ,

    spi_m_fifo_full_ext  => spi_m1_fifo_full   ,
    spi_m_fifo_wr_en_ext => spi_m1_fifo_wr_en  ,
    spi_m_fifo_din_ext   => spi_m1_fifo_din    ,

    spi_m_sck            => spi_m1_sck         ,
    spi_m_ss             => spi_m1_ss          ,
    spi_m_mosi           => spi_m1_mosi        ,
    spi_m_miso           => spi_m1_miso        ,

    spi_fifo_loopback    => spi_fifo_loopback   
);

u_spi_device2: spi_device generic map ( 
    WIDTH => WIDTH 
) port map (
    clk                  => clk                ,
    reset                => reset              ,
                                              
    spi_s_sck            => spi_s2_sck         ,
    spi_s_ss             => spi_s2_ss          ,
    spi_s_mosi           => spi_s2_mosi        ,
    spi_s_miso           => spi_s2_miso        ,

    spi_s_fifo_empty_ext => spi_s2_fifo_empty  ,
    spi_s_fifo_rd_en_ext => spi_s2_fifo_rd_en  ,
    spi_s_fifo_dout_ext  => spi_s2_fifo_dout   ,

    spi_m_fifo_full_ext  => spi_m2_fifo_full   ,
    spi_m_fifo_wr_en_ext => spi_m2_fifo_wr_en  ,
    spi_m_fifo_din_ext   => spi_m2_fifo_din    ,

    spi_m_sck            => spi_m2_sck         ,
    spi_m_ss             => spi_m2_ss          ,
    spi_m_mosi           => spi_m2_mosi        ,
    spi_m_miso           => spi_m2_miso        ,

    spi_fifo_loopback    => spi_fifo_loopback   
);

u_spi_device3: spi_device generic map ( 
    WIDTH => WIDTH 
) port map (
    clk                  => clk                ,
    reset                => reset              ,
                                              
    spi_s_sck            => spi_s3_sck         ,
    spi_s_ss             => spi_s3_ss          ,
    spi_s_mosi           => spi_s3_mosi        ,
    spi_s_miso           => spi_s3_miso        ,

    spi_s_fifo_empty_ext => spi_s3_fifo_empty  ,
    spi_s_fifo_rd_en_ext => spi_s3_fifo_rd_en  ,
    spi_s_fifo_dout_ext  => spi_s3_fifo_dout   ,

    spi_m_fifo_full_ext  => spi_m3_fifo_full   ,
    spi_m_fifo_wr_en_ext => spi_m3_fifo_wr_en  ,
    spi_m_fifo_din_ext   => spi_m3_fifo_din    ,

    spi_m_sck            => spi_m3_sck         ,
    spi_m_ss             => spi_m3_ss          ,
    spi_m_mosi           => spi_m3_mosi        ,
    spi_m_miso           => spi_m3_miso        ,

    spi_fifo_loopback    => spi_fifo_loopback   
);

end arch;

