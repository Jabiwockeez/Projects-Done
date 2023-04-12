`timescale 1ns / 1ps
module aludec(input  logic [5:0] funct,
              input  logic [1:0] aluop,
	      	  input  logic [5:0] op,
              output logic [3:0] alucontrol);

  always_comb
    case(aluop)
      2'b00: case(op)
        6'b010001: alucontrol <= 4'b0100; // li
        default: alucontrol <= 4'b0010;  // add (for lw/sw/addi)
      endcase
      2'b01: alucontrol <= 4'b0110;  // sub (for beq)
      default: case(funct)          // R-type instructions
          6'b100000: alucontrol <= 4'b0010; // add
          6'b100010: alucontrol <= 4'b1010; // sub
          6'b100100: alucontrol <= 4'b0000; // and
          6'b100101: alucontrol <= 4'b0001; // or
          6'b101010: alucontrol <= 4'b1011; // slt
          default:   alucontrol <= 4'bxxxx; // ???
        endcase
    endcase
endmodule