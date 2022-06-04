`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: MultiCycleCPU
// Project Name: Multi-cycle-cpu
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MultiCycleCPU (reset, sysclk, sw, bcd7, an, leds);
    //Input Clock Signals
    input reset, sysclk, sw;
    output bcd7, an, leds;
    
    //--------------Your code below-----------------------
    wire reset;
    wire sysclk;
    wire [1:0] sw;
    wire [6:0] bcd7;
    wire [3:0] an;
    wire [7:0] leds;

    wire clk;
    wire [15:0] display_sig;
    wire [3:0] bcd_in;

    wire  [5:0] OpCode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] Shamt;
    wire  [5:0] Funct;
    wire PCWrite;
    wire PCWriteCond;
    wire IorD;
    wire MemWrite;
    wire MemRead;
    wire IRWrite;
    wire [1:0] MemtoReg;
    wire [1:0] RegDst;
    wire RegWrite;
    wire ExtOp;
    wire LuiOp;
    wire [1:0] ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [3:0] ALUOp;
    wire [1:0] PCSource;

    wire [31:0] Instruction;
    wire [31:0] Address;
    wire [31:0] MemData;
    wire [31:0] PC_now;
    wire [31:0] PC_new;
    wire [31:0] dataB;
    wire [31:0] dataA;
    assign Address = IorD ? ALUOutbeq : PC_now;
    InstAndDataMemory InstAndDataCtrler(reset, clk, Address, dataB, MemRead, MemWrite, MemData);
    assign Instruction = IRWrite ? MemData : Instruction;

    wire [31:0] MDRout;
    RegTemp MDR(reset, clk, MemData, MDRout);

    InstReg Decoder(reset, clk, IRWrite, Instruction, OpCode, 
                        rs, rt, rd, Shamt, Funct);

    Controller Ctrl1(reset, clk, OpCode, Funct, PCWrite, 
                        PCWriteCond, IorD, MemWrite, MemRead, IRWrite, 
                            MemtoReg, RegDst, RegWrite, ExtOp, LuiOp,
                                ALUSrcA, ALUSrcB, ALUOp, PCSource);

    wire [31:0] ImmExtOut;
    wire [31:0] ImmExtShift;
    ImmProcess Imm1(ExtOp, LuiOp, {rd, Shamt, Funct}, ImmExtOut, ImmExtShift);

    wire [4:0] Rw;    // 0: rt; 1: rd; 2: ra
    assign Rw = RegDst == 2'b00 ? rt : 
                    RegDst == 2'b01 ? rd : 31;

    wire [31:0] Write_data;
    assign Write_data = MemtoReg == 2'b10 ? PC_now:      // ra
                           MemtoReg == 2'b00 ? MDRout : ALUOutput;
    RegisterFile RF1(reset, clk, RegWrite, rs, rt, 
                        Rw, Write_data, dataA, dataB);
                        
    wire [31:0] dataA_out;
    wire [31:0] dataB_out;
    RegTemp dataAReg(reset, clk, dataA, dataA_out);
    RegTemp dataBReg(reset, clk, dataB, dataB_out);

    wire Sign;
    wire [4:0] ALUCtrl;
    ALUControl ALUController(ALUOp, Funct, ALUCtrl, Sign);

    wire [31:0] ALUinA;
    wire [31:0] ALUinB;
    assign ALUinA = ALUSrcA == 2'b10 ? {27'h0000000, Shamt} :
                        ALUSrcA == 2'b00 ? PC_now : dataA_out;
    assign ALUinB = ALUSrcB == 2'b11 ? ImmExtShift :
                        ALUSrcB == 2'b10 ? ImmExtOut :
                            ALUSrcB == 2'b01 ? 32'd04 : dataB_out;

    wire [31:0] ALUOutput;
    wire Zero;
    ALU ALU1(ALUCtrl, Sign, ALUinA, ALUinB, ALUOutput, Zero);

    wire [31:0] ALUOutbeq;
    RegTemp ALUOut1(reset, clk, ALUOutput, ALUOutbeq);

    assign PC_new = PCSource == 2'b10 ? {PC_now[31:28], rs, rt, rd, Shamt, Funct, 2'b00} : 
                        PCSource == 2'b01 ? ALUOutbeq : 
                            PCSource == 2'b11 ? dataA_out : ALUOutput;

    wire PCWrite_hat;
    assign PCWrite_hat = PCWrite | (Zero & PCWriteCond);
    PC PCController(reset, clk, PCWrite_hat, PC_new, PC_now);

    //--------------Your code above-----------------------
    BCD7 BCD(bcd_in, bcd7);
    BCD_16to4 BCD_tran(reset, sysclk, display_sig, bcd_in, an);
    assign display_sig = sw == 2'b00 ? RF1.RF_data[4] :
                         sw == 2'b01 ? RF1.RF_data[2] :
                         sw == 2'b10 ? RF1.RF_data[29] :
                         sw == 2'b11 ? RF1.RF_data[31] : 0;

    AdjustClk Adjust(sysclk, clk);
    assign leds = PC_now[7:0];

endmodule