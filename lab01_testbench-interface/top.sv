/***********************************************************************
 * A SystemVerilog top-level netlist to connect testbench to DUT
 **********************************************************************/

module top; //metoda de incapsulare a codului 
  timeunit 1ns/1ns; //o nano scunda cu o rezoutie de o nano secunda 

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*; //avem nevoie de ceva din paketul asta

  // clock variables
  logic clk;     //wier 
  logic test_clk; 

  // interconnecting signals
  logic          load_en; 
  logic          reset_n;
  opcode_t       opcode; //_t = template  
  operand_t      operand_a, operand_b;
  address_t      write_pointer, read_pointer;
  instruction_t  instruction_word;
  result_t       result;

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
    .instruction_word(instruction_word),
    .instruction_word_rez(result)
   );

  // instantiate design and connect ports
  instr_register dut (
    .clk(clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .result(result),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   ); 
  //mai sus am conectat dut cu test
  // clock oscillators
  initial begin // tot codul o sa fie la timpul 0 facut 
    clk <= 0; //clok ul incepe din 0 
    forever #5  clk = ~clk; // cum afli frecventa unui semnal? Factorul de umplere? 
  end

  initial begin
    test_clk <=0;
    // offset test_clk edges from clk to prevent races between
    // the testbench and the design
    #4 forever begin
      #2ns test_clk = 1'b1;
      #8ns test_clk = 1'b0;
    end
  end

endmodule: top