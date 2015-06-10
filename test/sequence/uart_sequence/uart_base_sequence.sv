`ifndef _UART_BASE_SEQUENCE_SV__
`define _UART_BASE_SEQUENCE_SV__

`include "uart_transaction.sv"

virtual class uart_base_sequence extends uvm_sequence #(uart_transaction);

function new(string name="uart_base_sequence");
    super.new(name);
    set_automatic_phase_objection(1);
endfunction
  
endclass

class send_one_uart_seq extends uart_base_sequence;
rand uart_transaction::cmd_type uart_cmd_type ;
rand logic [2:0]                addr          ;

function new(string name="send_one_uart_seq");
    super.new(name);
endfunction
  
`uvm_object_utils(send_one_uart_seq)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_cmd_type; req.addr == addr;} )
endtask
  
endclass

//sequence uart_write_fifo_unicast_sequence
class uart_write_fifo_unicast_sequence extends uart_base_sequence;

function new(string name="uart_write_fifo_unicast_sequence");
    super.new(name);
endfunction
  
`uvm_object_utils(uart_write_fifo_unicast_sequence)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_transaction::WRITE; req.uart_access_type == uart_transaction::FIFO; req.uart_bc_type == uart_transaction::UNICAST; req.payload.size() == 1;} )
endtask
  
endclass

//sequence uart_write_fifo_burst_unicast_sequence
class uart_write_fifo_burst_unicast_sequence extends uart_base_sequence;

function new(string name="uart_write_fifo_burst_unicast_sequence");
    super.new(name);
endfunction
  
`uvm_object_utils(uart_write_fifo_burst_unicast_sequence)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_transaction::WRITE; req.uart_access_type == uart_transaction::FIFO; req.uart_bc_type == uart_transaction::UNICAST;} )
endtask
  
endclass

//sequence uart_write_fifo_broadcast_sequence 
class uart_write_fifo_broadcast_sequence extends uart_base_sequence;

function new(string name="uart_write_fifo_broadcast_sequence");
    super.new(name);
endfunction
  
`uvm_object_utils(uart_write_fifo_broadcast_sequence)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_transaction::WRITE; req.uart_access_type == uart_transaction::FIFO; req.uart_bc_type == uart_transaction::BROADCAST; req.payload.size() == 1;} )
endtask
  
endclass

//uart_write_fifo_burst_broadcast_sequence
class uart_write_fifo_burst_broadcast_sequence extends uart_base_sequence;

function new(string name="uart_write_fifo_burst_broadcast_sequence");
    super.new(name);
endfunction
  
`uvm_object_utils(uart_write_fifo_burst_broadcast_sequence)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_transaction::WRITE; req.uart_access_type == uart_transaction::FIFO; req.uart_bc_type == uart_transaction::BROADCAST;} )
endtask
  
endclass

//sequence uart_write_fifo_randcast_sequence 
class uart_write_fifo_randcast_sequence extends uart_base_sequence;

function new(string name="uart_write_fifo_randcast_sequence");
    super.new(name);
endfunction
  
`uvm_object_utils(uart_write_fifo_randcast_sequence)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_transaction::WRITE; req.uart_access_type == uart_transaction::FIFO; req.payload.size() == 1;} )
endtask
  
endclass

//uart_write_fifo_burst_randcast_sequence
class uart_write_fifo_burst_randcast_sequence extends uart_base_sequence;

function new(string name="uart_write_fifo_burst_randcast_sequence");
    super.new(name);
endfunction
  
`uvm_object_utils(uart_write_fifo_burst_randcast_sequence)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_transaction::WRITE; req.uart_access_type == uart_transaction::FIFO;} )
endtask
  
endclass

//uart_read_fifo_sequence
class uart_read_fifo_sequence extends uart_base_sequence;

function new(string name="uart_read_fifo_sequence");
    super.new(name);
endfunction
  
`uvm_object_utils(uart_read_fifo_sequence)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_transaction::READ;  req.uart_access_type == uart_transaction::FIFO;} )
endtask

endclass

//sequence uart_write_test_reg_sequence 
class uart_write_test_reg_sequence extends uart_base_sequence;

function new(string name="uart_write_test_reg_sequence");
    super.new(name);
endfunction
  
`uvm_object_utils(uart_write_test_reg_sequence)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_transaction::WRITE; req.uart_access_type == uart_transaction::REG; req.addr == 0;} )
endtask
  
endclass

//sequence uart_read_test_reg_sequence 
class uart_read_test_reg_sequence extends uart_base_sequence;

function new(string name="uart_read_test_reg_sequence");
    super.new(name);
endfunction
  
`uvm_object_utils(uart_read_test_reg_sequence)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_transaction::READ; req.uart_access_type == uart_transaction::REG; req.addr == 0;} )
endtask
  
endclass

//sequence uart_uart2spi_fifo_loopback_en_sequence
//uart2spi_fifo_loopback_en
class uart_uart2spi_fifo_loopback_en_sequence extends uart_base_sequence;

function new(string name="uart_uart2spi_fifo_loopback_en_sequence");
    super.new(name);
endfunction
  
`uvm_object_utils(uart_uart2spi_fifo_loopback_en_sequence)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_transaction::WRITE; req.uart_access_type == uart_transaction::REG; req.addr == 0; req.payload[0]==8'h3;} )

    //uvm_sequence_base __seq;
    //`uvm_create_on(req, m_sequencer)
    //if(!$cast(__seq, req)) start_item(req, -1);
    //if ((__seq == null || !__seq.do_not_randomize) && !req.randomize() with {req.uart_cmd_type == uart_transaction::WRITE; req.uart_access_type == uart_transaction::REG; req.addr == 0;}) begin
    //    `uvm_warning("RNDFLD", "Randomization failed in uvm_do_with action")
    //end
    //if (!$cast(__seq,req)) finish_item(req, -1);
    //else __seq.start(m_sequencer, this, -1, 0);
endtask
  
endclass

//sequence uart_spi_loopback_en_sequence
//spi_loopback_en
class uart_spi_loopback_en_sequence extends uart_base_sequence;

function new(string name="uart_spi_loopback_en_sequence");
    super.new(name);
endfunction
  
`uvm_object_utils(uart_spi_loopback_en_sequence)

virtual task body();
    `uvm_do_with(req, {req.uart_cmd_type == uart_transaction::WRITE; req.uart_access_type == uart_transaction::REG; req.addr == 0; req.payload[0]==8'h5;} )
endtask
  
endclass

`endif

