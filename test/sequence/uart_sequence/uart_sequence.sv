`ifndef __uart_send_random_sequence_SV__
`define __uart_send_random_sequence_SV__

`include "uart_base_sequence.sv"

class uart_send_random_sequence extends uart_base_sequence;

int itr = 10;
send_one_uart_seq uart_seq;
uart_read_fifo_sequence uart_read_fifo_seq;

`uvm_declare_p_sequencer(system_virtual_sequencer)

`uvm_object_utils(uart_send_random_sequence)

function new(string name="uart_send_random_sequence");
    super.new(name);
endfunction

virtual task body();
    //void'(uvm_config_db#(int)::get(null,get_full_name(),"itr", itr));
    `uvm_info(get_type_name(), $sformatf("%s starting...itr = %0d", get_sequence_path(), itr), UVM_NONE);

    uart_seq = send_one_uart_seq::type_id::create("uart_seq");
    uart_read_fifo_seq = uart_read_fifo_sequence::type_id::create("uart_read_fifo_seq");

    for(int i = 0; i < itr; i++) begin
        `uvm_do_on(uart_seq, p_sequencer.uart_sqr)
        //`uvm_do_on_with(uart_seq, p_sequencer.uart_sqr, {uart_seq.uart_cmd_type == uart_transaction::READ; uart_seq.addr == 8'hff;})
        `uvm_do_on(uart_read_fifo_seq, p_sequencer.uart_sqr)


        //uart_seq.randomize() with {uart_seq.uart_cmd_type == uart_transaction::READ; uart_seq.addr == 8'hff;};
        //uart_seq.start(p_sequencer.uart_sqr);
    end
endtask : body

endclass

//uart_multiple_write_fifo_unicast_sequence
class uart_multiple_write_fifo_unicast_sequence extends uart_base_sequence;

int itr = 10;
uart_write_fifo_unicast_sequence uart_write_fifo_unicast_seq;
uart_read_fifo_sequence uart_read_fifo_seq;

`uvm_declare_p_sequencer(system_virtual_sequencer)

`uvm_object_utils(uart_multiple_write_fifo_unicast_sequence)

function new(string name="uart_multiple_write_fifo_unicast_sequence");
    super.new(name);
endfunction

virtual task body();
    //void'(uvm_config_db#(int)::get(null,get_full_name(),"itr", itr));
    `uvm_info(get_type_name(), $sformatf("%s starting...itr = %0d", get_sequence_path(), itr), UVM_NONE);

    uart_write_fifo_unicast_seq = uart_write_fifo_unicast_sequence::type_id::create("uart_write_fifo_burst_unicast_seq");
    uart_read_fifo_seq = uart_read_fifo_sequence::type_id::create("uart_read_fifo_seq");

    for(int i = 0; i < itr; i++) begin
        `uvm_do_on(uart_write_fifo_unicast_seq, p_sequencer.uart_sqr)
        `uvm_do_on(uart_read_fifo_seq, p_sequencer.uart_sqr)
    end
endtask : body

endclass

//uart_multiple_write_fifo_burst_unicast_sequence
class uart_multiple_write_fifo_burst_unicast_sequence extends uart_base_sequence;

int itr = 10;
uart_write_fifo_burst_unicast_sequence uart_write_fifo_burst_unicast_seq;
uart_read_fifo_sequence uart_read_fifo_seq;

`uvm_declare_p_sequencer(system_virtual_sequencer)

`uvm_object_utils(uart_multiple_write_fifo_burst_unicast_sequence)

function new(string name="uart_multiple_write_fifo_burst_unicast_sequence");
    super.new(name);
endfunction

virtual task body();
    //void'(uvm_config_db#(int)::get(null,get_full_name(),"itr", itr));
    `uvm_info(get_type_name(), $sformatf("%s starting...itr = %0d", get_sequence_path(), itr), UVM_NONE);

    uart_write_fifo_burst_unicast_seq = uart_write_fifo_burst_unicast_sequence::type_id::create("uart_write_fifo_burst_unicast_seq");
    uart_read_fifo_seq = uart_read_fifo_sequence::type_id::create("uart_read_fifo_seq");

    for(int i = 0; i < itr; i++) begin
        `uvm_do_on(uart_write_fifo_burst_unicast_seq, p_sequencer.uart_sqr)
        `uvm_do_on(uart_read_fifo_seq, p_sequencer.uart_sqr)
    end
endtask : body

endclass

//uart_multiple_write_fifo_broadcast_sequence
class uart_multiple_write_fifo_broadcast_sequence extends uart_base_sequence;

int itr = 10;
uart_write_fifo_broadcast_sequence uart_write_fifo_broadcast_seq;
uart_read_fifo_sequence uart_read_fifo_seq;

`uvm_declare_p_sequencer(system_virtual_sequencer)

`uvm_object_utils(uart_multiple_write_fifo_broadcast_sequence)

function new(string name="uart_multiple_write_fifo_broadcast_sequence");
    super.new(name);
endfunction

virtual task body();
    //void'(uvm_config_db#(int)::get(null,get_full_name(),"itr", itr));
    `uvm_info(get_type_name(), $sformatf("%s starting...itr = %0d", get_sequence_path(), itr), UVM_NONE);

    uart_write_fifo_broadcast_seq = uart_write_fifo_broadcast_sequence::type_id::create("uart_write_fifo_burst_unicast_seq");
    uart_read_fifo_seq = uart_read_fifo_sequence::type_id::create("uart_read_fifo_seq");

    for(int i = 0; i < itr; i++) begin
        `uvm_do_on(uart_write_fifo_broadcast_seq, p_sequencer.uart_sqr)
        `uvm_do_on(uart_read_fifo_seq, p_sequencer.uart_sqr)
    end
endtask : body

endclass

//uart_multiple_write_fifo_burst_broadcast_sequence
class uart_multiple_write_fifo_burst_broadcast_sequence extends uart_base_sequence;

int itr = 10;
uart_write_fifo_burst_broadcast_sequence uart_write_fifo_burst_broadcast_seq;
uart_read_fifo_sequence uart_read_fifo_seq;

`uvm_declare_p_sequencer(system_virtual_sequencer)

`uvm_object_utils(uart_multiple_write_fifo_burst_broadcast_sequence)

function new(string name="uart_multiple_write_fifo_burst_broadcast_sequence");
    super.new(name);
endfunction

virtual task body();
    //void'(uvm_config_db#(int)::get(null,get_full_name(),"itr", itr));
    `uvm_info(get_type_name(), $sformatf("%s starting...itr = %0d", get_sequence_path(), itr), UVM_NONE);

    uart_write_fifo_burst_broadcast_seq = uart_write_fifo_burst_broadcast_sequence::type_id::create("uart_write_fifo_burst_unicast_seq");
    uart_read_fifo_seq = uart_read_fifo_sequence::type_id::create("uart_read_fifo_seq");

    for(int i = 0; i < itr; i++) begin
        `uvm_do_on(uart_write_fifo_burst_broadcast_seq, p_sequencer.uart_sqr)
        `uvm_do_on(uart_read_fifo_seq, p_sequencer.uart_sqr)
    end
endtask : body

endclass

//uart_multiple_write_fifo_randcast_sequence
class uart_multiple_write_fifo_randcast_sequence extends uart_base_sequence;

int itr = 20;
uart_write_fifo_randcast_sequence uart_write_fifo_randcast_seq;
uart_read_fifo_sequence uart_read_fifo_seq;

`uvm_declare_p_sequencer(system_virtual_sequencer)

`uvm_object_utils(uart_multiple_write_fifo_randcast_sequence)

function new(string name="uart_multiple_write_fifo_randcast_sequence");
    super.new(name);
endfunction

virtual task body();
    //void'(uvm_config_db#(int)::get(null,get_full_name(),"itr", itr));
    `uvm_info(get_type_name(), $sformatf("%s starting...itr = %0d", get_sequence_path(), itr), UVM_NONE);

    uart_write_fifo_randcast_seq = uart_write_fifo_randcast_sequence::type_id::create("uart_write_fifo_burst_unicast_seq");
    uart_read_fifo_seq = uart_read_fifo_sequence::type_id::create("uart_read_fifo_seq");

    for(int i = 0; i < itr; i++) begin
        `uvm_do_on(uart_write_fifo_randcast_seq, p_sequencer.uart_sqr)
        `uvm_do_on(uart_read_fifo_seq, p_sequencer.uart_sqr)
    end
endtask : body

endclass

//uart_multiple_write_fifo_burst_randcast_sequence
class uart_multiple_write_fifo_burst_randcast_sequence extends uart_base_sequence;

int itr = 20;
uart_write_fifo_burst_randcast_sequence uart_write_fifo_burst_randcast_seq;
uart_read_fifo_sequence uart_read_fifo_seq;

`uvm_declare_p_sequencer(system_virtual_sequencer)

`uvm_object_utils(uart_multiple_write_fifo_burst_randcast_sequence)

function new(string name="uart_multiple_write_fifo_burst_randcast_sequence");
    super.new(name);
endfunction

virtual task body();
    //void'(uvm_config_db#(int)::get(null,get_full_name(),"itr", itr));
    `uvm_info(get_type_name(), $sformatf("%s starting...itr = %0d", get_sequence_path(), itr), UVM_NONE);

    uart_write_fifo_burst_randcast_seq = uart_write_fifo_burst_randcast_sequence::type_id::create("uart_write_fifo_burst_unicast_seq");
    uart_read_fifo_seq = uart_read_fifo_sequence::type_id::create("uart_read_fifo_seq");

    for(int i = 0; i < itr; i++) begin
        `uvm_do_on(uart_write_fifo_burst_randcast_seq, p_sequencer.uart_sqr)
        `uvm_do_on(uart_read_fifo_seq, p_sequencer.uart_sqr)
    end
endtask : body

endclass

//uart_uart2spi_fifo_loopback_en_multiple_write_fifo_burst_randcast_sequence
class uart_uart2spi_fifo_loopback_en_multiple_write_fifo_burst_randcast_sequence extends uart_multiple_write_fifo_burst_randcast_sequence;

uart_uart2spi_fifo_loopback_en_sequence uart_uart2spi_fifo_loopback_en_seq;

`uvm_declare_p_sequencer(system_virtual_sequencer)

`uvm_object_utils(uart_uart2spi_fifo_loopback_en_multiple_write_fifo_burst_randcast_sequence)

function new(string name="uart_uart2spi_fifo_loopback_en_multiple_write_fifo_burst_randcast_sequence");
    super.new(name);
endfunction

virtual task body();
    uart_uart2spi_fifo_loopback_en_seq = uart_uart2spi_fifo_loopback_en_sequence::type_id::create("uart_uart2spi_fifo_loopback_en_seq");

    `uvm_do_on(uart_uart2spi_fifo_loopback_en_seq, p_sequencer.uart_sqr)

    super.body();
endtask : body

endclass

//uart_spi_loopback_en_multiple_write_fifo_burst_randcast_sequence
class uart_spi_loopback_en_multiple_write_fifo_burst_randcast_sequence extends uart_multiple_write_fifo_burst_randcast_sequence;

uart_spi_loopback_en_sequence uart_spi_loopback_en_seq;

`uvm_declare_p_sequencer(system_virtual_sequencer)

`uvm_object_utils(uart_spi_loopback_en_multiple_write_fifo_burst_randcast_sequence)

function new(string name="uart_spi_loopback_en_multiple_write_fifo_burst_randcast_sequence");
    super.new(name);
endfunction

virtual task body();
    uart_spi_loopback_en_seq = uart_spi_loopback_en_sequence::type_id::create("uart_spi_loopback_en_seq");

    `uvm_do_on(uart_spi_loopback_en_seq, p_sequencer.uart_sqr)

    super.body();
endtask : body

endclass

//uart_multiple_write_reg_sequence
class uart_multiple_write_reg_sequence extends uart_base_sequence;

int itr = 10;
uart_write_test_reg_sequence uart_write_test_reg_seq;
uart_read_test_reg_sequence uart_read_test_reg_seq;

`uvm_declare_p_sequencer(system_virtual_sequencer)

`uvm_object_utils(uart_multiple_write_reg_sequence)

function new(string name="uart_multiple_write_reg_sequence");
    super.new(name);
endfunction

virtual task body();
    //void'(uvm_config_db#(int)::get(null,get_full_name(),"itr", itr));
    `uvm_info(get_type_name(), $sformatf("%s starting...itr = %0d", get_sequence_path(), itr), UVM_NONE);

    uart_write_test_reg_seq = uart_write_test_reg_sequence::type_id::create("uart_write_test_reg_seq");
    uart_read_test_reg_seq = uart_read_test_reg_sequence::type_id::create("uart_read_test_reg_seq");

    for(int i = 0; i < itr; i++) begin
        `uvm_do_on(uart_write_test_reg_seq, p_sequencer.uart_sqr)
        `uvm_do_on(uart_read_test_reg_seq, p_sequencer.uart_sqr)
    end
endtask : body

endclass

`endif

