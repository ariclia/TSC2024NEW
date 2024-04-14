/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/
//DUT ul 
module instr_register
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
(input  logic          clk,
 input  logic          load_en,
 input  logic          reset_n,
 input  operand_t      operand_a,
 input  operand_t      operand_b,
 output  result_t      result,
 input  opcode_t       opcode,
 input  address_t      write_pointer,
 input  address_t      read_pointer,
 output instruction_t  instruction_word
);
  timeunit 1ns/1ns;

  instruction_t  iw_reg [0:31];  // an array of instruction_word structures 32 de elemente [31:0] 32 de biti

  // write to the register
  always@(posedge clk, negedge reset_n)   // write into register // latch comuta pe plaer 
    if (!reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros cum se initializeaza o structura ' zice indiferent de nr de biti 
    end
    else if (load_en) begin //punem case daca opcode este add ce facem? adaugam in structura o variabila noua REZ TEMA de implementam toate operatiile
      $display("LOADD_EN %d timp %t", load_en ,$time  );
      case (opcode)
        ZERO  : result = 0;
        PASSA : result = operand_a;
        PASSB : result = operand_b;
        ADD   : result = operand_a + operand_b;
        SUB   : result = operand_a - operand_b;
        MULT  : result = operand_a * operand_b;
        DIV   : result = operand_a / operand_b;
        MOD   : result = operand_a % operand_b;
        //default : result = 0;
      endcase
      iw_reg[write_pointer] = '{opcode,operand_a,operand_b,result}; // cum se intampla truncherea?? 
    end

  // read from the register
  assign instruction_word = iw_reg[read_pointer];  // continuously read from register

// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force operand_b = operand_a; // cause wrong value to be loaded into operand_b
end
`endif

endmodule: instr_register
