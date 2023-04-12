`timescale 1ns / 1ps
module testbench();

  logic        clk;
  logic        reset;

  logic [31:0] writedata, dataadr;
  logic        memwrite;

  // instantiate device to be tested
  top dut(clk, reset, writedata, dataadr, memwrite);
  
  // initialize test
  initial
    begin
      $dumpfile("dump.vcd"); $dumpvars;
      reset <= 1; # 1; reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 1; clk <= 0; # 1;
    end

endmodule