// the rest of the UVM is not provided as it is not the focus of the question
// Questa2Go question 6 
// Quiz 6 
package fifo_drv_pkg;
  `include "uvm_macros.svh"
	import uvm_pkg::*;
	import FIFO_seq_item_pkg::*;
  typedef virtual fifo_if fifo_vif;

  class fifo_driver extends uvm_driver#(fifo_seq_item);
    `uvm_component_utils(fifo_driver)
    fifo_vif vif;
    FIFO_seq_item seq_item; 

   function new(string name = "FIFO_driver", uvm_component parent = null);
			super.new(name, parent);
		endfunction 

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item = FIFO_seq_item::type_id::create("seq_item");
        seq_item_port.get_next_item(seq_item);

      // add your code here for the missing part in the driver. Upload a screenshot of the driver after ur edits. 
        if(seq_item.op == WRITE) begin
          vif.write(seq_item.data);
        end
        else if(seq_item.op == READ) begin
          vif.read(seq_item.data);
        end
        
        seq_item_port.item_done();

       
      end
    endtask

  endclass
endpackage

interface fifo_if(input logic clk, input logic rst_n);
  logic        wr_en;
  logic        rd_en;
  logic [7:0]  din;
  logic [7:0]  dout;
  logic        full;
  logic        empty;

  // Write task
  task write(input [7:0] data);
    wr_en = 1;
    din = data;
    @(negedge clk);
    wr_en = 0;
  endtask

  task read(output [7:0] data);
    rd_en = 1;
    @(negedge clk);    
    data = dout;      
    rd_en = 0;
  endtask

endinterface