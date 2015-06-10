`ifndef __UART_ENV_SV__
`define __UART_ENV_SV__

`include "uart_agent.sv"
`include "uart_scoreboard.sv"

class uart_env extends uvm_env;

uart_agent      uart_agt;
uart_scoreboard uart_sb;

virtual uart_interface uart_vif;

`uvm_component_utils(uart_env)

function new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uart_agt = uart_agent::type_id::create("uart_agt", this);
    uart_sb = uart_scoreboard::type_id::create("uart_sb", this);
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    uart_agt.uart_drv.drv2sb_port.connect(uart_sb.drv2sb_port);
    uart_agt.uart_mon.mon2sb_port.connect(uart_sb.mon2sb_port);
endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask

endclass

`endif

