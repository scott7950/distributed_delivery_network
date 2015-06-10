`ifndef __UART_AGENT_SV__
`define __UART_AGENT_SV__

`include "uart_sequencer.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"

class uart_agent extends uvm_agent;
uart_sequencer uart_sqr;
uart_driver    uart_drv;
uart_monitor   uart_mon;

`uvm_component_utils_begin(uart_agent)
    `uvm_field_object(uart_sqr, UVM_ALL_ON)
    `uvm_field_object(uart_drv, UVM_ALL_ON)
    `uvm_field_object(uart_mon, UVM_ALL_ON)
`uvm_component_utils_end

function new(string name, uvm_component parent = null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    uart_sqr = uart_sequencer::type_id::create("uart_sqr", this);
    uart_drv = uart_driver::type_id::create("uart_drv", this);
    uart_mon = uart_monitor::type_id::create("uart_mon", this);
endfunction

virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    uart_drv.seq_item_port.connect(uart_sqr.seq_item_export);
endfunction

endclass

`endif

