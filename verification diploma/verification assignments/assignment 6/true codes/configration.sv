`timescale 1ps/1ps
package config_pkg;
import shared_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

// Configration class
class ALSU_config extends uvm_object;
    `uvm_object_utils(ALSU_config)    
    virtual ALSU_interface v_if;
    function new(string name = "ALSU_config");
        super.new(name);
    endfunction //new()
endclass //ALSU_config
endpackage