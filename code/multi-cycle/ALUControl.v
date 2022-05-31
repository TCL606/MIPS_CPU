module ALUControl (
    ALUOp,
    Funct,
    ALUCtrl,
    Sign
);

parameter ADD = 0;
parameter SUB = 1;
parameter AND = 2;
parameter OR = 3;
parameter XOR = 4;
parameter NOR = 5;
parameter SLL = 6;
parameter SRL = 7;
parameter SRA = 8;
parameter SLT = 9;

parameter ALUOp_ADD = 3'b000;
parameter ALUOp_NULL = 3'b001;
parameter ALUOp_SLT = 3'b010;
parameter ALUOp_SUB = 3'b011;
parameter ALUOp_AND = 3'b100;

input [3:0] ALUOp;
input [5:0] Funct;
output [4:0] ALUCtrl;
output Sign;

reg [4:0] ALUCtrl;
wire Sign;

assign Sign = (ALUOp[2:0] == ALUOp_NULL)? ~Funct[0]: ~ALUOp[3];  // R ? ~Funct0 : ~I0 

reg [4:0] ALUConf;
always @(*) begin
    case(ALUOp[2:0]) 
        ALUOp_ADD: ALUCtrl <= ADD; 
        ALUOp_SUB: ALUCtrl <= SUB;  
        ALUOp_AND: ALUCtrl <= AND; 
        ALUOp_SLT: ALUCtrl <= SLT;  
        ALUOp_NULL: ALUCtrl <= ALUConf;
        default: ALUCtrl <= ADD;        // Default: ADD 
    endcase
end
    
always @(*) begin
    case(Funct)
        6'h20: ALUConf <= ADD;
        6'h21: ALUConf <= ADD;
        6'h22: ALUConf <= SUB;
        6'h23: ALUConf <= SUB;
        6'h24: ALUConf <= AND;
        6'h25: ALUConf <= OR;
        6'h26: ALUConf <= XOR;
        6'h27: ALUConf <= NOR;
        6'h00: ALUConf <= SLL;
        6'h02: ALUConf <= SRL;
        6'h03: ALUConf <= SRA;
        6'h2a: ALUConf <= SLT;
        6'h2b: ALUConf <= SLT;
        6'h08: ALUConf <= ADD;  // jr
        6'h09: ALUConf <= ADD;  // jalr
        default: ALUConf <= ADD;
    endcase
end

endmodule