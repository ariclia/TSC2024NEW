/*************************
 * A SystemVerilog RTL model of an instruction regisgter:
 * User-defined type definitions
 ************************/
package instr_register_pkg;
  timeunit 1ns/1ns;

  typedef enum logic [3:0] { //typedef defineste un tip de data/ enum = o enumerare de tip logic de la 3:0 putem declara 16 operatii
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
  typedef logic signed [63:0] result_t; // adaug un nou tip pentru result facem dublu dimensiunea unui operand deoarece cand facem inmultirea se poate dubla nr de biti
  
  typedef logic [4:0] address_t; //32 de valorui 
  
  typedef struct {
    opcode_t  opc;
    operand_t op_a;
    operand_t op_b;
    result_t  rez_t;
  } instruction_t; //declara variabile de opcode si de operant 68 de biti in total +64 de la result 

endpackage: instr_register_pkg
