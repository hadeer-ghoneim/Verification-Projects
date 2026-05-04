package coverage_collector_pkg;
import agent_pkg::*;
import shared_pkg::*;
import sequencer_pkg::*;
import sequenceItem_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class ALSU_coverage extends uvm_component;
    `uvm_component_utils(ALSU_coverage)
    uvm_analysis_export #(ALSU_sequenceItem) cov_export; // coverage export
    uvm_tlm_analysis_fifo #(ALSU_sequenceItem) cov_fifo; // coverage fifo
    ALSU_sequenceItem cov_seq_item;

    //////////////////////////////////
    //      begin Coverage Group    //
    //////////////////////////////////

    covergroup cvr_gp;
        // input A bins
            A_cp: coverpoint cov_seq_item.A {
                bins A_data_0 = {ZERO};
                bins A_data_max = {MAXPOS};
                bins A_data_min = {MAXNEG};
                bins A_data_default = default;
                bins A_data_[] = {001, 010, 100};
            }

        // input B bins
            B_cp: coverpoint cov_seq_item.B {
                bins B_data_0 = {ZERO};
                bins B_data_max = {MAXPOS};
                bins B_data_min = {MAXNEG};
                bins B_data_default = default;
                bins B_data_[] = {001, 010, 100};
            }

        // cover point for reduction operation red_op
            op_A_cp: coverpoint cov_seq_item.red_op_A {
                bins one = {1};
                bins zero = {0};
            }
            op_B_cp: coverpoint cov_seq_item.red_op_B {
                bins one = {1};
                bins zero = {0};
            }

        // Crossing to satsfied the data_walkingones of A and B
            A_walk: cross A_cp, op_A_cp {
                option.cross_auto_bin_max = 0;
                bins A_data_walkingones = binsof(A_cp.A_data_) && binsof(op_A_cp.one);
            }
            B_walk: cross B_cp, op_A_cp, op_B_cp {
                option.cross_auto_bin_max = 0;
                bins B_data_walkingones = (binsof(B_cp.B_data_) 
                                          && binsof(op_A_cp.zero) 
                                          && binsof(op_B_cp.one)); 
            }

        // cover point for opcode (ALU)
            ALU_cp: coverpoint cov_seq_item.opcode {
                bins Bins_shift[] = {SHIFT, ROTATE};
                bins Bins_arith[] = {ADD, MULT};
                bins Bins_bitwise[] = {OR, XOR};//
                bins Bins_invalid = {INVALID_6, INVALID_7};
                bins Bins_trans = (0 => 1 => 2 => 3 => 4 => 5);
            }
     
        // cover point for c_in
            cin_cp: coverpoint cov_seq_item.cin;
        
        // cover point for serial_in
            serial_cp: coverpoint cov_seq_item.serial_in;
        
        // cover point for direction
            direction_cp: coverpoint cov_seq_item.direction;

        // Cross coverage between ALU_cp and A and B
            ALU_A: cross ALU_cp, A_cp {
                option.cross_auto_bin_max = 0;
                bins arith_permutations = binsof(ALU_cp.Bins_arith) && binsof(A_cp) intersect{ZERO, MAXPOS, MAXNEG};
            }
            ALU_B: cross ALU_cp, B_cp {
                option.cross_auto_bin_max = 0;
                bins arith_permutations = binsof(ALU_cp.Bins_arith) && binsof(B_cp) intersect{ZERO, MAXPOS, MAXNEG};
            }
        
        // Cross coverage between ALU_cp and cin_cp
            ALU_cin: cross ALU_cp, cin_cp {
                option.cross_auto_bin_max = 0;
                bins add_cin = binsof(ALU_cp) intersect{ADD};
            }
        
        // Cross coverage between ALU_cp and serial_cp
            ALU_serial: cross ALU_cp, serial_cp {
                option.cross_auto_bin_max = 0;
                bins shift_serial = binsof(ALU_cp) intersect{SHIFT};
            }
        
        // Cross coverage between ALU_cp and direction_cp
            ALU_direction: cross ALU_cp, direction_cp {
                option.cross_auto_bin_max = 0;
                bins sh_ro_direction = binsof(ALU_cp.Bins_shift);
            }    
    
        // Cross coverage ALU = {OR,XOR}, red_op_A = 1, A = data_walk, B = 0
            A_data_walk_OR_XOR: cross ALU_cp, A_walk, op_A_cp, B_cp {
                option.cross_auto_bin_max = 0;
                bins A_walk_OR_XOR = (binsof(ALU_cp.Bins_bitwise) 
                                   && binsof(A_walk.A_data_walkingones)
                                   && binsof(op_A_cp.one)
                                   && binsof(B_cp.B_data_0));
            }
    
        // Cross coverage ALU = {OR,XOR}, red_op_A = 1, A = data_walk, B = 0
            B_data_walk_OR_XOR: cross ALU_cp, B_walk, op_B_cp, A_cp {
                option.cross_auto_bin_max = 0;
                bins B_walk_OR_XOR = (binsof(ALU_cp.Bins_bitwise) 
                                   && binsof(B_walk.B_data_walkingones)
                                   && binsof(op_B_cp.one)
                                   && binsof(A_cp.A_data_0));
            }

        // Cross coverage Invalid case 2 red_op
            Invalid_red_op: cross ALU_cp, op_A_cp, op_B_cp {
                option.cross_auto_bin_max = 0;
                bins Invalid_reduction = (binsof(ALU_cp.Bins_bitwise)
                                         && (binsof(op_A_cp.one) || binsof(op_B_cp.one)));
            }
    
        // Invalid case with reduction operation
            reduction_invalid: cross ALU_cp, op_A_cp, op_B_cp {
                option.cross_auto_bin_max = 0;
                bins invalid_red_op = (binsof(ALU_cp) intersect{!OR, !XOR} && (binsof(op_A_cp.one)||binsof(op_B_cp.one)));
            }
        
        // cover point rst
            rst_cp: coverpoint cov_seq_item.rst;

        // Cross coverage red_op_A and red_op_B
            red_op_High_cross: cross op_A_cp, op_B_cp;
    endgroup

    ///////////////////////////////////
    //      finish Coverage Group    //
    ///////////////////////////////////

    function new(string name = "ALSU_coverage", uvm_component parent = null);
        super.new(name, parent);
        cvr_gp = new();
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_export = new("cov_export", this);
        cov_fifo = new("cov_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cov_export.connect(cov_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            cov_fifo.get(cov_seq_item);
            cvr_gp.sample();
        end
    endtask
endclass 
endpackage