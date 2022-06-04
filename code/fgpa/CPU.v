module CPU(reset, sysclk, sw, bcd7, an, leds);
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
    
    reg [31:0] PC;
    wire [31:0] Instruction;
	wire [1:0] PCSrc;
	wire Branch;
	wire RegWrite;
	wire [1:0] RegDst;
	wire MemRead;
	wire MemWrite;
	wire [1:0] MemtoReg;
	wire ALUSrc1;
	wire ALUSrc2;
	wire ExtOp;
	wire LuOp;

    wire [31:0] data1;
    wire [31:0] data2;
    wire [4:0] ALUCtrl;
    wire Sign;
    wire [31:0] ALUresult;
    wire Zero;
    wire [31:0] ReadData;

    wire [31:0] WriteData;
    wire [4:0] Rw;
    wire [31:0] ALUin1;
    wire [31:0] ALUin2;

    assign WriteData = MemtoReg == 0 ? ALUresult : 
                            MemtoReg == 2 ? PC + 4 : ReadData;
    assign Rw = RegDst == 2'b00 ? Instruction[20:16] : 
                    RegDst == 2'b01 ? Instruction[15:11] : 31;
    assign ALUin1 = ALUSrc1 ? {27'h0000000, Instruction[10:6]} : data1;
    assign ALUin2 = ALUSrc2 ? (ExtOp ? {{16{Instruction[15]}}, Instruction[15:0]} : {16'h0000, Instruction[15:0]}) : data2;

    InstructionMemory GetInst(PC, Instruction);    
    
    Control Decoder(Instruction[31:26], Instruction[5:0], PCSrc, Branch, 
                        RegWrite, RegDst, MemRead, MemWrite, MemtoReg, 
                            ALUSrc1, ALUSrc2, ExtOp, LuOp);
    
    RegisterFile RF1(reset, clk, RegWrite, Instruction[25:21], Instruction[20:16], 
                        Rw, WriteData, data1, data2);
    
    ALUControl ALUController(Instruction[31:26], Instruction[5:0], ALUCtrl, Sign);

    ALU ALU1(ALUCtrl, Sign, ALUin1, ALUin2, ALUresult, Zero);

    DataMemory MemController(reset, clk, ALUresult, data2, ReadData, MemRead, MemWrite);

    always@(posedge clk or posedge reset) begin
        if(reset)
            PC <= 0;
        else if(PCSrc == 1)
            PC <= {PC[31:28], Instruction[25:0], 2'b00};
        else if (PCSrc == 2)
            PC <= data1;
        else if(Branch & Zero)
            PC <= PC + 4 + (Instruction[15:0] << 2);
        else 
            PC <= PC + 4;
    end

    //--------------Your code above-----------------------
    BCD7 BCD(bcd_in, bcd7);
    BCD_16to4 BCD_tran(reset, sysclk, display_sig, bcd_in, an);
    assign display_sig = sw == 2'b00 ? RF1.RF_data[4] :
                         sw == 2'b01 ? RF1.RF_data[2] :
                         sw == 2'b10 ? RF1.RF_data[29] :
                         sw == 2'b11 ? RF1.RF_data[31] : 0;

    AdjustClk Adjust(sysclk, clk);
    assign leds = PC[7:0];

endmodule
	