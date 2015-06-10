`ifndef __TEST_SV__
`define __TEST_SV__

`include "env.sv"
`include "uart_sequence.sv"

class base_test extends uvm_test;

env tb_env;
bit test_pass = 1;
uvm_table_printer printer;

`uvm_component_utils(base_test)

function new(string name="base_test", uvm_component parent=null);
    super.new(name, parent);

endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    tb_env = env::type_id::create("tb_env", this);
    printer = new();
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_type_name(),$sformatf("Printing the test topology :\n%s", this.sprint(printer)), UVM_LOW)
endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask

function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);

    if(tb_env.u_uart_env.uart_sb.sbd_error || tb_env.u_uart_env.uart_sb.ref_uart_data.size() != 0) begin
        test_pass = 0;
    end

endfunction

function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    if(test_pass) begin
        `uvm_info(get_type_name(), "** UVM TEST PASSED **", UVM_NONE)
    end
    else begin
        `uvm_error(get_type_name(), "** UVM TEST FAIL **")
    end
endfunction

endclass

//uart_multiple_write_fifo_unicast_test
class uart_multiple_write_fifo_unicast_test extends base_test;

`uvm_component_utils(uart_multiple_write_fifo_unicast_test)

function new(string name="uart_multiple_write_fifo_unicast_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    uart_multiple_write_fifo_unicast_sequence uart_multiple_write_fifo_unicast_seq;

    super.build_phase(phase);

    uart_multiple_write_fifo_unicast_seq = uart_multiple_write_fifo_unicast_sequence::type_id::create("uart_multiple_write_fifo_unicast_seq");
    uvm_config_db#(uvm_sequence_base)::set(this, "tb_env.sys_vir_sqr.main_phase", "default_sequence", uart_multiple_write_fifo_unicast_seq);
endfunction

endclass

//uart_multiple_write_fifo_burst_unicast_test
class uart_multiple_write_fifo_burst_unicast_test extends base_test;

`uvm_component_utils(uart_multiple_write_fifo_burst_unicast_test)

function new(string name="uart_multiple_write_fifo_burst_unicast_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    uart_multiple_write_fifo_burst_unicast_sequence uart_multiple_write_fifo_burst_unicast_seq;

    super.build_phase(phase);

    uart_multiple_write_fifo_burst_unicast_seq = uart_multiple_write_fifo_burst_unicast_sequence::type_id::create("uart_multiple_write_fifo_burst_unicast_seq");
    uvm_config_db#(uvm_sequence_base)::set(this, "tb_env.sys_vir_sqr.main_phase", "default_sequence", uart_multiple_write_fifo_burst_unicast_seq);
endfunction

endclass

//uart_multiple_write_fifo_broadcast_test
class uart_multiple_write_fifo_broadcast_test extends base_test;

`uvm_component_utils(uart_multiple_write_fifo_broadcast_test)

function new(string name="uart_multiple_write_fifo_broadcast_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    uart_multiple_write_fifo_broadcast_sequence uart_multiple_write_fifo_broadcast_seq;

    super.build_phase(phase);

    uart_multiple_write_fifo_broadcast_seq = uart_multiple_write_fifo_broadcast_sequence::type_id::create("uart_multiple_write_fifo_broadcast_seq");
    uvm_config_db#(uvm_sequence_base)::set(this, "tb_env.sys_vir_sqr.main_phase", "default_sequence", uart_multiple_write_fifo_broadcast_seq);
endfunction

endclass

//uart_multiple_write_fifo_burst_broadcast_test
class uart_multiple_write_fifo_burst_broadcast_test extends base_test;

`uvm_component_utils(uart_multiple_write_fifo_burst_broadcast_test)

function new(string name="uart_multiple_write_fifo_burst_broadcast_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    uart_multiple_write_fifo_burst_broadcast_sequence uart_multiple_write_fifo_burst_broadcast_seq;

    super.build_phase(phase);

    uart_multiple_write_fifo_burst_broadcast_seq = uart_multiple_write_fifo_burst_broadcast_sequence::type_id::create("uart_multiple_write_fifo_burst_broadcast_seq");
    uvm_config_db#(uvm_sequence_base)::set(this, "tb_env.sys_vir_sqr.main_phase", "default_sequence", uart_multiple_write_fifo_burst_broadcast_seq);
endfunction

endclass

//uart_multiple_write_fifo_randcast_test
class uart_multiple_write_fifo_randcast_test extends base_test;

`uvm_component_utils(uart_multiple_write_fifo_randcast_test)

function new(string name="uart_multiple_write_fifo_randcast_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    uart_multiple_write_fifo_randcast_sequence uart_multiple_write_fifo_randcast_seq;

    super.build_phase(phase);

    uart_multiple_write_fifo_randcast_seq = uart_multiple_write_fifo_randcast_sequence::type_id::create("uart_multiple_write_fifo_randcast_seq");
    uvm_config_db#(uvm_sequence_base)::set(this, "tb_env.sys_vir_sqr.main_phase", "default_sequence", uart_multiple_write_fifo_randcast_seq);
endfunction

endclass

//uart_multiple_write_fifo_burst_randcast_test
class uart_multiple_write_fifo_burst_randcast_test extends base_test;

`uvm_component_utils(uart_multiple_write_fifo_burst_randcast_test)

function new(string name="uart_multiple_write_fifo_burst_randcast_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    uart_multiple_write_fifo_burst_randcast_sequence uart_multiple_write_fifo_burst_randcast_seq;

    super.build_phase(phase);

    uart_multiple_write_fifo_burst_randcast_seq = uart_multiple_write_fifo_burst_randcast_sequence::type_id::create("uart_multiple_write_fifo_burst_randcast_seq");
    uvm_config_db#(uvm_sequence_base)::set(this, "tb_env.sys_vir_sqr.main_phase", "default_sequence", uart_multiple_write_fifo_burst_randcast_seq);
endfunction

endclass

//uart_rx_tx_loopback_test
//rx_tx_loopback_en_pin
//hard debug
class uart_rx_tx_loopback_test extends uart_multiple_write_fifo_burst_randcast_test;

`uvm_component_utils(uart_rx_tx_loopback_test)

function new(string name="uart_rx_tx_loopback_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    force $root.top.dn_host_debug_en = 1'b1;
    force $root.top.ctrl[2:0] = 3'b001;

    uvm_config_db#(logic)::set(this, "tb_env.u_uart_env.uart_sb", "rx_tx_loopback_en", 1'b1);

endfunction

endclass

//uart_hard_uart2spi_fifo_loopback_test
//uart2spi_fifo_loopback_en 
//hard debug
class uart_hard_uart2spi_fifo_loopback_test extends uart_multiple_write_fifo_burst_randcast_test;

`uvm_component_utils(uart_hard_uart2spi_fifo_loopback_test)

function new(string name="uart_hard_uart2spi_fifo_loopback_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    force $root.top.dn_host_debug_en = 1'b1;
    force $root.top.ctrl[2:0] = 3'b010;
endfunction

endclass

//uart_hard_spi_loopback_test
//spi_loopback_en
//hard debug
class uart_hard_spi_loopback_test extends uart_multiple_write_fifo_burst_randcast_test;

`uvm_component_utils(uart_hard_spi_loopback_test)

function new(string name="uart_hard_spi_loopback_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    force $root.top.dn_host_debug_en = 1'b1;
    force $root.top.ctrl[2:0] = 3'b100;
endfunction

endclass

//uart_soft_uart2spi_fifo_loopback_test
//uart2spi_fifo_loopback_en 
//soft debug
class uart_soft_uart2spi_fifo_loopback_test extends base_test;

`uvm_component_utils(uart_soft_uart2spi_fifo_loopback_test)

function new(string name="uart_soft_uart2spi_fifo_loopback_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    uart_uart2spi_fifo_loopback_en_multiple_write_fifo_burst_randcast_sequence uart_uart2spi_fifo_loopback_en_multiple_write_fifo_burst_randcast_seq;

    super.build_phase(phase);

    uart_uart2spi_fifo_loopback_en_multiple_write_fifo_burst_randcast_seq = uart_uart2spi_fifo_loopback_en_multiple_write_fifo_burst_randcast_sequence::type_id::create("uart_uart2spi_fifo_loopback_en_multiple_write_fifo_burst_randcast_seq");
    uvm_config_db#(uvm_sequence_base)::set(this, "tb_env.sys_vir_sqr.main_phase", "default_sequence", uart_uart2spi_fifo_loopback_en_multiple_write_fifo_burst_randcast_seq);
endfunction

endclass

//uart_soft_spi_loopback_test
//spi_loopback_en
//soft debug
class uart_soft_spi_loopback_test extends base_test;

`uvm_component_utils(uart_soft_spi_loopback_test)

function new(string name="uart_soft_spi_loopback_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    uart_spi_loopback_en_multiple_write_fifo_burst_randcast_sequence uart_spi_loopback_en_multiple_write_fifo_burst_randcast_seq;

    super.build_phase(phase);

    uart_spi_loopback_en_multiple_write_fifo_burst_randcast_seq = uart_spi_loopback_en_multiple_write_fifo_burst_randcast_sequence::type_id::create("uart_spi_loopback_en_multiple_write_fifo_burst_randcast_seq");
    uvm_config_db#(uvm_sequence_base)::set(this, "tb_env.sys_vir_sqr.main_phase", "default_sequence", uart_spi_loopback_en_multiple_write_fifo_burst_randcast_seq);
endfunction

endclass

//uart_multiple_write_reg_test
class uart_multiple_write_reg_test extends base_test;

`uvm_component_utils(uart_multiple_write_reg_test)

function new(string name="uart_multiple_write_reg_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    uart_multiple_write_reg_sequence uart_multiple_write_reg_seq;

    super.build_phase(phase);

    uart_multiple_write_reg_seq = uart_multiple_write_reg_sequence::type_id::create("uart_multiple_write_reg_seq");
    uvm_config_db#(uvm_sequence_base)::set(this, "tb_env.sys_vir_sqr.main_phase", "default_sequence", uart_multiple_write_reg_seq);
endfunction

endclass

`endif

