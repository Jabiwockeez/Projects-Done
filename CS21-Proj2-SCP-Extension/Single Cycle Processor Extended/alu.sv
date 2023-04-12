module alu(input  logic [31:0] a, b,
           input  logic [3:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);
  
  logic [31:0] condinvb, sum, mask;

  assign condinvb = alucontrol[3] ? ~b : b;
  assign sum = a + condinvb + alucontrol[3];
  assign mask = 'h0000FFFF;
 
  always_comb
    case (alucontrol[2:0])
      3'b000: result = a & b;
      3'b001: result = a | b;
      3'b010: result = sum;
      3'b011: result = sum[31];
      3'b100: result = mask & b;
    endcase

  assign zero = (result == 32'b0);
endmodule