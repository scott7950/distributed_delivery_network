library ieee;
use ieee.std_logic_1164.all;

entity virtual_top is
generic (
    UART_BAUD_WIDTH : integer := 10 ;
    UART_BAUD_CNT   : integer := 54 ;
    WIDTH           : integer := 8  ;
    SB_TICK         : integer := 16  
);
port (
    clk                : in  std_logic                    ;
    reset              : in  std_logic                    ;
   
    rx                 : in  std_logic                    ;
    tx                 : out std_logic                    ;

    dn_host_debug_en   : in  std_logic                    ;
    dn_device_debug_en : in  std_logic                    ;
    ctrl               : in  std_logic_vector(5 downto 0) ;
    data_obs           : out std_logic_vector(7 downto 0) 

);
end virtual_top;

architecture arch of virtual_top is
component dn_host is
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
end component;

component dn_device is
generic (
    WIDTH : integer := 8 
);
port(
    clk               : in  std_logic ;
    reset             : in  std_logic ;

    -- spi0 slave interface
    spi_s0_sck        : in  std_logic ;
    spi_s0_ss         : in  std_logic ;
    spi_s0_mosi       : in  std_logic ;
    spi_s0_miso       : out std_logic ;

    -- spi1 slave interface
    spi_s1_sck        : in  std_logic ;
    spi_s1_ss         : in  std_logic ;
    spi_s1_mosi       : in  std_logic ;
    spi_s1_miso       : out std_logic ;

    -- spi2 slave interface
    spi_s2_sck        : in  std_logic ;
    spi_s2_ss         : in  std_logic ;
    spi_s2_mosi       : in  std_logic ;
    spi_s2_miso       : out std_logic ;

    -- spi3 slave interface
    spi_s3_sck        : in  std_logic ;
    spi_s3_ss         : in  std_logic ;
    spi_s3_mosi       : in  std_logic ;
    spi_s3_miso       : out std_logic ;

    -- spi0 master interface
    spi_m0_sck        : out std_logic ;
    spi_m0_ss         : out std_logic ;
    spi_m0_mosi       : out std_logic ;
    spi_m0_miso       : in  std_logic ;

    -- spi1 master interface
    spi_m1_sck        : out std_logic ;
    spi_m1_ss         : out std_logic ;
    spi_m1_mosi       : out std_logic ;
    spi_m1_miso       : in  std_logic ;

    -- spi2 master interface
    spi_m2_sck        : out std_logic ;
    spi_m2_ss         : out std_logic ;
    spi_m2_mosi       : out std_logic ;
    spi_m2_miso       : in  std_logic ;

    -- spi3 master interface
    spi_m3_sck        : out std_logic ;
    spi_m3_ss         : out std_logic ;
    spi_m3_mosi       : out std_logic ;
    spi_m3_miso       : in  std_logic ;

    debug_en          : in  std_logic                    ;
    ctrl              : in  std_logic_vector(6 downto 0) ;
    data_obs          : out std_logic_vector(7 downto 0)
);
end component;

signal spi_m0_sck  : std_logic                    ;
signal spi_m0_ss   : std_logic                    ;
signal spi_m0_mosi : std_logic                    ;
signal spi_m0_miso : std_logic                    ;

signal spi_m1_sck  : std_logic                    ;
signal spi_m1_ss   : std_logic                    ;
signal spi_m1_mosi : std_logic                    ;
signal spi_m1_miso : std_logic                    ;

signal spi_m2_sck  : std_logic                    ;
signal spi_m2_ss   : std_logic                    ;
signal spi_m2_mosi : std_logic                    ;
signal spi_m2_miso : std_logic                    ;

signal spi_m3_sck  : std_logic                    ;
signal spi_m3_ss   : std_logic                    ;
signal spi_m3_mosi : std_logic                    ;
signal spi_m3_miso : std_logic                    ;

signal spi_s0_sck  : std_logic                    ;
signal spi_s0_ss   : std_logic                    ;
signal spi_s0_mosi : std_logic                    ;
signal spi_s0_miso : std_logic                    ;

signal spi_s1_sck  : std_logic                    ;
signal spi_s1_ss   : std_logic                    ;
signal spi_s1_mosi : std_logic                    ;
signal spi_s1_miso : std_logic                    ;

signal spi_s2_sck  : std_logic                    ;
signal spi_s2_ss   : std_logic                    ;
signal spi_s2_mosi : std_logic                    ;
signal spi_s2_miso : std_logic                    ;

signal spi_s3_sck  : std_logic                    ;
signal spi_s3_ss   : std_logic                    ;
signal spi_s3_mosi : std_logic                    ;
signal spi_s3_miso : std_logic                    ;

signal dn_host_ctrl        : std_logic_vector(6 downto 0) ;
signal dn_host_data_obs    : std_logic_vector(7 downto 0) ;

signal dn_device_ctrl      : std_logic_vector(6 downto 0) ;
signal dn_device_data_obs  : std_logic_vector(7 downto 0) ;

begin

-- debug signal
-- dn_host_debug_en <= debug_en;
-- dn_device_debug_en <= debug_en;
dn_host_ctrl(2 downto 0) <= ctrl(2 downto 0);
dn_device_ctrl(0) <= ctrl(3);
data_obs <= dn_host_data_obs;

u_dn_host: dn_host generic map (
    UART_BAUD_WIDTH => UART_BAUD_WIDTH ,
    UART_BAUD_CNT   => UART_BAUD_CNT   ,
    WIDTH           => WIDTH           ,
    SB_TICK         => SB_TICK          
) port map (
    clk         => clk         ,
    reset       => reset       ,
                               
    rx          => rx          ,
    tx          => tx          ,
                               
    spi_m0_sck  => spi_m0_sck  ,
    spi_m0_ss   => spi_m0_ss   ,
    spi_m0_mosi => spi_m0_mosi ,
    spi_m0_miso => spi_m0_miso ,
                               
    spi_m1_sck  => spi_m1_sck  ,
    spi_m1_ss   => spi_m1_ss   ,
    spi_m1_mosi => spi_m1_mosi ,
    spi_m1_miso => spi_m1_miso ,
                               
    spi_m2_sck  => spi_m2_sck  ,
    spi_m2_ss   => spi_m2_ss   ,
    spi_m2_mosi => spi_m2_mosi ,
    spi_m2_miso => spi_m2_miso ,
                               
    spi_m3_sck  => spi_m3_sck  ,
    spi_m3_ss   => spi_m3_ss   ,
    spi_m3_mosi => spi_m3_mosi ,
    spi_m3_miso => spi_m3_miso ,
                               
    spi_s0_sck  => spi_s0_sck  ,
    spi_s0_ss   => spi_s0_ss   ,
    spi_s0_mosi => spi_s0_mosi ,
    spi_s0_miso => spi_s0_miso ,
                               
    spi_s1_sck  => spi_s1_sck  ,
    spi_s1_ss   => spi_s1_ss   ,
    spi_s1_mosi => spi_s1_mosi ,
    spi_s1_miso => spi_s1_miso ,
                               
    spi_s2_sck  => spi_s2_sck  ,
    spi_s2_ss   => spi_s2_ss   ,
    spi_s2_mosi => spi_s2_mosi ,
    spi_s2_miso => spi_s2_miso ,
                               
    spi_s3_sck  => spi_s3_sck  ,
    spi_s3_ss   => spi_s3_ss   ,
    spi_s3_mosi => spi_s3_mosi ,
    spi_s3_miso => spi_s3_miso ,

    debug_en    => dn_host_debug_en ,
    ctrl        => dn_host_ctrl     ,
    data_obs    => dn_host_data_obs    
);

u_dn_device: dn_device generic map (
    WIDTH => WIDTH
) port map (
    clk            => clk            ,
    reset          => reset          ,
                                     
    spi_s0_sck     => spi_m0_sck  ,
    spi_s0_ss      => spi_m0_ss   ,
    spi_s0_mosi    => spi_m0_mosi ,
    spi_s0_miso    => spi_m0_miso ,
                                  
    spi_s1_sck     => spi_m1_sck  ,
    spi_s1_ss      => spi_m1_ss   ,
    spi_s1_mosi    => spi_m1_mosi ,
    spi_s1_miso    => spi_m1_miso ,
                                  
    spi_s2_sck     => spi_m2_sck  ,
    spi_s2_ss      => spi_m2_ss   ,
    spi_s2_mosi    => spi_m2_mosi ,
    spi_s2_miso    => spi_m2_miso ,
                                  
    spi_s3_sck     => spi_m3_sck  ,
    spi_s3_ss      => spi_m3_ss   ,
    spi_s3_mosi    => spi_m3_mosi ,
    spi_s3_miso    => spi_m3_miso ,
                                  
    spi_m0_sck     => spi_s0_sck  ,
    spi_m0_ss      => spi_s0_ss   ,
    spi_m0_mosi    => spi_s0_mosi ,
    spi_m0_miso    => spi_s0_miso ,
                                  
    spi_m1_sck     => spi_s1_sck  ,
    spi_m1_ss      => spi_s1_ss   ,
    spi_m1_mosi    => spi_s1_mosi ,
    spi_m1_miso    => spi_s1_miso ,
                                  
    spi_m2_sck     => spi_s2_sck  ,
    spi_m2_ss      => spi_s2_ss   ,
    spi_m2_mosi    => spi_s2_mosi ,
    spi_m2_miso    => spi_s2_miso ,
                                  
    spi_m3_sck     => spi_s3_sck  ,
    spi_m3_ss      => spi_s3_ss   ,
    spi_m3_mosi    => spi_s3_mosi ,
    spi_m3_miso    => spi_s3_miso ,

    debug_en       => dn_device_debug_en ,
    ctrl           => dn_device_ctrl     ,
    data_obs       => dn_device_data_obs    
);
end arch;

