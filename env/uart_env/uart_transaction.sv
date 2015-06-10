`ifndef __UART_TRANSACTION_SV__
`define __UART_TRANSACTION_SV__

class uart_transaction extends uvm_sequence_item;

typedef enum {WRITE, READ, NULL} cmd_type;
typedef enum {UNICAST, BROADCAST} bc_type;
typedef enum {REG, FIFO} access_type;
rand cmd_type    uart_cmd_type    ;
rand logic [2:0] uart_cmd         ;
rand bc_type     uart_bc_type     ;
rand access_type uart_access_type ;
rand logic [2:0] addr             ;
rand logic [7:0] payload[$]       ;

extern function new(string name = "uart Transaction");

function void byte2uart(ref logic[7:0] data[$]);
    //if(data.size() >= 2) begin
    //    header[15:8] = data.pop_front();
    //    header[7:0]  = data.pop_front();
    //end

    foreach(data[i]) begin
        payload.push_back(data[i]);
    end

endfunction

`uvm_object_utils_begin(uart_transaction)
    `uvm_field_enum(cmd_type, uart_cmd_type, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_enum(bc_type, uart_bc_type, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_enum(access_type, uart_access_type, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(uart_cmd, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(addr, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_queue_int(payload, UVM_ALL_ON)
`uvm_object_utils_end

constraint con_uart_addr {
    //solve uart_cmd_type before addr;
    addr inside {['h0:'h7]};
}

constraint con_uart_cmd {
    solve uart_cmd_type before uart_cmd;
    (uart_cmd_type == WRITE) -> (uart_cmd == 3'b001);
    (uart_cmd_type == READ) -> (uart_cmd == 3'b010);
    (uart_cmd_type == NULL) -> (uart_cmd inside {3'h0, [3'b011:3'b111]});
}

constraint con_uart_len {
    solve uart_cmd_type before payload;
    solve uart_access_type before payload;

    (uart_cmd_type == WRITE && uart_access_type == FIFO) -> (payload.size() inside {[1:255]});
    (uart_cmd_type == WRITE && uart_access_type != FIFO) -> (payload.size() == 1);
    (uart_cmd_type == READ) -> (payload.size() == 0);
    (uart_cmd_type == NULL) -> (payload.size() == 0);
}

virtual function bit do_compare (uvm_object rhs, uvm_comparer comparer);
      uart_transaction rhs_;
      do_compare = super.do_compare(rhs,comparer);

      $cast(rhs_,rhs);
      if(do_compare) begin
          foreach (rhs_.payload[i]) begin
              do_compare &= comparer.compare_field_int("Payload", payload[i], rhs_.payload[i], 8);
          end
      end

endfunction

function uvm_object clone();
    uart_transaction tr = new(); 

    tr.copy(this);
    return tr;
endfunction

function void do_copy (uvm_object rhs);
    uart_transaction rhs_;
    super.do_copy(rhs);

    $cast(rhs_, rhs);

    //header = rhs_.header;
    //foreach(rhs_.payload[i]) begin
    //    payload.push_back(rhs_.payload[i]);
    //end

endfunction

endclass

function uart_transaction::new(string name = "uart Transaction");
    super.new(name);
endfunction

`endif

