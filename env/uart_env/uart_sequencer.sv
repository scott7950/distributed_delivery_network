`ifndef __UART_SEQUENCER_SV__
`define __UART_SEQUENCER_SV__

`include "uart_transaction.sv"

class uart_sequencer extends uvm_sequencer #(uart_transaction);

`uvm_component_utils(uart_sequencer)

function new(string name, uvm_component parent=null);
    super.new(name, parent);
endfunction

endclass

`endif

