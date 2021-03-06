library ieee;
use ieee.std_logic_1164.all;

entity spi_m_fifo is
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
end spi_m_fifo;

architecture arch of spi_m_fifo is
component fifo_generator_1 is
port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    din   : in  std_logic_vector(7 downto 0);
    wr_en : in  std_logic;
    rd_en : in  std_logic;
    dout  : out std_logic_vector(7 downto 0);
    full  : out std_logic;
    empty : out std_logic
);
end component;

begin

u_fifo_generator_1: fifo_generator_1 port map (
    clk   => clk   ,
    rst   => rst   ,
    din   => din   ,
    wr_en => wr_en ,
    rd_en => rd_en ,
    dout  => dout  ,
    full  => full  ,
    empty => empty  
);

end arch;

