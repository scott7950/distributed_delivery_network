`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uart_interface.svi"
`include "test.sv"

module top;
parameter clock_cycle = 10;

parameter UART_BAUD_WIDTH = 10 ;
parameter UART_BAUD_CNT   = 10 ;
parameter WIDTH           = 8  ;
parameter SB_TICK         = 16 ;

logic clk;
logic reset;

logic       dn_host_debug_en   ;
logic       dn_device_debug_en ;
logic [5:0] ctrl               ;

uart_interface uart_intf(clk, reset);

virtual_top #(
    .UART_BAUD_WIDTH (UART_BAUD_WIDTH ) ,
    .UART_BAUD_CNT   (UART_BAUD_CNT   ) ,
    .WIDTH           (WIDTH           ) ,
    .SB_TICK         (SB_TICK         )  
) u_virtual_top (
    .clk                ( clk                ) ,
    .reset              ( reset              ) ,

    .rx                 ( uart_intf.tx       ) ,
    .tx                 ( uart_intf.rx       ) ,

    .dn_host_debug_en   ( dn_host_debug_en   ) ,
    .dn_device_debug_en ( dn_device_debug_en ) ,
    .ctrl               ( ctrl               ) ,
    .data_obs           ( uart_intf.data_obs )  

);

initial begin
    $timeformat(-9, 1, "ns", 10);
    clk = 0;
    forever begin
        #(clock_cycle/2) clk = ~clk;
    end
end

initial begin
    reset = 1'b0;
    repeat(10) @(posedge clk);
    reset = 1'b1;
    repeat(10) @(posedge clk);
    reset = 1'b0;
end

initial begin
    uvm_config_db#(int)::set(uvm_root::get(), "*", "uart_tick_cycle", UART_BAUD_CNT);
    uvm_config_db#(int)::set(uvm_root::get(), "*", "num_of_uart_sample", SB_TICK);
    uvm_config_db#(virtual uart_interface)::set(uvm_root::get(), "*", "uart_vif", uart_intf);

    //loopback for device fifo is always enabled
    dn_host_debug_en <= 1'b0;
    dn_device_debug_en <= 1'b1;
    ctrl[2:0] <= 3'h0;
    ctrl[3] <= 1'b1;
    ctrl[5:4] <= 2'h0;

    run_test();
end

`ifdef WAVE_ON
initial begin
    //$dumpfile("wave.vcd");
    //$dumpvars(0, top);
end
`endif

endmodule

