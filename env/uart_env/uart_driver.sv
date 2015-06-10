`ifndef __UART_DRIVER_SV__
`define __UART_DRIVER_SV__

`include "uart_interface.svi"
`include "uart_transaction.sv"

class uart_driver extends uvm_driver #(uart_transaction);

virtual uart_interface uart_vif;
uvm_analysis_port #(uart_transaction) drv2sb_port;
int uart_tick_cycle;
int num_of_uart_sample;

`uvm_component_utils(uart_driver)

extern function new(string name, uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern task main_phase(uvm_phase phase);

task reset_phase(uvm_phase phase);
    super.reset_phase(phase);

    phase.raise_objection(this);

    uart_vif.cb.tx <= 1'b1;
    @(negedge uart_vif.reset);
    repeat(10) @(uart_vif.cb);

    phase.drop_objection(this);
endtask;

task wait_for_one_uart_cycle();
    //wait for one uart data cycle
    for (int i = 0; i < num_of_uart_sample; i++) begin
        for (int j = 0; j < uart_tick_cycle; j++) begin
            @(uart_vif.cb);
        end
    end
endtask;

task write_one_byte(logic [7:0] data);
    //start bit
    uart_vif.tx <= 1'b0;
    wait_for_one_uart_cycle();

    for(int i=0; i<8; i++) begin
        uart_vif.tx <= data[i];
        wait_for_one_uart_cycle();
    end

    //stop bit
    uart_vif.tx <= 1'b1;
    wait_for_one_uart_cycle();
endtask

virtual protected task get_and_drive();
    logic [7:0] data;

    forever begin
        uart_transaction uart_tr;

        seq_item_port.get_next_item(uart_tr);

        drv2sb_port.write(uart_tr);

        uart_tr.print();

        //send cmd and bc_uc
        data[7:5] = uart_tr.uart_cmd;
        if(uart_tr.uart_bc_type == uart_transaction::BROADCAST)
            data[4] = 1'b1;
        else
            data[4] = 1'b0;
        
        if(uart_tr.uart_access_type == uart_transaction::FIFO)
            data[3] = 1'b1;
        else
            data[3] = 1'b0;

        data[2:0] = uart_tr.addr;

        write_one_byte(data);

        if(uart_tr.uart_cmd_type == uart_transaction::WRITE) begin
            if(uart_tr.uart_access_type == uart_transaction::REG)
                //write data
                write_one_byte(uart_tr.payload[0]);
            else begin
                //write length
                $display(uart_tr.payload.size());
                write_one_byte(uart_tr.payload.size());

                foreach(uart_tr.payload[i]) begin
                    //write data
                    write_one_byte(uart_tr.payload[i]);
                end
            end
        end

        //wait for data has been transmitted from fpga
        if(uart_tr.uart_cmd_type == uart_transaction::READ) begin
            @(uart_vif.cb);
            wait(uart_vif.data_obs[5] == 1'b0);
        end

        seq_item_port.item_done();
    end
endtask

endclass

function uart_driver::new(string name, uvm_component parent);
    super.new(name, parent);

    drv2sb_port = new("drv2sb_port", this);
endfunction

function void uart_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual uart_interface)::get(this, "", "uart_vif", uart_vif)) begin
        `uvm_fatal("NOVIF", {"virutal interface must be set for: ", get_full_name(), ".uart_vif"});
    end

    if(!uvm_config_db#(int)::get(uvm_root::get(), "", "uart_tick_cycle", uart_tick_cycle))
        uart_tick_cycle = 651;

    if(!uvm_config_db#(int)::get(uvm_root::get(), "", "num_of_uart_sample", num_of_uart_sample))
        num_of_uart_sample = 16;
endfunction

task uart_driver::main_phase(uvm_phase phase);
    super.main_phase(phase);

    `uvm_info(get_full_name(),$sformatf(" uart Driver"), UVM_MEDIUM)

    fork
        get_and_drive();
    join
endtask

`endif

