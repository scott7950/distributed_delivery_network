library ieee;
use ieee.std_logic_1164.all;

entity spi_loopback is
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
end spi_loopback;

architecture arch of spi_loopback is
begin

spi_m_sck_ext  <= spi_m_sck when spi_loopback_en = '0' else '0'; 
spi_m_ss_ext   <= spi_m_ss when spi_loopback_en = '0' else '0';
spi_m_mosi_ext <= spi_m_mosi when spi_loopback_en = '0' else '0';
spi_m_miso     <= spi_m_miso_ext when spi_loopback_en = '0' else spi_s_miso;

spi_s_sck      <= spi_s_sck_ext when spi_loopback_en = '0' else spi_m_sck;  
spi_s_ss       <= spi_s_ss_ext when spi_loopback_en = '0' else spi_m_ss;   
spi_s_mosi     <= spi_s_mosi_ext when spi_loopback_en = '0' else spi_m_mosi; 
spi_s_miso_ext <= spi_s_miso when spi_loopback_en = '0' else '0'; 

end arch;

