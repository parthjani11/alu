`timescale 1ns/1ps
`include "ALU_Parth.v"
`include "alu_ref_s.v"

module test_alu;

    // DUT signals
    reg [7:0] OPA, OPB;
    reg CLK, RST, CE, MODE, CIN;
    reg [1:0] INV;
    reg [3:0] CMD;
    wire [15:0] RES_dut;
    wire COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut;

    // Reference model signals
    wire [15:0] RES_ref;
    wire COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref;

    reg [15:0] RES_hold;
    reg COUT_hold, OFLOW_hold, G_hold, E_hold, L_hold, ERR_hold;
    // Test counters
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;

     // Updated ALU instantiation
    ALU_Parth #(
        .WIDTH_INP(8),
        .WIDTH_CMD(4)
    ) dut (
        .CLK(CLK),
        .RST(RST),
        .MODE(MODE),
        .CE(CE),
        .CIN(CIN),
        .OPA(OPA),
        .OPB(OPB),
        .INP_VALID(INV), // Mapping testbench 'INV' to module 'INP_VALID'
        .CMD(CMD),
        .RES(RES_dut),
        .COUT(COUT_dut),
        .OFLOW(OFLOW_dut),
        .E(E_dut),
        .G(G_dut),
        .L(L_dut),
        .ERR(ERR_dut)
    );


    // Reference model instantiation
    alu_ref #(.WIDTH(8)) m2(
        .OPA(OPA), .OPB(OPB), .CIN(CIN),
        .MODE(MODE), .CMD(CMD),
        .RES(RES_ref),.INP_VALID(INV),
        .COUT(COUT_ref), .OFLOW(OFLOW_ref),
        .G(G_ref), .E(E_ref), .L(L_ref),
        .ERR(ERR_ref)
    );



        task display_mismatch_rst();
        begin
            $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_dut, COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut);
        end
    endtask
    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    // Test stimulus
    initial begin
        // Initialize
        RST = 1; CE = 1'b1; CIN = 0;
        OPA = 0; OPB = 0; MODE = 0; CMD = 0;INV=2'b11;

        @(negedge CLK);
        @(posedge CLK);
        test_reset("RESET");
        RST = 0;  // Release reset
        @(posedge CLK);
        $display("\n=== INPUT_VALID=2'b11 ===");
        // Test Arithmetic Operations
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();

        // Test Logical Operations
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        $display("\n=== Testing MULTIPLICATION Operations (MODE=1) ===");
        MODE = 1;
        test_mult();

        $display("\n=== HOLD OPERATION ===");
        // Test Arithmetic Operations
        @(posedge CLK);
        test_hold();
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();

        // Test Logical Operations
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        $display("\n=== Testing MULTIPLICATION Operations (MODE=1) ===");
        MODE = 1;
        test_mult();


        @(negedge CLK);
        CE=1'b1;
        @(posedge CLK);
        // Summary
        INV=2'b00;
        @(posedge CLK);
        $display("\n=== INPUT_VALID=2'b00 ===");
        // Test Arithmetic Operations
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();

        // Test Logical Operations
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        $display("\n=== Testing MULTIPLICATION Operations (MODE=1) ===");
        MODE = 1;
        test_mult();

        // Summary
        INV=2'b01;
        @(posedge CLK);
        $display("\n=== INPUT_VALID=2'b01 ===");
        // Test Arithmetic Operations
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();

        // Test Logical Operations
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        $display("\n=== Testing MULTIPLICATION Operations (MODE=1) ===");
        MODE = 1;
        test_mult();

        // Summary
        INV=2'b10;
        @(posedge CLK);
        $display("\n=== INPUT_VALID=2'b10 ===");
        // Test Arithmetic Operations
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();

        // Test Logical Operations
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        $display("\n=== Testing MULTIPLICATION Operations (MODE=1) ===");
        MODE = 1;
        test_mult();

        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");

        #1000;
        $finish;
    end

    task test_hold();
        begin
            @(negedge CLK);
            CE=1'b0;
            RES_hold<=RES_dut;
            COUT_hold<=COUT_dut;
            OFLOW_hold<=OFLOW_dut;
            G_hold<=G_dut;
            E_hold<=E_dut;
            L_hold<=L_dut;
            ERR_hold<=ERR_dut;
            @(posedge CLK);
            @(posedge CLK);
        end
    endtask
    



task test_arithmetic();
begin


// ADD

apply_test(8'h00, 8'h00, 4'b0000, "ADD zero");
apply_test(8'h01, 8'h01, 4'b0000, "ADD simple");
apply_test(8'h7F, 8'h01, 4'b0000, "ADD signed overflow");
apply_test(8'h80, 8'h80, 4'b0000, "ADD negative overflow");
apply_test(8'hFE, 8'h01, 4'b0000, "ADD no carry");
apply_test(8'hFF, 8'h01, 4'b0000, "ADD carry");
apply_test(8'hFF, 8'hFF, 4'b0000, "ADD max values");
apply_test(8'hAA, 8'h55, 4'b0000, "ADD alternating bits");


// SUB

apply_test(8'h20, 8'h10, 4'b0001, "SUB");
apply_test(8'h10, 8'h20, 4'b0001, "SUB overflow");
apply_test(8'h00, 8'h00, 4'b0001, "SUB zero");
apply_test(8'h80, 8'h01, 4'b0001, "SUB signed overflow");
apply_test(8'h7F, 8'hFF, 4'b0001, "SUB positive overflow");
apply_test(8'h55, 8'hAA, 4'b0001, "SUB alternating");


// ADD_CIN

CIN = 1;
apply_test(8'hF0, 8'h20, 4'b0010, "ADD_CIN carry");
apply_test(8'hFF, 8'h00, 4'b0010, "ADD_CIN full carry");
apply_test(8'h7F, 8'h00, 4'b0010, "ADD_CIN signed overflow");
apply_test(8'h80, 8'hFF, 4'b0010, "ADD_CIN negative overflow");

CIN = 0;
apply_test(8'h10, 8'h20, 4'b0010, "ADD_CIN no cin");
apply_test(8'hF0, 8'h20, 4'b0010, "ADD_CIN no cin carry");


// SUB_CIN

CIN = 1;
apply_test(8'h10, 8'h20, 4'b0011, "SUB_CIN overflow");
apply_test(8'h00, 8'h00, 4'b0011, "SUB_CIN zero");
apply_test(8'h80, 8'h01, 4'b0011, "SUB_CIN signed overflow");
apply_test(8'h7F, 8'hFF, 4'b0011, "SUB_CIN positive overflow");

CIN = 0;
apply_test(8'h10, 8'h20, 4'b0011, "SUB_CIN no cin");
apply_test(8'hF0, 8'h20, 4'b0011, "SUB_CIN no cin carry");

// INC_A

apply_test(8'h00, 8'h00, 4'b0100, "INC_A zero");
apply_test(8'h7F, 8'h00, 4'b0100, "INC_A signed overflow");
apply_test(8'hFE, 8'h00, 4'b0100, "INC_A near max");
apply_test(8'hFF, 8'h00, 4'b0100, "INC_A wrap");


// DEC_A

apply_test(8'h0F, 8'h00, 4'b0101, "DEC_A");
apply_test(8'h01, 8'h00, 4'b0101, "DEC_A one");
apply_test(8'h80, 8'h00, 4'b0101, "DEC_A signed");
apply_test(8'h00, 8'h00, 4'b0101, "DEC_A underflow");


// INC_B

apply_test(8'h00, 8'h00, 4'b0110, "INC_B zero");
apply_test(8'h00, 8'h7F, 4'b0110, "INC_B signed overflow");
apply_test(8'h00, 8'hFF, 4'b0110, "INC_B wrap");


// DEC_B

apply_test(8'h00, 8'h01, 4'b0111, "DEC_B one");
apply_test(8'h00, 8'h80, 4'b0111, "DEC_B signed");
apply_test(8'h00, 8'h00, 4'b0111, "DEC_B underflow");
apply_test(8'h00, 8'hFF, 4'b0111, "DEC_B");


// CMP

apply_test(8'h10, 8'h10, 4'b1000, "CMP equal");
apply_test(8'h20, 8'h10, 4'b1000, "CMP greater");
apply_test(8'h10, 8'h20, 4'b1000, "CMP less");
apply_test(8'h80, 8'h7F, 4'b1000, "CMP signed");


// SIGNED ADD

apply_test(8'h5A, 8'h0C, 4'b1011, "sign add positive");
apply_test(8'h5A, 8'h5C, 4'b1011, "sign add positive overflow");
apply_test(8'hAA, 8'h0C, 4'b1011, "sign add negative");
apply_test(8'hAA, 8'hAC, 4'b1011, "sign add negative overflow");

apply_test(8'h7F, 8'h01, 4'b1011, "signed add max overflow");
apply_test(8'h80, 8'hFF, 4'b1011, "signed add min overflow");
apply_test(8'h55, 8'hAA, 4'b1011, "signed add toggle");


// SIGNED SUB

apply_test(8'h5A, 8'hF4, 4'b1100, "sign sub positive");
apply_test(8'h5A, 8'hA4, 4'b1100, "sign sub positive overflow");
apply_test(8'hAA, 8'hF4, 4'b1100, "sign sub negative");
apply_test(8'hAA, 8'h54, 4'b1100, "sign sub negative overflow");

apply_test(8'h7F, 8'hFF, 4'b1100, "signed sub overflow");
apply_test(8'h80, 8'h01, 4'b1100, "signed sub underflow");
apply_test(8'hFF, 8'hFE, 4'b1100, "signed sub positive");


// ERROR STATES

apply_test(8'hAA, 8'hFB, 4'b1101, "ERROR");
apply_test(8'h55, 8'hAA, 4'b1101, "ERROR toggle");

apply_test(8'hAA, 8'hFB, 4'b1110, "ERROR");
apply_test(8'h0F, 8'hF0, 4'b1110, "ERROR toggle");

apply_test(8'hAA, 8'hFB, 4'b1111, "ERROR");
apply_test(8'hFF, 8'h00, 4'b1111, "ERROR toggle");


// TOGGLE COVERAGE SPECIAL CASES

apply_test(8'h0F, 8'hF0, 4'b1011, "toggle nibble");
apply_test(8'hF0, 8'h0F, 4'b1100, "toggle reverse nibble");
// sum_unsigned[15:9]
apply_test(8'hFF, 8'hFF, 4'b0000, "TOGGLE_SUM_UNSIGNED_MSB");

// sum_cin[15:9]
CIN = 1;
apply_test(8'hFF, 8'hFF, 4'b0010, "TOGGLE_SUM_CIN_MSB");
CIN = 0;

// inc_a[15:9]
apply_test(8'hFF, 8'h00, 4'b0100, "TOGGLE_INC_A_MSB");

// inc_b[15:9]
apply_test(8'h00, 8'hFF, 4'b0110, "TOGGLE_INC_B_MSB");

end
endtask



// UPDATED test_logical()

task test_logical();
begin


// AND

apply_test(8'hF0, 8'h0F, 4'b0000, "AND");


// NAND

apply_test(8'hF0, 8'h0F, 4'b0001, "NAND");
apply_test(8'hFF, 8'hFF, 4'b0001, "NAND full");


// OR

apply_test(8'hF0, 8'h0F, 4'b0010, "OR");


// NOR

apply_test(8'hF0, 8'h0F, 4'b0011, "NOR");
apply_test(8'h00, 8'h00, 4'b0011, "NOR zero");


// XOR

apply_test(8'hAA, 8'h55, 4'b0100, "XOR");
apply_test(8'hFF, 8'hFF, 4'b0100, "XOR equal");


// XNOR

apply_test(8'hAA, 8'h55, 4'b0101, "XNOR");
apply_test(8'hFF, 8'hFF, 4'b0101, "XNOR equal");


// NOT_A

apply_test(8'hF0, 8'h00, 4'b0110, "NOT_A");


// NOT_B

apply_test(8'h00, 8'h0F, 4'b0111, "NOT_B");

// RS_A

apply_test(8'h01, 8'h00, 4'b1000, "RS_A LSB");
apply_test(8'h80, 8'h00, 4'b1000, "RS_A MSB");


// LS_A

apply_test(8'h80, 8'h00, 4'b1001, "LS_A overflow");


// RS_B

apply_test(8'h00, 8'h01, 4'b1010, "RS_B LSB");
apply_test(8'h00, 8'h80, 4'b1010, "RS_B MSB");


// LS_B

apply_test(8'h00, 8'h80, 4'b1011, "LS_B overflow");


// ROL

apply_test(8'hAA, 8'h01, 4'b1100, "ROL1");
apply_test(8'hAA, 8'h07, 4'b1100, "ROL7");

// ROR

apply_test(8'hAA, 8'h01, 4'b1101, "ROR1");
apply_test(8'hAA, 8'h07, 4'b1101, "ROR7");


// ERROR

apply_test(8'hAA, 8'h55, 4'b1110, "ERROR0");
apply_test(8'h55, 8'hAA, 4'b1111, "ERROR1");

// log_and[15:8]
apply_test(8'hFF, 8'hFF, 4'b0000, "TOGGLE_AND_MSB");

// log_nand[15:8]
apply_test(8'h00, 8'h00, 4'b0001, "TOGGLE_NAND_MSB");

// log_nor[15:8]
apply_test(8'h00, 8'h00, 4'b0011, "TOGGLE_NOR_MSB");

// log_or[15:8]
apply_test(8'hFF, 8'hFF, 4'b0010, "TOGGLE_OR_MSB");

// log_xor[15:8]
apply_test(8'hFF, 8'h00, 4'b0100, "TOGGLE_XOR_MSB");

// log_xnor[15:8]
apply_test(8'hFF, 8'hFF, 4'b0101, "TOGGLE_XNOR_MSB");

// log_nota[15:8]
apply_test(8'h00, 8'h00, 4'b0110, "TOGGLE_NOTA_MSB");

// log_notb[15:8]
apply_test(8'h00, 8'h00, 4'b0111, "TOGGLE_NOTB_MSB");

// log_shl_a[0]
apply_test(8'h80, 8'h00, 4'b1001, "TOGGLE_SHL_A_LSB");

// log_shl_b[0]
apply_test(8'h00, 8'h80, 4'b1011, "TOGGLE_SHL_B_LSB");

// log_shr_a[7]
apply_test(8'h01, 8'h00, 4'b1000, "TOGGLE_SHR_A_MSB");

// log_shr_b[7]
apply_test(8'h00, 8'h01, 4'b1010, "TOGGLE_SHR_B_MSB");

end
endtask



// UPDATED test_mult()

task test_mult();
begin


// CMD9 : MULTIPLICATION TESTCASES


apply_test_mul(8'h00, 8'h00, 4'b1001, "MULT zero");

apply_test_mul(8'hFE, 8'h00, 4'b1001, "MULT near max");
apply_test_mul(8'hFF, 8'h00, 4'b1001, "MULT wrap A");
apply_test_mul(8'h00, 8'hFF, 4'b1001, "MULT wrap B");
apply_test_mul(8'hFF, 8'hFF, 4'b1001, "MULT both wrap");

apply_test_mul(8'hF0, 8'h0F, 4'b1001, "MULT upper-lower nibble");
apply_test_mul(8'h0F, 8'hF0, 4'b1001, "MULT lower-upper nibble");
apply_test_mul(8'hAA, 8'h55, 4'b1001, "MULT alternating bits");
apply_test_mul(8'h55, 8'hAA, 4'b1001, "MULT reverse alternating");

apply_test_mul(8'h00, 8'hFF, 4'b1001, "MULT all 0 to all 1");
apply_test_mul(8'hFF, 8'h00, 4'b1001, "MULT all 1 to all 0");
apply_test_mul(8'h01, 8'h80, 4'b1001, "MULT LSB/MSB toggle");
apply_test_mul(8'h80, 8'h01, 4'b1001, "MULT MSB/LSB toggle");

apply_test_mul(8'h7F, 8'h7F, 4'b1001, "MULT positive boundary");
apply_test_mul(8'h80, 8'h80, 4'b1001, "MULT negative boundary");
apply_test_mul(8'hFE, 8'hFE, 4'b1001, "MULT near overflow");
apply_test_mul(8'hA3, 8'h45, 4'b1001, "MULT random pattern");
apply_test_mul(8'h3C, 8'hC3, 4'b1001, "MULT mirror pattern");

apply_test_mul(8'hAA, 8'hAA, 4'b1001, "MULT toggle 2");
apply_test_mul(8'h55, 8'h55, 4'b1001, "MULT toggle 3");


// CMD10 : SHIFT MULTIPLICATION TESTCASES


apply_test_mul(8'h00, 8'h00, 4'b1010, "SHL_MULT zero");
apply_test_mul(8'h01, 8'h01, 4'b1010, "SHL_MULT one");
apply_test_mul(8'h02, 8'h04, 4'b1010, "SHL_MULT small");

apply_test_mul(8'h7F, 8'h01, 4'b1010, "SHL_MULT max positive");
apply_test_mul(8'h80, 8'h01, 4'b1010, "SHL_MULT sign boundary");
apply_test_mul(8'hFF, 8'h01, 4'b1010, "SHL_MULT all ones");

apply_test_mul(8'hF0, 8'h0F, 4'b1010, "SHL_MULT nibble pattern");
apply_test_mul(8'h0F, 8'hF0, 4'b1010, "SHL_MULT reverse nibble");

apply_test_mul(8'hAA, 8'h55, 4'b1010, "SHL_MULT alternating");
apply_test_mul(8'h55, 8'hAA, 4'b1010, "SHL_MULT reverse alternating");

apply_test_mul(8'h00, 8'hFF, 4'b1010, "SHL_MULT zero-full");
apply_test_mul(8'hFF, 8'h00, 4'b1010, "SHL_MULT full-zero");

apply_test_mul(8'h40, 8'h02, 4'b1010, "SHL_MULT shift overflow");
apply_test_mul(8'h80, 8'h02, 4'b1010, "SHL_MULT MSB loss");
apply_test_mul(8'h01, 8'h80, 4'b1010, "SHL_MULT LSB to MSB");

apply_test_mul(8'hAE, 8'hFF, 4'b1010, "SHL_MULT random");
apply_test_mul(8'h3C, 8'hC3, 4'b1010, "SHL_MULT mirror");
apply_test_mul(8'h5A, 8'hA5, 4'b1010, "SHL_MULT complementary");

apply_test_mul(8'hAA, 8'hAA, 4'b1010, "SHL_MULT toggle 2");
apply_test_mul(8'h55, 8'h55, 4'b1010, "SHL_MULT toggle 3");


// RESET VALIDATION

test_reset("RESET");

#1;
RST = 0;
#1;

apply_test_mul(8'h00, 8'h00, 4'b1001, "POST_RESET_MULT_ZERO");
apply_test_mul(8'hFF, 8'hFF, 4'b1001, "POST_RESET_MULT_MAX");
apply_test_mul(8'hAA, 8'h55, 4'b1010, "POST_RESET_SHL_MULT");
apply_test_mul(8'h55, 8'hAA, 4'b1001, "POST_RESET_ALT_PATTERN");


end
endtask

    task apply_test_mul(
        input [7:0] a, b,
        input [3:0] cmd,
        input [80*8:1] test_name
    );
        begin
            @(negedge CLK);
            OPA = a;
            OPB = b;
            CMD = cmd;

            @(posedge CLK);
            @(posedge CLK);
            #1;
            if (CE) begin
                if((RES_dut!=={2*8{1'bx}})&&(INV==2'b11)) begin
                    $display("[FAIL-x] %s: OPA=0x%h OPB=0x%h CMD=0x%h",test_name,a, b, cmd);
		    @(negedge CLK);
                    #1;
			
                    test_count = test_count + 1;
                    fail_count = fail_count + 1;
                    display_mismatch();
		    @(negedge CLK);
                end else begin
                    @(posedge CLK);
                    #1;
                    test_count = test_count + 1;
                    if (compare_outputs(COUT_dut, COUT_ref)) begin
                        $display("[PASS] %s: OPA=0x%h OPB=0x%h CMD=0x%h",test_name, a, b, cmd);
                        pass_count = pass_count + 1;
                        display_mismatch();
                    end else begin
                        $display("[FAIL] %s: OPA=0x%h OPB=0x%h CMD=0x%h",test_name, a, b, cmd);
                        display_mismatch();
                        fail_count = fail_count + 1;
                    end
                    @(posedge CLK);
                end
             end else begin
                @(posedge CLK);
                test_count = test_count + 1;
                if (compare_hold(COUT_dut, COUT_ref)) begin
                    $display("[PASS] %s: OPA=0x%h OPB=0x%h CMD=0x%h",test_name, a, b, cmd);
                    pass_count = pass_count + 1;
                    display_mismatch();
                end else begin
                    $display("[FAIL] %s: OPA=0x%h OPB=0x%h CMD=0x%h",test_name, a, b, cmd);
                    display_mismatch();
                    fail_count = fail_count + 1;
                end
             end
        end
    endtask

    // Apply test and check
    task apply_test(
        input [7:0] a, b,
        input [3:0] cmd,
        input [80*8:1] test_name
    );
        begin
            @(negedge CLK);
            OPA = a;
            OPB = b;
            CMD = cmd;

            @(posedge CLK);
            @(posedge CLK);
            if (CE) begin
                test_count = test_count + 1;
                #1;
                if (compare_outputs(COUT_dut, COUT_ref)) begin
                    $display("[PASS] %s: OPA=0x%h OPB=0x%h CMD=0x%h",test_name,                                                                                                              a, b, cmd);
                    pass_count = pass_count + 1;
                    display_mismatch();
                end else begin
                    $display("[FAIL] %s: OPA=0x%h OPB=0x%h CMD=0x%h",
                             test_name, a, b, cmd);
                    display_mismatch();
                    fail_count = fail_count + 1;
                end
            end else begin
                test_count = test_count + 1;
                if (compare_hold(COUT_dut, COUT_ref)) begin
                    $display("[PASS] %s: OPA=0x%h OPB=0x%h CMD=0x%h",test_name,                                                                                                              a, b, cmd);
                    pass_count = pass_count + 1;
                    display_mismatch();
                end else begin
                    $display("[FAIL] %s: OPA=0x%h OPB=0x%h CMD=0x%h",test_name,                                                                                                              a, b, cmd);
                    display_mismatch();
                    fail_count = fail_count + 1;
                end
            end
        end
    endtask

    task test_reset(input [80*8:1] test_name);
        begin
            test_count = test_count + 1;
            if ((COUT_dut!=1'b0)||(OFLOW_dut!=0)||(G_dut!=0)||(E_dut!=0)||(L_dut !=0)||(ERR_dut!=0)) begin
                $display("[FAIL] %s", test_name);
                fail_count = fail_count + 1;
                display_mismatch_rst();
            end else begin
                $display("[PASS] %s",test_name);
                pass_count = pass_count + 1;
                display_mismatch_rst();
            end
        end
    endtask


    // Compare DUT vs Reference
    function compare_outputs(COUT_dut, COUT_ref);
        begin
            compare_outputs = 1;

            // Compare RES (handle Z values)
            if (RES_dut !== RES_ref) begin
                if (!((RES_dut === 8'hxx) && (RES_ref === 8'hxx)))
                    compare_outputs = 0;
            end

            // Compare flags (handle Z values)
            if (!compare_bit(COUT_dut, COUT_ref)) compare_outputs = 0;
            if (!compare_bit(OFLOW_dut, OFLOW_ref)) compare_outputs = 0;
            if (!compare_bit(G_dut, G_ref)) compare_outputs = 0;
            if (!compare_bit(E_dut, E_ref)) compare_outputs = 0;
            if (!compare_bit(L_dut, L_ref)) compare_outputs = 0;
            if (!compare_bit(ERR_dut, ERR_ref)) compare_outputs = 0;
        end
    endfunction

    function compare_hold(COUT_dut, COUT_ref);
        begin
            compare_hold = 1;

            // Compare flags (handle Z values)
            if (!compare_bit(COUT_dut, COUT_hold)) compare_hold = 0;
            if (!compare_bit(OFLOW_dut, OFLOW_hold)) compare_hold = 0;
            if (!compare_bit(G_dut, G_hold)) compare_hold = 0;
            if (!compare_bit(E_dut, E_hold)) compare_hold = 0;
            if (!compare_bit(L_dut, L_hold)) compare_hold = 0;
            if (!compare_bit(ERR_dut, ERR_hold)) compare_hold = 0;
        end
    endfunction

    // Compare single bit (handle Z)
    function compare_bit(input dut, ref);
        begin
            if (dut === ref)
                compare_bit = 1;
            else if ((dut === 1'bz) && (ref === 1'bz))
                compare_bit = 1;
            else
                compare_bit = 0;
        end
    endfunction

    // Display mismatch details
    task display_mismatch();
        begin
            if (CE) begin
                $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b                                                                                                             ", RES_dut, COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut);
                $display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b                                                                                                             ",RES_ref, COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref);
            end else begin
                $display("   DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b", RES_dut, COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut);
                $display("  HELD: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b", RES_hold, COUT_hold, OFLOW_hold, G_hold, E_hold, L_hold, ERR_hold);
            end
        end
    endtask


    // Waveform dump
    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, test_alu);
    end

endmodule