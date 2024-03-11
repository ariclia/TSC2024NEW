/***********************************************************************
 * A SystemVerilog top-level netlist to connect testbench to DUT
 **********************************************************************/

module top; //unde incepe si unde se termina
  timeunit 1ns/1ns; 

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  // clock variables
  logic clk; //-128...-1...0...127 
  logic test_clk; 

  // interconnecting signals
  logic          load_en; 
  logic          reset_n;
  opcode_t       opcode; //template
  operand_t      operand_a, operand_b;
  address_t      write_pointer, read_pointer;
  instruction_t  instruction_word;

  // instantiate testbench and connect ports
  instr_register_test test (
    .clk(test_clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   );

  // instantiate design and connect ports
  instr_register dut (
    .clk(clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   );

  // clock oscillators
  initial begin
    clk <= 0; 
    forever #5  clk = ~clk; //diez asteapta 5 unitati de timp 1nanosecundax5
  end // perioada 10ns, frecventa 100mHz, 50%

  initial begin //tot codul de sub va fi  executat la timp de simulare 0
    test_clk <=0;
    // offset test_clk edges from clk to prevent races between
    // the testbench and the design
    #4 forever begin
      #2ns test_clk = 1'b1;
      #8ns test_clk = 1'b0;
    end
  end //80%

endmodule: top
