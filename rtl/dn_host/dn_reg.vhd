library ieee;
use ieee.std_logic_1164.all;

entity dn_reg is
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
end dn_reg;

architecture arch of dn_reg is

signal ctrl                        : std_logic_vector(7 downto 0) ;
signal e_spi2uart_fifo_full_status : std_logic_vector(3 downto 0) ;
signal e_uart2spi_fifo_full_status : std_logic_vector(4 downto 0) ;

signal debug_en_reg                : std_logic                    ;

begin

-- addr 0
process(clk, reset)
begin
    if(reset = '1') then
        ctrl <= (others => '0');
    elsif(rising_edge(clk)) then
        if(reg_wr_en = '1' and reg_addr = "000") then
            ctrl <= reg_din;
        end if;
    end if;
end process;

---- addr 0xf0
--spi2uart_uart2spi_fifo_full <= spi2uart_fifo_full & uart2spi_fifo_full;

-- addr "110"
process(clk, reset)
begin
    if(reset = '1') then
        e_spi2uart_fifo_full_status <= (others => '0');
    elsif(rising_edge(clk)) then
        if(reg_wr_en = '1' and reg_addr = "110") then
            e_spi2uart_fifo_full_status <= e_spi2uart_fifo_full_status and (not reg_din(3 downto 0));
        else
            e_spi2uart_fifo_full_status <= e_spi2uart_fifo_full_status or e_spi2uart_fifo_full;
        end if;
    end if;
end process;

-- addr "111"
process(clk, reset)
begin
    if(reset = '1') then
        e_uart2spi_fifo_full_status <= (others => '0');
    elsif(rising_edge(clk)) then
        if(reg_wr_en = '1' and reg_addr = "111") then
            e_uart2spi_fifo_full_status <= e_uart2spi_fifo_full_status and (not reg_din(4 downto 0));
        else
            e_uart2spi_fifo_full_status <= e_uart2spi_fifo_full_status or e_uart2spi_fifo_full;
        end if;
    end if;
end process;

-- read register
process(reg_addr, ctrl, e_spi2uart_fifo_full_status, e_uart2spi_fifo_full_status)
begin
    case(reg_addr) is
        when "000" => reg_dout <= ctrl;
        when "110" => reg_dout <= "0000" & e_spi2uart_fifo_full_status;
        when "111" => reg_dout <= "000" & e_uart2spi_fifo_full_status;
        when others => reg_dout <= (others => '0');
    end case;
end process;

-- ctrl signal
debug_en_reg <= ctrl(0);
uart2spi_fifo_loopback_en <= ctrl(1) when debug_en_reg = '1' else '0';
spi_loopback_en <= ctrl(2) when debug_en_reg = '1' else '0';

-- observation signal
debug_en <= debug_en_reg;

end arch;

