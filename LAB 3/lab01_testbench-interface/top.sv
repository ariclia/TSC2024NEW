/***********************************************************************
 * A SystemVerilog top-level netlist to connect testbench to DUT
 **********************************************************************/

module top;
 timeunit 1ns/1ns; //directiva de compilator

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  // clock variables
  logic clk; // stari 0,1,x-nu stiu daca e 0 sau 1,z-inalta impedanta
  logic test_clk;

  tb_ifc interf(clk, reset_n);

  // interconnecting signals
  //logic          load_en;
  //logic          reset_n;
  //opcode_t       opcode;
  //operand_t      operand_a, operand_b;
 // address_t      write_pointer, read_pointer;
  //instruction_t  instruction_word;

  // instantiate testbench and connect ports
  instr_register_test test (
    .interf(intf)
    //.clk(test_clk),
    //.load_en(load_en),
    //.reset_n(reset_n),
    //.operand_a(operand_a),
    //.operand_b(operand_b),
    //.opcode(opcode),
   // .write_pointer(write_pointer),
    //.read_pointer(read_pointer),
    //.instruction_word(instruction_word)
   );

  // instantiate design and connect ports
  //module instr_register test instantiaza dut
  instr_register dut (
    .interf(intf)
    //.clk(clk),
    //.load_en(load_en),
   // .reset_n(reset_n),
    //.operand_a(operand_a),
    //.operand_b(operand_b),
   // .opcode(opcode),
    //.write_pointer(write_pointer),
    //.read_pointer(read_pointer),
   // .instruction_word(instruction_word)
   );

  // clock oscillators
  initial begin
    clk <= 0; // se atribuie 0
    forever #5  clk = ~clk;
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
