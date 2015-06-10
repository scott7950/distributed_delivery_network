`ifndef __ENV_SV__
`define __ENV_SV__

`include "uart_env.sv"
`include "system_virtual_sequencer.sv"

class env extends uvm_env;

uart_env u_uart_env;
system_virtual_sequencer sys_vir_sqr;

`uvm_component_utils(env)

function new(string name, uvm_component parent = null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    u_uart_env = uart_env::type_id::create("u_uart_env", this);
    sys_vir_sqr = system_virtual_sequencer::type_id::create("sys_vir_sqr", this);
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    sys_vir_sqr.uart_sqr = u_uart_env.uart_agt.uart_sqr;
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask

endclass

`endif

