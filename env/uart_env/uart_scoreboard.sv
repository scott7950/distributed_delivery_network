`ifndef __UART_SCOREBOARD_SV__
`define __UART_SCOREBOARD_SV__

`include "uart_transaction.sv"

`uvm_analysis_imp_decl(_rcvd_uart)
`uvm_analysis_imp_decl(_sent_uart)

class uart_scoreboard extends uvm_scoreboard;

uvm_analysis_imp_sent_uart #(uart_transaction, uart_scoreboard) drv2sb_port;
uvm_analysis_imp_rcvd_uart #(uart_transaction, uart_scoreboard) mon2sb_port;

int ref_uart_data[logic [7:0]];
int ref_uart_loopback_data[$];

integer error_no = 0;
integer send_no = 0;
integer receive_no = 0;

bit read_reg = 0;

logic rx_tx_loopback_en = 1'b0;

protected bit disable_scoreboard = 0;
int sbd_error = 0;

`uvm_component_utils_begin(uart_scoreboard)
    `uvm_field_int(disable_scoreboard, UVM_DEFAULT)
`uvm_component_utils_end

function new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon2sb_port = new("mon2sb", this);
    drv2sb_port = new("drv2sb", this);

    if(!uvm_config_db#(logic)::get(this, "", "rx_tx_loopback_en", rx_tx_loopback_en)) begin
        rx_tx_loopback_en = 1'b0;
    end

endfunction

virtual function void report_phase(uvm_phase phase);
    if(!disable_scoreboard) begin
        `uvm_info(get_type_name(), $sformatf("Reporting scoreboard information...\n%s", this.sprint()), UVM_LOW)
    end
endfunction

virtual function void write_rcvd_uart(input uart_transaction uart_tr);
    uart_transaction cb_uart_tr;
    logic [7:0] data;

    $cast(cb_uart_tr, uart_tr.clone());

    if(rx_tx_loopback_en == 1'b0) begin
        if(read_reg == 1'b1) begin
            //check for register
            read_reg = 1'b0;
        end
        else if(cb_uart_tr.payload.size() != 1) begin
            `uvm_error(get_type_name(), "Data size is 0, expected 1\n")
        end
        else begin
            if(!ref_uart_data.exists(cb_uart_tr.payload[0])) begin
                `uvm_error(get_type_name(), "Not expected data from rx, which is not sent by tx\n")
                error_no++;
                sbd_error = 1;
            end
            else begin
                ref_uart_data[cb_uart_tr.payload[0]] --;
                if(ref_uart_data[cb_uart_tr.payload[0]] == 0) begin
                    ref_uart_data.delete(cb_uart_tr.payload[0]);
                end
            end

            receive_no++;
        end
    end
    else begin
        if(cb_uart_tr.payload.size() != 1) begin
            `uvm_error(get_type_name(), "Data size is 0, expected 1\n")
        end
        else begin
            data = ref_uart_loopback_data.pop_front();

            if(data != cb_uart_tr.payload[0]) begin
                `uvm_error(get_type_name(), "Comparison failed\n")
                error_no++;
                sbd_error = 1;
            end

            receive_no++;
        end
    end

endfunction
 
virtual function void write_sent_uart(input uart_transaction uart_tr);
    uart_transaction cb_uart_tr;
    int inc_num;
    logic [7:0] data;

    $cast(cb_uart_tr, uart_tr.clone());

    if(rx_tx_loopback_en == 1'b0) begin
        if(cb_uart_tr.uart_bc_type == uart_transaction::BROADCAST) begin
            inc_num = 4;
        end
        else begin
            inc_num = 1;
        end

        if(cb_uart_tr.uart_cmd_type == uart_transaction::READ && cb_uart_tr.uart_access_type == uart_transaction::REG) begin
        //read register
            `uvm_info(get_type_name(), $sformatf("UART read register: addr = %h", cb_uart_tr.addr), UVM_NONE);
            read_reg = 1'b1;
        end
        else if(cb_uart_tr.uart_cmd_type == uart_transaction::WRITE) begin
            if(cb_uart_tr.uart_access_type == uart_transaction::REG) begin
            end
            else if(cb_uart_tr.uart_access_type == uart_transaction::FIFO) begin
                foreach(cb_uart_tr.payload[i]) begin
                    if(ref_uart_data.exists(cb_uart_tr.payload[i])) begin
                        ref_uart_data[cb_uart_tr.payload[i]] += inc_num;
                    end
                    else begin
                        ref_uart_data[cb_uart_tr.payload[i]] = inc_num;
                    end
                end

                send_no += cb_uart_tr.payload.size() * inc_num;
            end
        end
    end
    else begin
        //cmd
        data[7:5] = cb_uart_tr.uart_cmd;
        if(cb_uart_tr.uart_bc_type == uart_transaction::BROADCAST)
            data[4] = 1'b1;
        else
            data[4] = 1'b0;
        
        if(cb_uart_tr.uart_access_type == uart_transaction::FIFO)
            data[3] = 1'b1;
        else
            data[3] = 1'b0;

        data[2:0] = cb_uart_tr.addr;

        ref_uart_loopback_data.push_back(data);
        send_no++;

        //data for write
        if(cb_uart_tr.uart_cmd_type == uart_transaction::WRITE) begin
            if(cb_uart_tr.uart_access_type == uart_transaction::REG) begin
                //write data
                ref_uart_loopback_data.push_back(cb_uart_tr.payload[0]);
                send_no++;
            end
            else begin
                //write length
                ref_uart_loopback_data.push_back(cb_uart_tr.payload.size());
                send_no++;

                foreach(cb_uart_tr.payload[i]) begin
                    //write data
                    ref_uart_loopback_data.push_back(cb_uart_tr.payload[i]);
                    send_no++;
                end
            end
        end


    end

    //display("[uart][SEND]");

endfunction

function display(string prefix);
    `uvm_info(get_type_name(), $sformatf("%s Send: %d, Receive: %d, Error: %d", prefix, send_no, receive_no, error_no), UVM_NONE);
endfunction

endclass

`endif

