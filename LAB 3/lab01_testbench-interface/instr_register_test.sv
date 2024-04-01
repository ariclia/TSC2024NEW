/*************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 ************************/
module instr_register_test 
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word,
   input  result_t       instruction_word_rez
  );

  timeunit 1ns/1ns;
  parameter WD_NR = 3;
  parameter RD_NR = 3;
  parameter WR_ORDER = 2;
  parameter RD_ORDER = 2;
  int seed = 555; 
  int passed_tests = 0;
  int failed_tests = 0;
  instruction_t  iw_reg_test [0:31];  // an array of instruction_word structures 32 de elemente [31:0] 32 de biti
  



  initial begin
    $display("\n\n*********************");
    $display(    "*  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  *");
    $display(    "*  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     *");
    $display(    "*  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  *");
    $display(    "*********************");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles//repete de doua ori doua posage de clock
    reset_n        = 1'b1;          // deassert reset_n (active low)
    foreach (iw_reg_test[i])        // resetam iw_reg_test
      iw_reg_test[i] = '{opc:ZERO,default:0};

    $display("\nWriting values to register stack...\n");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    repeat (WD_NR) begin
      @(posedge clk) randomize_transaction;
      @(negedge clk)  print_transaction;
      save_data;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...\n");
    for (int i=0; i<RD_NR; i++) begin //BD 05.03.2024
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      case (RD_ORDER)
        0 : @(posedge clk) read_pointer = i;
        1 : @(posedge clk) read_pointer = $unsigned($random)%32;
        2 : @(posedge clk) read_pointer = 31 - (i % 32);
      endcase
      
      @(negedge clk) begin print_results;
      check_result;
      end
    end

    final_report;
    @(posedge clk) ;
    $display("\n*********************");
    $display(  "*  THIS IS A SELF-CHECKING TESTBENCH.  YOU DONT       *");
    $display(  "*  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     *");
    $display(  "*  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  *");
    $display(  "*********************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    static int temp_decremental = 31;
    operand_a     <= $random(seed)%16;                 // between -15 and 15
    operand_b     <= $unsigned($random)%16;            // between 0 and 15
    opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    case (WR_ORDER)
      0 : write_pointer <= temp++;
      1 : write_pointer <= $unsigned($random)%32;
      2 : write_pointer <= temp_decremental--;
    endcase
    //write_pointer <= temp++; //toate valoriel alea trebuie sa sa le punem intre-un iv reg 
    //iw_reg[write_pointer]. aici trebuie sa stockez toate valorile generate
    
  endfunction: randomize_transaction

  function void check_result;
    case(iw_reg_test[read_pointer].opc)
      ZERO : iw_reg_test[read_pointer].rez_t = 0;
      PASSA: iw_reg_test[read_pointer].rez_t = iw_reg_test[read_pointer].op_a;
      PASSB: iw_reg_test[read_pointer].rez_t = iw_reg_test[read_pointer].op_b;
      ADD  : iw_reg_test[read_pointer].rez_t = iw_reg_test[read_pointer].op_a + iw_reg_test[read_pointer].op_b;
      SUB  : iw_reg_test[read_pointer].rez_t = iw_reg_test[read_pointer].op_a - iw_reg_test[read_pointer].op_b;
      MULT : iw_reg_test[read_pointer].rez_t = iw_reg_test[read_pointer].op_a * iw_reg_test[read_pointer].op_b;
      DIV  : iw_reg_test[read_pointer].rez_t = iw_reg_test[read_pointer].op_a / iw_reg_test[read_pointer].op_b;
      MOD  : iw_reg_test[read_pointer].rez_t = iw_reg_test[read_pointer].op_a % iw_reg_test[read_pointer].op_b;
    endcase

    if(instruction_word.rez_t!= iw_reg_test[read_pointer].rez_t) begin
    $display("ERROR: Mismatch detected at read pointer %0d", read_pointer);
    $display("  Opcode: %0d (%s)", iw_reg_test[read_pointer].opc, iw_reg_test[read_pointer].opc.name);
    $display("  Operand A: %0d", iw_reg_test[read_pointer].op_a);
    $display("  Operand B: %0d", iw_reg_test[read_pointer].op_b);
    $display("  Expected Result: %0d", iw_reg_test[read_pointer].rez_t);
    $display("  Actual Result: %0d", instruction_word.rez_t);
    failed_tests++;
    end else begin
    $display("SUCCESS: No mismatch at read pointer %0d", read_pointer);
    $display("  Opcode: %0d (%s)", iw_reg_test[read_pointer].opc, iw_reg_test[read_pointer].opc.name);
    $display("  Operand A: %0d", iw_reg_test[read_pointer].op_a);
    $display("  Operand B: %0d", iw_reg_test[read_pointer].op_b);
    $display("  Result: %0d", instruction_word.rez_t);
    passed_tests++;
    end
    if(instruction_word.rez_t != iw_reg_test[read_pointer].rez_t )begin
    $display("ERROR: Rezultat incorect");
    end
    if(instruction_word.op_a != iw_reg_test[read_pointer].op_a )begin
    $display("ERROR: OPERAND_A incorect");
    end 
    if(instruction_word.op_b != iw_reg_test[read_pointer].op_b )begin
    $display("ERROR: OPERAND_B incorect");
    end
    if(instruction_word.opc != iw_reg_test[read_pointer].opc )begin
    $display("ERROR: OPCODE INCORECT");
    end 
  endfunction: check_result

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d", operand_b);
    $display("  instruction_word_rez= %0d\n", instruction_word.rez_t);
  endfunction: print_transaction

  function void save_data;
    // $display("BEFORE SAVING");
    // $display("  OPCODE: %0d ", opcode);
    // $display("  Operand A: %0d", operand_a);
    // $display("  Operand B: %0d", operand_b);
    // $display("  Actual Result: %0d", instruction_word.rez_t);
    // $display("DONE BEFORE SAVING");
    iw_reg_test[write_pointer] = '{opcode, operand_a, operand_b, 'b0};
    $display("DATA SAVED\n");
  endfunction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d", instruction_word.op_b);
    $display("  instruction_word_rez= %0d\n", instruction_word.rez_t);
  endfunction: print_results

  function void final_report;
    $display("Tests that passed %0d: ", passed_tests);
    $display("Tests that failed %0d: ", failed_tests);
  endfunction: final_report

endmodule: instr_register_test
//Tema o functie check results in fn de readpointer sa stie care este op a b opcode si sa calc expected resoult si sa compare a b opcode si rezultatul cu iw_regresult(ce am primit de la dut).
//
