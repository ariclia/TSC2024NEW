/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter:
 * User-defined type definitions
 **********************************************************************/
package instr_register_pkg;
  timeunit 1ns/1ns;

  typedef enum logic [3:0] {  // enumerare tip logic, 16 operatii maxim
  	ZERO,
    PASSA,
    PASSB,
    ADD,
    SUB,
    MULT,
    DIV,
    MOD
  } opcode_t;

  typedef logic signed [31:0] operand_t;
  
  typedef logic [4:0] address_t; //32 valori
  
  typedef struct {
    opcode_t  opc;
    operand_t op_a;
    operand_t op_b;
  } instruction_t; // 68 biti 

endpackage: instr_register_pkg
