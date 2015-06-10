`ifndef __UART_MONITOR_SV__
`define __UART_MONITOR_SV__

`include "uart_interface.svi"
`include "uart_transaction.sv"

class uart_monitor extends uvm_monitor;

virtual uart_interface uart_vif;

bit checks_enable = 1;
bit coverage_enable = 1;

uvm_analysis_port #(uart_transaction) mon2sb_port;

int uart_tick_cycle;
int num_of_uart_sample;

`uvm_component_utils_begin(uart_monitor)
  `uvm_field_int(checks_enable, UVM_DEFAULT)
  `uvm_field_int(coverage_enable, UVM_DEFAULT)
`uvm_component_utils_end

function new (string name, uvm_component parent);
    super.new(name, parent);

    mon2sb_port = new("mon2sb_port", this);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual uart_interface)::get(this, "", "uart_vif", uart_vif))
        `uvm_fatal("NOVIF",{"virtual interface must be set for: ", get_full_name(), ".uart_vif"});

    if(!uvm_config_db#(int)::get(uvm_root::get(), "", "uart_tick_cycle", uart_tick_cycle))
        uart_tick_cycle = 651;

    if(!uvm_config_db#(int)::get(uvm_root::get(), "", "num_of_uart_sample", num_of_uart_sample))
        num_of_uart_sample = 16;
endfunction

virtual task main_phase(uvm_phase phase);
    super.main_phase(phase);

    `uvm_info(get_full_name(), $sformatf(" uart Monitor"), UVM_MEDIUM)

    fork
        collect_transactions();
    join
endtask

task wait_for_half_uart_cycle();
    //wait for half uart data cycle
    for (int i = 0; i < num_of_uart_sample/2; i++) begin
        for (int j = 0; j < uart_tick_cycle; j++) begin
            @(uart_vif.cb);
        end
    end
endtask;

task wait_for_one_uart_cycle();
    //wait for one uart data cycle
    for (int i = 0; i < num_of_uart_sample; i++) begin
        for (int j = 0; j < uart_tick_cycle; j++) begin
            @(uart_vif.cb);
        end
    end
endtask;

task get_one_byte(output logic [7:0] data);
    //start bit
    wait_for_half_uart_cycle();
    assert(uart_vif.rx == 1'b0) 
        else `uvm_error(get_type_name(),$sformatf("[Receiver] Expecting rx = 0\n"))

    for(int i=0; i<8; i++) begin
        wait_for_one_uart_cycle();
        data[i] = uart_vif.rx;
    end

    //stop bit
    wait_for_one_uart_cycle();
    assert(uart_vif.rx == 1'b1) 
        else `uvm_error(get_type_name(),$sformatf("[Receiver] Expecting rx = 1\n"))
endtask

virtual protected task collect_transactions();
    uart_transaction uart_tr = uart_transaction::type_id::create("uart_tr");
    uart_tr.randomize with {uart_tr.payload.size() == 1;};

    //wait for the global reset
    //drive has hold the reset phase for reset the fpga
    //no need to wait for the negedge of reset
    wait(uart_vif.reset == 1'b0);

    forever begin
        logic [7:0] data ;

        do begin
            @(uart_vif.cb);
        end while(uart_vif.rx == 1'b1);

        get_one_byte(data);
        uart_tr.payload[0] = data;

        //`callback_macro(uart_monitor_callback, monitor_post_transactor(this, uart_tr))
        mon2sb_port.write(uart_tr);
    end
endtask

virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction

endclass

//class uart_monitor_callback extends transactor_callback;
//    virtual task monitor_pre_transactor (uart_monitor xactor, ref uart_transaction uart_tr, ref bit drop);
//    endtask
//    virtual task monitor_post_transactor (uart_monitor xactor, ref uart_transaction uart_tr);
//    endtask
//endclass

`endif

